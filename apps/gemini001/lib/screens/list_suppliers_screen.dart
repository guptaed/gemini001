import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/screens/supplier_details_screen.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:gemini001/screens/list_fuel_types_screen.dart';
import 'package:gemini001/screens/add_fuel_type_screen.dart';

class ListSuppliersScreen extends StatefulWidget {
  const ListSuppliersScreen({super.key});

  @override
  State<ListSuppliersScreen> createState() => _ListSuppliersScreenState();
}

class _ListSuppliersScreenState extends State<ListSuppliersScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  late Stream<List<Supplier>> _suppliersStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _suppliersStream = _firestoreHelper.streamSuppliers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMenuItemSelected(int index) {
    switch (index) {
      case 0:
        // Already on ListSuppliersScreen
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

  Widget _buildDetailRow(
      String label, String value, TextStyle style, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
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

  // Helper method for gradient badge colors
  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return [
          const Color.fromARGB(255, 19, 18, 18),
          const Color.fromARGB(255, 110, 110, 110)
        ];
      case 'active':
        return [
          const Color.fromARGB(255, 19, 88, 82),
          const Color.fromARGB(255, 35, 170, 157)
        ];
      case 'at risk':
        return [
          const Color.fromARGB(255, 238, 149, 16),
          const Color.fromARGB(255, 221, 146, 34)
        ];
      case 'terminated':
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
      case 'new':
        return Icons.circle_outlined;
      case 'active':
        return Icons.check_circle_outline;
      case 'at risk':
        return Icons.warning_amber_outlined;
      case 'terminated':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // Helper method to build the gradient badge with icon
  Widget _buildStatusBadge(String status, ThemeData theme) {
    return Semantics(
      label: 'Supplier status: $status',
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
      title: 'List Suppliers',
      userName: userName,
      selectedPageIndex: 0,
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
                    labelText: 'Search Suppliers',
                    hintText: 'Enter Name, ID, or Status',
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
              child: StreamBuilder<List<Supplier>>(
                stream: _suppliersStream,
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
                    final suppliers = snapshot.data!;
                    if (suppliers.isEmpty) {
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
                              Text('No suppliers added yet.',
                                  style: bodyMedium),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AddSupplierScreen()),
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
                                child: const Text('Add Supplier'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    final filteredSuppliers = suppliers.where((supplier) {
                      final fields = [
                        supplier.SupId.toString(),
                        supplier.CompanyName.toLowerCase(),
                        supplier.Address.toLowerCase(),
                        supplier.Tel.toLowerCase(),
                        supplier.Email.toLowerCase(),
                        supplier.TaxCode.toLowerCase(),
                        supplier.Representative.toLowerCase(),
                        supplier.Title.toLowerCase(),
                        supplier.Status.toLowerCase(),
                      ];
                      return fields
                          .any((field) => field.contains(_searchQuery));
                    }).toList();
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 1.5, // Adjusted for more content
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: filteredSuppliers.length,
                      itemBuilder: (context, index) {
                        final supplier = filteredSuppliers[index];
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
                                    builder: (context) => SupplierDetailsScreen(
                                        supplier: supplier),
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
                                      child: Text(
                                        supplier.CompanyName,
                                        style: titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
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
                                                supplier.SupId.toString(),
                                                bodyMedium,
                                                theme),
                                            _buildDetailRow(
                                                'Representative',
                                                supplier.Representative,
                                                bodyMedium,
                                                theme),
                                            _buildDetailRow(
                                                'Address',
                                                supplier.Address,
                                                bodyMedium,
                                                theme),
                                            _buildDetailRow(
                                                'Email',
                                                supplier.Email,
                                                bodyMedium,
                                                theme),
                                            const SizedBox(height: 4),
                                            _buildStatusBadge(
                                                supplier.Status, theme),
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
                          Text('Start adding suppliers!', style: bodyMedium),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AddSupplierScreen()),
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
                            child: const Text('Add Supplier'),
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
