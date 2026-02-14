import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gemini001/utils/logging.dart';

const String jsonFilePath = '../data/Suppliers.json';

Future<void> main() async {
  try {
    // Minimal Firebase initialization for Firestore
    await Firebase.initializeApp(
      options: FirebaseOptions(
        appId: '1:490924808031:web:c3276a58bb7458decac8ea',
        apiKey: 'AIzaSyCgNNxTCWmAuygURSFYpOzbdz9ZfEOP-LI',
        projectId: 'vietfuelprocapp',
        messagingSenderId: '490924808031',
        authDomain: 'vietfuelprocapp.firebaseapp.com',
        storageBucket: 'vietfuelprocapp.appspot.com',
      ),
    );

    final firestore = FirebaseFirestore.instance;

    // Read the JSON file
    final file = File(jsonFilePath);
    if (!await file.exists()) {
      logger.e('Error: $jsonFilePath not found. Please check the path.');
      return;
    }

    final jsonString = await file.readAsString();
    final data = jsonDecode(jsonString)['Suppliers'] as List;

    if (data.isEmpty) {
      logger.e('Error: No "Suppliers" array found in the JSON file.');
      return;
    }

    // Upload each supplier to Firestore
    int importedCount = 0;
    const batchSize = 500;
    WriteBatch batch = firestore.batch();

    for (var supplier in data) {
      final supId = supplier['SupId'] as String?;
      if (supId == null) {
        logger.e('Warning: Skipping supplier due to missing SupId: $supplier');
        continue;
      }

      final docRef = firestore.collection('suppliers').doc(supId);
      batch.set(docRef, supplier);
      importedCount++;

      if (importedCount % batchSize == 0) {
        await batch.commit();
        logger.e('Committed batch of $importedCount suppliers...');
        batch = firestore.batch();
      }
    }

    if (importedCount % batchSize != 0) {
      await batch.commit();
      logger.e(
          'Committed final batch of ${importedCount % batchSize} suppliers...');
    }

    logger.e('Upload completed! Total suppliers processed: $importedCount');
    logger.e(
        'Verify the data in the Firebase Console under the "suppliers" collection.');
  } catch (e) {
    logger.e('An error occurred: $e');
  }
}
