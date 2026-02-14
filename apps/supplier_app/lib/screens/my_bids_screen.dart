import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_app/database/firestore_helper.dart';
import 'package:supplier_app/providers/auth_provider.dart';
import 'package:supplier_app/widgets/status_badge.dart';
import 'package:vietfuel_shared/vietfuel_shared.dart';

class MyBidsScreen extends StatelessWidget {
  const MyBidsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final supId = auth.supId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bids'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: supId == null
          ? const Center(child: Text('Unable to load bids.'))
          : StreamBuilder<List<Bid>>(
              stream: FirestoreHelper().streamBidsForSupplier(supId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading bids.',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                final bids = snapshot.data ?? [];

                if (bids.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.gavel, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No bids yet.',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Go to Announcements to place a bid.',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bids.length,
                  itemBuilder: (context, index) {
                    final bid = bids[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Bid #${bid.bidId}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                StatusBadge(status: bid.status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                                label: 'Announcement',
                                value: '#${bid.announceId}'),
                            _InfoRow(
                                label: 'Quantity Bid',
                                value: '${bid.quantity}'),
                            _InfoRow(
                                label: 'Submitted',
                                value: bid.submittedDate),
                            if (bid.quantityAccepted > 0)
                              _InfoRow(
                                  label: 'Qty Accepted',
                                  value: '${bid.quantityAccepted}'),
                            if (bid.acceptRejectDate.isNotEmpty)
                              _InfoRow(
                                  label: 'Decision Date',
                                  value: bid.acceptRejectDate),
                            if (bid.notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                bid.notes,
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
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
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
