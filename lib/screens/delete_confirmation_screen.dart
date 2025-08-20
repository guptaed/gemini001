// lib/screens/delete_confirmation_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/models/farmer.dart';
import 'package:gemini001/database/firestore_helper.dart';

class DeleteConfirmationScreen extends StatefulWidget {
  final Farmer farmer;

  const DeleteConfirmationScreen({super.key, required this.farmer});

  @override
  _DeleteConfirmationScreenState createState() => _DeleteConfirmationScreenState();
}

class _DeleteConfirmationScreenState extends State<DeleteConfirmationScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  void _deleteFarmer() async {
    try {
      if (widget.farmer.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Farmer ID is missing')),
        );
        return;
      }
      await _firestoreHelper.deleteFarmer(widget.farmer.id!); // Use ! if you're sure it's non-null
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The farmer has been deleted')),
      );
      Navigator.pop(context, true); // Return true to indicate deletion
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting farmer: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmer = widget.farmer;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Deletion')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('First Name: ${farmer.firstName}', style: const TextStyle(fontSize: 18)),
            Text('Last Name: ${farmer.lastName}', style: const TextStyle(fontSize: 18)),
            Text('Company Name: ${farmer.companyName}', style: const TextStyle(fontSize: 18)),
            Text('Address: ${farmer.address}', style: const TextStyle(fontSize: 18)),
            Text('Phone: ${farmer.phone}', style: const TextStyle(fontSize: 18)),
            Text('Email: ${farmer.email}', style: const TextStyle(fontSize: 18)),
            Text('Total Farm Size (acres): ${farmer.totalFarmSize}', style: const TextStyle(fontSize: 18)),
            Text('Monthly Selling Capacity (tons): ${farmer.sellingCapacityPerMonthTons}', style: const TextStyle(fontSize: 18)),
            Text('Yearly Selling Capacity (tons): ${farmer.sellingCapacityPerYearTons}', style: const TextStyle(fontSize: 18)),
            const Spacer(),
            ElevatedButton(
              onPressed: _deleteFarmer,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Press to Delete Farmer Information'),
            ),
          ],
        ),
      ),
    );
  }
}