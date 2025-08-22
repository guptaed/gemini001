// lib/screens/farmer_details_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/models/farmer.dart';
import 'package:gemini001/screens/delete_confirmation_screen.dart';
import 'package:gemini001/screens/edit_farmer_screen.dart';

class FarmerDetailsScreen extends StatelessWidget {
  final Farmer farmer;
  
  FarmerDetailsScreen({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${farmer.firstName} ${farmer.lastName} Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${farmer.firstName}', style: const TextStyle(fontSize: 16)),
            Text('Last Name: ${farmer.lastName}', style: const TextStyle(fontSize: 16)),
            Text('Company Name: ${farmer.companyName}', style: const TextStyle(fontSize: 16)),
            Text('Address: ${farmer.address}', style: const TextStyle(fontSize: 16)),
            Text('Phone: ${farmer.phone}', style: const TextStyle(fontSize: 16)),
            Text('Email: ${farmer.email}', style: const TextStyle(fontSize: 16)),
            Text('Total Farm Size: ${farmer.totalFarmSize} acres', style: const TextStyle(fontSize: 16)),
            Text('Monthly Capacity: ${farmer.sellingCapacityPerMonthTons} tons', style: const TextStyle(fontSize: 16)),
            Text('Yearly Capacity: ${farmer.sellingCapacityPerYearTons} tons', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditFarmerScreen(farmer: farmer),
                      ),
                    );
                    if (result == true) {
                      Navigator.pop(context); // Return to details screen and refresh if needed
                      // Note: Refreshing requires state management or callback from parent
                    }
                  },
                  child: const Text('Edit'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeleteConfirmationScreen(farmer: farmer),
                      ),
                    );
                    if (result == true) {
                      Navigator.pop(context); // Return to list screen
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
