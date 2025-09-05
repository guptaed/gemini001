import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/screens/supplier_details_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      childAspectRatio: 3,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    supplier.CompanyName,
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    supplier.Representative,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Status: ${supplier.Status}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Divider(
                                    color: Colors.grey,
                                    thickness: 1,
                                    height: 10,
                                  ),
                                  Text('ID: ${supplier.SupId}'),
                                  Text('Address: ${supplier.Address}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Tel: ${supplier.Tel}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Email: ${supplier.Email}', maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Tax Code: ${supplier.TaxCode}', maxLines: 1, overflow: TextOverflow.ellipsis),
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
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     try {
      //       final result = await Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder: (context) => AddSupplierScreen(),
      //         ),
      //       );
      //       if (result == true) {
      //         setState(() {
      //           _suppliersStream = _firestoreHelper.streamSuppliers();
      //         });
      //       }
      //     } catch (e) {
      //       ScaffoldMessenger.of(context).showSnackBar(
      //         SnackBar(content: Text('Error navigating to Add Supplier: $e')),
      //       );
      //     }
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
