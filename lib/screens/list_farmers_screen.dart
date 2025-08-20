// lib/screens/list_farmers_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper.dart';
import 'package:gemini001/models/farmer.dart';
import 'package:gemini001/screens/delete_confirmation_screen.dart';


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
        title: const Text('Farmer List'),
      ),
      body: StreamBuilder<List<Farmer>>(
        
        stream: _firestoreHelper.streamFarmers(),                               // Now we call the streamFarmers() method which returns a Stream<List<Farmer>>
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
            return ListView.builder(                                            // Use a ListView to display the list of farmers.
              itemCount: farmers.length,
              itemBuilder: (context, index) {
                final farmer = farmers[index];
                return ListTile(                  
                  title: Text('${farmer.firstName} ${farmer.lastName}'),        // We'll combine the first and last name for the title.                  
                  subtitle: Text(farmer.address),                               // We'll use the address for the subtitle, as there is no 'location' property.
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Handle edit farmer functionality
                        },
                      ),
                      
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DeleteConfirmationScreen(farmer: farmer),
                            ),
                          );
                          if (result == true) { // If deletion happened, refresh the list
                            setState(() {
                              _farmersStream = _firestoreHelper.streamFarmers();
                            });
                          }
                        },
                      ),
                    ],
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
        onPressed: () {
          // Handle adding a new farmer
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
