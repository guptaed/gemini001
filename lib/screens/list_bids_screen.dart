import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/bid.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';

class ListBidsScreen extends StatefulWidget {
  const ListBidsScreen({super.key});

  @override
  State<ListBidsScreen> createState() => _ListBidsScreenState();
}

class _ListBidsScreenState extends State<ListBidsScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  late Stream<List<Bid>> _bidsStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _bidsStream = _firestoreHelper.streamBids();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMenuItemSelected(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListSuppliersScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListAnnouncementsScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddBidScreen()),
        );
        break;
      case 5:
        // Already on ListBidsScreen, do nothing
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddShipmentScreen()),
        );
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListShipmentsScreen()),
        );
        break;

      case 10:  
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SupplierOnboardingDashboard()),
        );
        break;  



    }
  }

  Widget _buildDetailRow(String label, String value, TextStyle style, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: style.copyWith(color: theme.colorScheme.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    final theme = Theme.of(context);
    final bodyMedium = theme.textTheme.bodyMedium!;

    return CommonLayout(
      title: 'List Bids',
      userName: userName,
      selectedPageIndex: 5,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Bids',
                hintText: 'Enter any field (e.g., Supplier ID, Status, Notes)',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Bid>>(
              stream: _bidsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  final bids = snapshot.data!;
                  if (bids.isEmpty) {
                    return const Center(child: Text('No bids added yet.'));
                  }
                  final filteredBids = bids.where((bid) {
                    final fields = [
                      bid.supId.toString(),
                      bid.announceId.toString(),
                      bid.bidId.toString(),
                      bid.submittedDate.toLowerCase(),
                      bid.quantity.toString(),
                      bid.status.toLowerCase(),
                      bid.quantityAccepted.toString(),
                      bid.acceptRejectDate.toLowerCase(),
                      bid.notes.toLowerCase(),
                    ];
                    return fields.any((field) => field.contains(_searchQuery));
                  }).toList();
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                    ),
                    itemCount: filteredBids.length,
                    itemBuilder: (context, index) {
                      final bid = filteredBids[index];
                      return Card(
                        elevation: 2,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bid #${bid.bidId}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  height: 10,
                                ),
                                _buildDetailRow('Supplier ID', bid.supId.toString(), bodyMedium, theme),
                                _buildDetailRow('Announcement ID', bid.announceId.toString(), bodyMedium, theme),
                                _buildDetailRow('Bid ID', bid.bidId.toString(), bodyMedium, theme),
                                _buildDetailRow('Submitted Date', bid.submittedDate, bodyMedium, theme),
                                _buildDetailRow('Quantity', bid.quantity.toString(), bodyMedium, theme),
                                _buildDetailRow('Status', bid.status, bodyMedium, theme),
                                _buildDetailRow('Quantity Accepted', bid.quantityAccepted.toString(), bodyMedium, theme),
                                _buildDetailRow('Accept/Reject Date', bid.acceptRejectDate, bodyMedium, theme),
                                _buildDetailRow('Notes', bid.notes, bodyMedium, theme),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Start adding bids!'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
