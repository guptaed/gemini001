// lib/screens/farmer_details_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/models/farmer.dart';
import 'package:gemini001/screens/delete_confirmation_screen.dart';
import 'package:gemini001/screens/edit_farmer_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gemini001/database/firestore_helper.dart';
import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class FarmerDetailsScreen extends StatelessWidget {
  final Farmer farmer;

  const FarmerDetailsScreen({super.key, required this.farmer});

  Future<void> _uploadPdf(BuildContext context) async {
    FilePickerResult? result;

    if (kIsWeb) {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
    } else {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
    }

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final storageRef = FirebaseStorage.instance.ref();
      final fileName = file.name;
      final pdfRef = storageRef.child("farmers/${farmer.id}/$fileName");

      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          double progress = 0.0;
          bool uploadComplete = false;
          UploadTask? uploadTask;

          return StatefulBuilder(
            builder: (BuildContext dialogContext, StateSetter setState) {
              if (!uploadComplete && uploadTask == null) {
                // Initialize upload task
                if (kIsWeb && file.bytes != null) {
                  uploadTask = pdfRef.putData(file.bytes!);
                } else if (file.path != null) {
                  uploadTask = pdfRef.putFile(File(file.path!));
                } else {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Upload Error'),
                      content: const Text('File not supported on this platform'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return const SizedBox.shrink(); // Return empty widget to close dialog
                }

                // Listen to upload progress
                uploadTask?.snapshotEvents.listen((TaskSnapshot snapshot) {
                  setState(() {
                    progress = snapshot.bytesTransferred / snapshot.totalBytes;
                  });
                }, onError: (e) {
                  setState(() {
                    uploadComplete = true;
                  });
                });

                uploadTask?.whenComplete(() {
                  setState(() {
                    uploadComplete = true;
                    progress = 1.0;
                  });
                });
              }

              if (uploadComplete && uploadTask != null) {
                // Handle completion
                pdfRef.getDownloadURL().then((downloadUrl) {
                  FirestoreHelper().updateFarmer(farmer.copyWith(contractPdfUrl: downloadUrl));
                  Navigator.pop(context); // Close progress dialog
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF uploaded successfully')));
                }).catchError((e) {
                  Navigator.pop(context); // Close progress dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Upload Error'),
                      content: Text('Failed to upload PDF: $e'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                });
              }

              return AlertDialog(
                title: const Text('Uploading PDF'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text('Progress: ${(progress * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              );
            },
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No file selected')));
    }
  }

  Future<void> _downloadPdf(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      // Handle error
    }
  }

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
                const SizedBox(height: 20),
                if (farmer.contractPdfUrl == null)
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _uploadPdf(context),
                      child: const Text('Upload Contract PDF'),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Contract PDF: Uploaded', style: TextStyle(color: Colors.green)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => _downloadPdf(farmer.contractPdfUrl!),
                            child: const Text('Download Contract PDF'),
                          ),
                          ElevatedButton(
                            onPressed: () => _uploadPdf(context),
                            child: const Text('Update Contract PDF'),
                          ),
                        ],
                      ),
                    ],
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
