// lib/screens/list_suppliers_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/supplier.dart';
// import 'package:gemini001/screens/add_supplier_screen.dart';
// import 'package:gemini001/screens/supplier_details_screen.dart';

// This screen displays a list of suppliers and is the main screen for the app.
class ListSuppliersScreen extends StatefulWidget {
  const ListSuppliersScreen({super.key});

  @override
  State<ListSuppliersScreen> createState() => _ListSuppliersScreenState();
}

class _ListSuppliersScreenState extends State<ListSuppliersScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  late Stream<List<Supplier>> _suppliersStream;

  @override
  void initState() {
    super.initState();
    _suppliersStream = _firestoreHelper.streamSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers List'),
      ),
      body: StreamBuilder<List<Supplier>>(
        
        stream: _suppliersStream,                               
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {            // If the connection is still waiting, show a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {                                              
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.hasData) {                                               // If we have data, we can display the list of suppliers.                               
            final suppliers = snapshot.data!;            
            if (suppliers.isEmpty) {                                              // If the list is empty, show a message indicating no suppliers have been added yet.  
              return const Center(child: Text('No suppliers added yet.'));
            }            
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: suppliers.length,
              itemBuilder: (context, index) {
                final supplier = suppliers[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => SupplierDetailsScreen(supplier: supplier),
                      //   ),
                      // );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            supplier.CompanyName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(supplier.Representative),
                          Text(supplier.Status),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          // Default case: Show a simple message if no data is available.
          return const Center(child: Text('Start adding suppliers!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // try {
          //   final result = await Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => AddSupplierScreen(),
          //     ),
          //   );
          //   if (result == true) {
          //     setState(() {
          //       _suppliersStream = _firestoreHelper.streamSuppliers();
          //     });
          //   }
          // } catch (e) {
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text('Error navigating to Add Supplier: $e')),
          //   );
          // }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
