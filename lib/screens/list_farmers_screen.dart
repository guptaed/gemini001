// lib/screens/list_farmers_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper.dart';
import 'package:gemini001/models/farmer.dart';
import 'package:gemini001/screens/add_farmer_screen.dart';
import 'package:gemini001/screens/farmer_details_screen.dart'; 

// This screen displays a list of farmers and is the main screen for the app.
class ListFarmersScreen extends StatefulWidget {
  const ListFarmersScreen({super.key});

  @override
  State<ListFarmersScreen> createState() => _ListFarmersScreenState();
}

class _ListFarmersScreenState extends State<ListFarmersScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  late Stream<List<Farmer>> _farmersStream;

  @override
  void initState() {
    super.initState();
    _farmersStream = _firestoreHelper.streamFarmers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers List'),
      ),
      body: StreamBuilder<List<Farmer>>(
        
        stream: _farmersStream,                               
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {            // If the connection is still waiting, show a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {                                              
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          if (snapshot.hasData) {                                               // If we have data, we can display the list of farmers.                               
            final farmers = snapshot.data!;            
            if (farmers.isEmpty) {                                              // If the list is empty, show a message indicating no farmers have been added yet.  
              return const Center(child: Text('No farmers added yet.'));
            }            
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: farmers.length,
              itemBuilder: (context, index) {
                final farmer = farmers[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmerDetailsScreen(farmer: farmer),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${farmer.firstName} ${farmer.lastName}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(farmer.companyName),
                          Text(farmer.address),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          // Default case: Show a simple message if no data is available.
          return const Center(child: Text('Start adding farmers!'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddFarmerScreen(),
              ),
            );
            if (result == true) {
              setState(() {
                _farmersStream = _firestoreHelper.streamFarmers();
              });
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error navigating to Add Farmer: $e')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
