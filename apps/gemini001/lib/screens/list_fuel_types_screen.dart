import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/fuel_type.dart';
import 'package:gemini001/screens/add_fuel_type_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/widgets/common_layout.dart';

class ListFuelTypesScreen extends StatefulWidget {
  const ListFuelTypesScreen({super.key});

  @override
  State<ListFuelTypesScreen> createState() => _ListFuelTypesScreenState();
}

class _ListFuelTypesScreenState extends State<ListFuelTypesScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  late Stream<List<FuelType>> _fuelTypesStream;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _categoryFilter = 'All';

  @override
  void initState() {
    super.initState();
    _fuelTypesStream = _firestoreHelper.streamFuelTypes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onMenuItemSelected(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListSuppliersScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSupplierScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListAnnouncementsScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBidScreen()));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListBidsScreen()));
        break;
      case 6:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddShipmentScreen()));
        break;
      case 7:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListShipmentsScreen()));
        break;
      case 10:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplierOnboardingDashboard()));
        break;
      case 11:
        // Already on ListFuelTypesScreen
        break;
      case 12:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelTypeScreen()));
        break;
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'wood':
        return [const Color(0xFF5D4037), const Color(0xFF8D6E63)];
      case 'agricultural residue':
        return [const Color(0xFF33691E), const Color(0xFF689F38)];
      case 'other biomass':
        return [const Color(0xFFE65100), const Color(0xFFFF9800)];
      default:
        return [Colors.grey[600]!, Colors.grey[400]!];
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'wood':
        return Icons.forest;
      case 'agricultural residue':
        return Icons.grass;
      case 'other biomass':
        return Icons.eco;
      default:
        return Icons.category;
    }
  }

  Widget _buildDetailRow(String label, String value, TextStyle style, ThemeData theme) {
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

  Widget _buildCategoryBadge(String category, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCategoryGradient(category),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(category), size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            category,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? Colors.green.withValues(alpha: 0.5) : Colors.red.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.green[800] : Colors.red[800],
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
      title: 'Fuel Type Master',
      userName: userName,
      selectedPageIndex: 11,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Container(
        color: Colors.grey[100],
        child: Column(
          children: [
            // Search and filter bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search Fuel Types',
                          hintText: 'Enter ID, Name, Category, or Subcategory',
                          prefixIcon: Icon(Icons.search, color: theme.colorScheme.primary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.clear, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          ),
                        ),
                        onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Category filter dropdown
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _categoryFilter,
                          items: const [
                            DropdownMenuItem(value: 'All', child: Text('All Categories')),
                            DropdownMenuItem(value: 'Wood', child: Text('Wood')),
                            DropdownMenuItem(value: 'Agricultural Residue', child: Text('Agricultural Residue')),
                            DropdownMenuItem(value: 'Other Biomass', child: Text('Other Biomass')),
                          ],
                          onChanged: (value) => setState(() => _categoryFilter = value ?? 'All'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<FuelType>>(
                stream: _fuelTypesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, color: theme.colorScheme.error, size: 40),
                              const SizedBox(height: 8),
                              Text('Error: ${snapshot.error}', style: bodyMedium),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  if (snapshot.hasData) {
                    final fuelTypes = snapshot.data!;
                    if (fuelTypes.isEmpty) {
                      return Center(
                        child: Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 40),
                                const SizedBox(height: 8),
                                Text('No fuel types added yet.', style: bodyMedium),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelTypeScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor: theme.colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  ),
                                  child: const Text('Add Fuel Type'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    // Apply filters
                    final filtered = fuelTypes.where((ft) {
                      final matchesCategory = _categoryFilter == 'All' || ft.Category == _categoryFilter;
                      final matchesSearch = _searchQuery.isEmpty || [
                        ft.FuelTypeId.toLowerCase(),
                        ft.FuelTypeName.toLowerCase(),
                        ft.Category.toLowerCase(),
                        ft.Subcategory.toLowerCase(),
                        ft.CertificationStatus.toLowerCase(),
                        ft.UnitOfMeasure.toLowerCase(),
                        ft.Description.toLowerCase(),
                      ].any((field) => field.contains(_searchQuery));
                      return matchesCategory && matchesSearch;
                    }).toList();

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: 1.3,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final fuelType = filtered[index];
                        return Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: Colors.white,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddFuelTypeScreen(fuelType: fuelType),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          fuelType.FuelTypeName,
                                          style: titleMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: theme.colorScheme.primary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildActiveBadge(fuelType.IsActive),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _buildDetailRow('Code', fuelType.FuelTypeId, bodyMedium, theme),
                                        _buildDetailRow('Subcategory', fuelType.Subcategory, bodyMedium, theme),
                                        _buildDetailRow('Certification', fuelType.CertificationStatus, bodyMedium, theme),
                                        _buildDetailRow('Unit', fuelType.UnitOfMeasure, bodyMedium, theme),
                                        const SizedBox(height: 4),
                                        _buildCategoryBadge(fuelType.Category, theme),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Center(
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 40),
                            const SizedBox(height: 8),
                            Text('Start adding fuel types!', style: bodyMedium),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelTypeScreen()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('Add Fuel Type'),
                            ),
                          ],
                        ),
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
