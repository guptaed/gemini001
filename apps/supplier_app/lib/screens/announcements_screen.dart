import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_app/database/firestore_helper.dart';
import 'package:supplier_app/providers/auth_provider.dart';
import 'package:supplier_app/widgets/status_badge.dart';
import 'package:vietfuel_shared/vietfuel_shared.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Announcement>>(
        stream: FirestoreHelper().streamAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading announcements.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            );
          }

          final announcements = snapshot.data ?? [];

          if (announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.campaign, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No announcements yet.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final a = announcements[index];
              return _AnnouncementCard(announcement: a);
            },
          );
        },
      ),
    );
  }
}

class _AnnouncementCard extends StatelessWidget {
  final Announcement announcement;

  const _AnnouncementCard({required this.announcement});

  @override
  Widget build(BuildContext context) {
    final isOpen = announcement.status.toLowerCase() == 'open';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  announcement.fuelType,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                StatusBadge(status: announcement.status),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(label: 'Quantity', value: '${announcement.quantity}'),
            _InfoRow(label: 'Price', value: '${announcement.price}'),
            _InfoRow(label: 'Announce Date', value: announcement.announceDate),
            _InfoRow(label: 'Bid Close Date', value: announcement.bidCloseDate),
            _InfoRow(
                label: 'Delivery Date', value: announcement.deliveryDate),
            if (announcement.notes.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                announcement.notes,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
            if (isOpen) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () => _showBidDialog(context),
                  icon: const Icon(Icons.gavel),
                  label: const Text('Place Bid', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showBidDialog(BuildContext context) {
    final quantityController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Bid on ${announcement.fuelType}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 18),
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a quantity';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: notesController,
                maxLines: 2,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  labelStyle: TextStyle(fontSize: 16),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final auth =
                  Provider.of<AuthProvider>(context, listen: false);
              final supId = auth.supId;
              if (supId == null) return;

              final now = DateTime.now();
              final dateStr =
                  '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

              final bid = Bid(
                supId: supId,
                announceId: announcement.announceId,
                bidId: 0, // Will be assigned by backend or auto-generated
                submittedDate: dateStr,
                quantity: int.parse(quantityController.text),
                quantityAccepted: 0,
                status: 'Submitted',
                acceptRejectDate: '',
                notes: notesController.text,
              );

              try {
                await FirestoreHelper().submitBid(bid);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bid submitted successfully!',
                          style: TextStyle(fontSize: 16)),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to submit bid. Please try again.',
                          style: TextStyle(fontSize: 16)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            child:
                const Text('Submit Bid', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(fontSize: 15, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
