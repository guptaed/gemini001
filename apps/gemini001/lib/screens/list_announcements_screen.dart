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
import 'package:gemini001/screens/announcement_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:gemini001/screens/list_fuel_types_screen.dart';
import 'package:gemini001/screens/add_fuel_type_screen.dart';

class ListAnnouncementsScreen extends StatefulWidget {
  const ListAnnouncementsScreen({super.key});

  @override
  State<ListAnnouncementsScreen> createState() =>
      _ListAnnouncementsScreenState();
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
          MaterialPageRoute(
              builder: (context) => const AddAnnouncementScreen()),
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
          MaterialPageRoute(
              builder: (context) => const SupplierOnboardingDashboard()),
        );
        break;
      case 11:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListFuelTypesScreen()));
        break;
      case 12:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelTypeScreen()));
        break;
    }
  }

  Widget _buildDetailRow(
      String label, String value, TextStyle style, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
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

  // Helper method for gradient badge colors based on announcement status
  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return [
          const Color.fromARGB(255, 19, 88, 82),
          const Color.fromARGB(255, 35, 170, 157)
        ];
      case 'closed':
        return [
          const Color.fromARGB(255, 151, 35, 33),
          const Color.fromARGB(255, 167, 41, 41)
        ];
      default:
        return [Colors.grey[400]!, Colors.grey[200]!];
    }
  }

  // Helper method for status icon
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.campaign_outlined;
      case 'closed':
        return Icons.lock_clock;
      default:
        return Icons.help_outline;
    }
  }

  // Helper method to build the gradient badge with icon
  Widget _buildStatusBadge(String status, ThemeData theme) {
    return Semantics(
      label: 'Announcement status: $status',
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _getStatusGradient(status),
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 14,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              status.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    final theme = Theme.of(context);
    final bodyMedium = theme.textTheme.bodyMedium!;
    final titleMedium = theme.textTheme.titleMedium!;

    return CommonLayout(
      title: 'List Announcements',
      userName: userName,
      selectedPageIndex: 3,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search Announcements',
                    hintText: 'Enter Fuel Type, ID, Status, or Notes',
                    prefixIcon:
                        Icon(Icons.search, color: theme.colorScheme.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7)),
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
            ),
            Expanded(
              child: StreamBuilder<List<Announcement>>(
                stream: _announcementsStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                color: theme.colorScheme.error, size: 40),
                            const SizedBox(height: 8),
                            Text('Error: ${snapshot.error}', style: bodyMedium),
                          ],
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    final announcements = snapshot.data!;
                    if (announcements.isEmpty) {
                      return Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline,
                                  color: theme.colorScheme.primary, size: 40),
                              const SizedBox(height: 8),
                              Text('No announcements added yet.',
                                  style: bodyMedium),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddAnnouncementScreen()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                ),
                                child: const Text('Add Announcement'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final filteredAnnouncements =
                        announcements.where((announcement) {
                      final fields = [
                        announcement.announceId.toString(),
                        announcement.announceDate.toLowerCase(),
                        announcement.bidCloseDate.toLowerCase(),
                        announcement.deliveryDate.toLowerCase(),
                        announcement.fuelTypeId.toLowerCase(),
                        announcement.fuelType.toLowerCase(),
                        announcement.quantity.toString(),
                        announcement.price.toString(),
                        announcement.status.toLowerCase(),
                        announcement.notes.toLowerCase(),
                      ];
                      return fields
                          .any((field) => field.contains(_searchQuery));
                    }).toList();
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: filteredAnnouncements.length,
                      itemBuilder: (context, index) {
                        final announcement = filteredAnnouncements[index];
                        return MouseRegion(
                          onEnter: (_) => setState(() {}),
                          onExit: (_) => setState(() {}),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AnnouncementDetailsScreen(
                                            announcement: announcement),
                                  ),
                                );
                              },
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.width / 2.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            announcement.fuelType,
                                            style: titleMedium.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (announcement.fuelTypeId.isNotEmpty)
                                            Text(
                                              announcement.fuelTypeId,
                                              style: bodyMedium.copyWith(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildDetailRow(
                                                'ID',
                                                announcement.announceId
                                                    .toString(),
                                                bodyMedium,
                                                theme),
                                            _buildDetailRow(
                                                'Quantity',
                                                '${announcement.quantity} liters',
                                                bodyMedium,
                                                theme),
                                            _buildDetailRow(
                                                'Price',
                                                '${announcement.price} VND/L',
                                                bodyMedium,
                                                theme),
                                            _buildDetailRow(
                                                'Bid Close',
                                                announcement.bidCloseDate,
                                                bodyMedium,
                                                theme),
                                            _buildDetailRow(
                                                'Delivery',
                                                announcement.deliveryDate,
                                                bodyMedium,
                                                theme),
                                            const SizedBox(height: 4),
                                            _buildStatusBadge(
                                                announcement.status, theme),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Card(
                    margin: const EdgeInsets.all(16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline,
                              color: theme.colorScheme.primary, size: 40),
                          const SizedBox(height: 8),
                          Text('Start adding announcements!',
                              style: bodyMedium),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddAnnouncementScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            child: const Text('Add Announcement'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
