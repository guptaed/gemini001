// lib/screens/list_farmers_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper.dart';
import 'package:gemini001/models/farmer.dart';

// This screen displays a list of farmers and is the main screen for the app.
class ListFarmersScreen extends StatefulWidget {
  const ListFarmersScreen({super.key});

  @override
  State<ListFarmersScreen> createState() => _ListFarmersScreenState();
}

class _ListFarmersScreenState extends State<ListFarmersScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer List'),
      ),
      body: StreamBuilder<List<Farmer>>(
        // Now we call the streamFarmers() method which returns a Stream<List<Farmer>>
        // This is the key change to fix the type mismatch error.
        stream: _firestoreHelper.streamFarmers(),
        builder: (context, snapshot) {
          // Show a loading indicator if the stream is still waiting for data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If there's an error, show an error message.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // If the snapshot has data, display the list.
          if (snapshot.hasData) {
            final farmers = snapshot.data!;
            // Show a message if there are no farmers.
            if (farmers.isEmpty) {
              return const Center(child: Text('No farmers added yet.'));
            }
            // Use a ListView to display the list of farmers.
            return ListView.builder(
              itemCount: farmers.length,
              itemBuilder: (context, index) {
                final farmer = farmers[index];
                return ListTile(
                  // We'll combine the first and last name for the title.
                  title: Text('${farmer.firstName} ${farmer.lastName}'),
                  // We'll use the address for the subtitle, as there is no 'location' property.
                  subtitle: Text(farmer.address),
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
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Handle delete farmer functionality
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
