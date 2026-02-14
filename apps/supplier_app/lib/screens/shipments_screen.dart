import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_app/database/firestore_helper.dart';
import 'package:supplier_app/providers/auth_provider.dart';
import 'package:supplier_app/widgets/status_badge.dart';
import 'package:vietfuel_shared/vietfuel_shared.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final supId = auth.supId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipments'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddShipmentDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add, size: 28),
        label: const Text('Add Shipment', style: TextStyle(fontSize: 16)),
      ),
      body: supId == null
          ? const Center(child: Text('Unable to load shipments.'))
          : StreamBuilder<List<Shipment>>(
              stream: FirestoreHelper().streamShipmentsForSupplier(supId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error loading shipments.',
                      style:
                          TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  );
                }

                final shipments = snapshot.data ?? [];

                if (shipments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_shipping,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No shipments yet.',
                          style: TextStyle(
                              fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap + to add a shipment.',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  itemCount: shipments.length,
                  itemBuilder: (context, index) {
                    final s = shipments[index];
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
                                  'Shipment #${s.ShipmentId}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                StatusBadge(status: s.Status),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                                label: 'Bid', value: '#${s.BidId}'),
                            _InfoRow(
                                label: 'Shipped Date',
                                value: s.ShippedDate),
                            if (s.ReceivedDate.isNotEmpty)
                              _InfoRow(
                                  label: 'Received Date',
                                  value: s.ReceivedDate),
                            if (s.Notes.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                s.Notes,
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

  void _showAddShipmentDialog(BuildContext context) {
    final bidIdController = TextEditingController();
    final shippedDateController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shipment'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: bidIdController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Bid ID',
                    labelStyle: TextStyle(fontSize: 16),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the Bid ID';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: shippedDateController,
                  style: const TextStyle(fontSize: 18),
                  decoration: const InputDecoration(
                    labelText: 'Shipped Date (YYYY-MM-DD)',
                    labelStyle: TextStyle(fontSize: 16),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      shippedDateController.text =
                          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
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

              final shipment = Shipment(
                ShipmentId: 0, // Will be assigned
                SupId: supId,
                BidId: int.parse(bidIdController.text),
                Status: 'Shipped',
                ShippedDate: shippedDateController.text,
                ReceivedDate: '',
                Notes: notesController.text,
              );

              try {
                await FirestoreHelper().addShipment(shipment);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Shipment added successfully!',
                          style: TextStyle(fontSize: 16)),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Failed to add shipment. Please try again.',
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
            child: const Text('Submit', style: TextStyle(fontSize: 16)),
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
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
