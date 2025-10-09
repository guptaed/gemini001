import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/announcement.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';

class ListAnnouncementsScreen extends StatefulWidget {
  const ListAnnouncementsScreen({super.key});

  @override
  State<ListAnnouncementsScreen> createState() => _ListAnnouncementsScreenState();
}

class _ListAnnouncementsScreenState extends State<ListAnnouncementsScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  late Stream<List<Announcement>> _announcementsStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _announcementsStream = _firestoreHelper.streamAnnouncements();
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
        // Already on ListAnnouncementsScreen, do nothing
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddBidScreen()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListBidsScreen()),
        );
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
      title: 'List Announcements',
      userName: userName,
      selectedPageIndex: 3,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Announcements',
                hintText: 'Enter any field (e.g., Fuel Type, ID, Notes)',
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
            child: StreamBuilder<List<Announcement>>(
              stream: _announcementsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  final announcements = snapshot.data!;
                  if (announcements.isEmpty) {
                    return const Center(child: Text('No announcements added yet.'));
                  }
                  final filteredAnnouncements = announcements.where((announcement) {
                    final fields = [
                      announcement.announceId.toString(),
                      announcement.announceDate.toLowerCase(),
                      announcement.bidCloseDate.toLowerCase(),
                      announcement.deliveryDate.toLowerCase(),
                      announcement.fuelType.toLowerCase(),
                      announcement.quantity.toString(),
                      announcement.price.toString(),
                      announcement.status.toLowerCase(),
                      announcement.notes.toLowerCase(),
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
                    itemCount: filteredAnnouncements.length,
                    itemBuilder: (context, index) {
                      final announcement = filteredAnnouncements[index];
                      return Card(
                        elevation: 2,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  announcement.fuelType,
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
                                _buildDetailRow('ID', announcement.announceId.toString(), bodyMedium, theme),
                                _buildDetailRow('Status', announcement.status, bodyMedium, theme),
                                _buildDetailRow('Announce Date', announcement.announceDate, bodyMedium, theme),
                                _buildDetailRow('Bid Close Date', announcement.bidCloseDate, bodyMedium, theme),
                                _buildDetailRow('Delivery Date', announcement.deliveryDate, bodyMedium, theme),
                                _buildDetailRow('Quantity', announcement.quantity.toString(), bodyMedium, theme),
                                _buildDetailRow('Price', announcement.price.toString(), bodyMedium, theme),
                                _buildDetailRow('Notes', announcement.notes, bodyMedium, theme),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Start adding announcements!'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
