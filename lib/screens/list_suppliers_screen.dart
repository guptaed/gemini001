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
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';

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
        // Already on ListSuppliersScreen, do nothing
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListBidsScreen()),
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
      title: 'List Suppliers',
      userName: userName,
      selectedPageIndex: 0,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Suppliers',
                hintText: 'Enter any field (e.g., Name, ID, Status)',
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
                  icon: Icon(Icons.clear),
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
            child: StreamBuilder<List<Supplier>>(
              stream: _suppliersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData) {
                  final suppliers = snapshot.data!;
                  if (suppliers.isEmpty) {
                    return const Center(child: Text('No suppliers added yet.'));
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
                    itemCount: filteredSuppliers.length,
                    itemBuilder: (context, index) {
                      final supplier = filteredSuppliers[index];
                      return Card(
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SupplierDetailsScreen(supplier: supplier),
                              ),
                            );
                          },
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.CompanyName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    height: 10,
                                  ),
                                  _buildDetailRow('ID', supplier.SupId.toString(), bodyMedium, theme),
                                  _buildDetailRow('Representative', supplier.Representative, bodyMedium, theme),
                                  _buildDetailRow('Status', supplier.Status, bodyMedium, theme),
                                  _buildDetailRow('Address', supplier.Address, bodyMedium, theme),
                                  _buildDetailRow('Tel', supplier.Tel, bodyMedium, theme),
                                  _buildDetailRow('Email', supplier.Email, bodyMedium, theme),
                                  _buildDetailRow('Tax Code', supplier.TaxCode, bodyMedium, theme),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: Text('Start adding suppliers!'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
