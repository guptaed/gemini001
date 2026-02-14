import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:gemini001/utils/logging.dart';

// StorageHelper is a helper class for Firebase Storage operations
// It handles uploading PDFs to Firebase Storage with proper error handling

class StorageHelper {
  static final StorageHelper _instance = StorageHelper._internal();
  factory StorageHelper() {
    return _instance;
  }

  StorageHelper._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a PDF file to Firebase Storage
  // Returns the filename on success, null on failure
  // Uses bytes to support both web and mobile platforms
  Future<String?> uploadPDF({
    required Uint8List fileBytes,
    required String fileName,
    required int supplierId,
    required int fieldNumber,
  }) async {
    try {
      // Validate file size (10 MB = 10 * 1024 * 1024 bytes)
      final fileSize = fileBytes.length;
      const maxSize = 10 * 1024 * 1024; // 10 MB

      if (fileSize > maxSize) {
        logger.w('File size $fileSize bytes exceeds limit of $maxSize bytes');
        throw Exception('File size exceeds 10 MB limit');
      }

      // Create the storage path: Supplier/{SupplierID}/filename.pdf
      final storageRef = _storage.ref().child('Supplier/$supplierId/$fileName');

      // Upload the file using bytes (works on both web and mobile)
      logger.i('Uploading PDF to: Supplier/$supplierId/$fileName');
      final uploadTask = await storageRef.putData(fileBytes);

      // Check if upload was successful
      if (uploadTask.state == TaskState.success) {
        logger.i('Successfully uploaded PDF: $fileName');
        return fileName;
      } else {
        logger.e('Upload failed with state: ${uploadTask.state}');
        return null;
      }
    } on FirebaseException catch (e) {
      logger.e('Firebase Storage error uploading PDF: ${e.message}', e);
      rethrow;
    } catch (e) {
      logger.e('Error uploading PDF: $e', e);
      rethrow;
    }
  }

  // Delete a PDF file from Firebase Storage
  Future<void> deletePDF({
    required int supplierId,
    required String fileName,
  }) async {
    try {
      final storageRef = _storage.ref().child('Supplier/$supplierId/$fileName');
      await storageRef.delete();
      logger.i('Successfully deleted PDF: $fileName');
    } on FirebaseException catch (e) {
      logger.e('Firebase Storage error deleting PDF: ${e.message}', e);
      rethrow;
    } catch (e) {
      logger.e('Error deleting PDF: $e', e);
      rethrow;
    }
  }

  // Get download URL for a PDF file
  Future<String?> getPDFDownloadUrl({
    required int supplierId,
    required String fileName,
  }) async {
    try {
      final storageRef = _storage.ref().child('Supplier/$supplierId/$fileName');
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } on FirebaseException catch (e) {
      logger.e('Firebase Storage error getting download URL: ${e.message}', e);
      return null;
    } catch (e) {
      logger.e('Error getting download URL: $e', e);
      return null;
    }
  }
}
