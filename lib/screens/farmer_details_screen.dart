// lib/screens/farmer_details_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/models/farmer.dart';
import 'package:gemini001/screens/delete_confirmation_screen.dart';
import 'package:gemini001/screens/edit_farmer_screen.dart';

class FarmerDetailsScreen extends StatelessWidget {
  final Farmer farmer;

  const FarmerDetailsScreen({super.key, required this.farmer});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle headlineSmall = theme.textTheme.headlineSmall!;
    final TextStyle bodyMedium = theme.textTheme.bodyMedium!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${farmer.firstName} ${farmer.lastName} Details',
          style: headlineSmall.copyWith(color: theme.colorScheme.onPrimary),
        ),
        backgroundColor: theme.colorScheme.primary,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farmer Information',
                  style: headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('First Name', farmer.firstName, bodyMedium, theme),
                _buildDetailRow('Last Name', farmer.lastName, bodyMedium, theme),
                _buildDetailRow('Company Name', farmer.companyName, bodyMedium, theme),
                _buildDetailRow('Address', farmer.address, bodyMedium, theme),
                _buildDetailRow('Phone', farmer.phone, bodyMedium, theme),
                _buildDetailRow('Email', farmer.email, bodyMedium, theme),
                _buildDetailRow('Total Farm Size', '${farmer.totalFarmSize} acres', bodyMedium, theme),
                _buildDetailRow('Monthly Capacity', '${farmer.sellingCapacityPerMonthTons} tons', bodyMedium, theme),
                _buildDetailRow('Yearly Capacity', '${farmer.sellingCapacityPerYearTons} tons', bodyMedium, theme),
                const SizedBox(height: 24),
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Row(
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
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
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
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                          foregroundColor: theme.colorScheme.onError,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, TextStyle style, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: style.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.7)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: style.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
