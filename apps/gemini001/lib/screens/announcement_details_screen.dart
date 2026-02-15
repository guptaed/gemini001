// THIS IS A DUMMY FILE FOR ANNOUNCEMENT DETAILS SCREEN
// TO BE IMPLEMENTED PROPERLY LATER

import 'package:flutter/material.dart';
import 'package:gemini001/models/announcement.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:gemini001/screens/list_fuel_types_screen.dart';
import 'package:gemini001/screens/add_fuel_type_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';

class AnnouncementDetailsScreen extends StatelessWidget {
  final Announcement announcement;

  const AnnouncementDetailsScreen({super.key, required this.announcement});

  void _onMenuItemSelected(BuildContext context, int index) {
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
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ListAnnouncementsScreen()),
        );
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

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    final theme = Theme.of(context);

    return CommonLayout(
      title: 'Announcement Details',
      userName: userName,
      selectedPageIndex: 3,
      onMenuItemSelected: (index) => _onMenuItemSelected(context, index),
      mainContentPanel: Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Fuel Type
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal[700]!, Colors.teal[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_gas_station,
                          color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              announcement.fuelType,
                              style: theme.textTheme.headlineSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (announcement.fuelTypeId.isNotEmpty)
                              Text(
                                announcement.fuelTypeId,
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Details Section
                _buildDetailRow('Announcement ID',
                    announcement.announceId.toString(), theme),
                _buildDetailRow('Fuel Type Code',
                    announcement.fuelTypeId.isNotEmpty ? announcement.fuelTypeId : 'N/A', theme),
                _buildDetailRow('Status', announcement.status, theme),
                const Divider(height: 32),

                _buildDetailRow(
                    'Announce Date', announcement.announceDate, theme),
                _buildDetailRow(
                    'Bid Close Date', announcement.bidCloseDate, theme),
                _buildDetailRow(
                    'Delivery Date', announcement.deliveryDate, theme),
                const Divider(height: 32),

                _buildDetailRow(
                    'Quantity', '${announcement.quantity} liters', theme),
                _buildDetailRow(
                    'Price', '${announcement.price} VND/liter', theme),
                const Divider(height: 32),

                _buildDetailRow('Notes', announcement.notes, theme,
                    isMultiline: true),

                // Metadata section
                if (announcement.CreatedAt != null ||
                    announcement.LastModifiedAt != null) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 32),
                  _buildMetadataSection(theme),
                ],

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back to List'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to edit screen or show bids
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('View bids feature coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.visibility),
                      label: const Text('View Bids'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetadataSection(ThemeData theme) {
    final metadataStyle = TextStyle(
      fontSize: 12,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );

    String formatDateTime(DateTime? dt) {
      if (dt == null) return 'N/A';
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (announcement.CreatedAt != null) ...[
          Row(
            children: [
              Icon(Icons.add_circle_outline,
                  size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Created by ${announcement.CreatedByName ?? 'Unknown'} on ${formatDateTime(announcement.CreatedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
        if (announcement.LastModifiedAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Last modified by ${announcement.LastModifiedByName ?? 'Unknown'} on ${formatDateTime(announcement.LastModifiedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme,
      {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: isMultiline
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 150,
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    value,
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
    );
  }
}
