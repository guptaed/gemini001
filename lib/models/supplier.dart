// lib/models/supplier.dart

// ignore_for_file: non_constant_identifier_names

// This is the `Supplier` model class. It represents the structure of a supplier's data
// in our application and will be used to interact with the database.
// The data for this class is now handled by Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  // `id` is now a nullable `String?` because Firestore will automatically
  // assign a unique ID when a new document is added.
  // We will need this ID to reference and update/delete a specific supplier.
  final String? id;
  final int SupId;
  final String CompanyName;
  final String Address;
  final String Tel;
  final String Email;
  final String TaxCode;
  final String Representative;
  final String Title;
  final String Status; 

  // The constructor for the `Supplier` class.
  // The `id` is optional when creating a new supplier object, as it will be null initially.
  Supplier({
    this.id,
    required this.SupId,
    required this.CompanyName,
    required this.Address,
    required this.Tel,
    required this.Email,
    required this.TaxCode,
    required this.Representative,
    required this.Title,
    required this.Status,
  });

// `copyWith` method: This method allows us to create a new `Supplier` object
// by copying the existing one and overriding specific fields.
// This is useful for updating supplier information without modifying the original object.
Supplier copyWith({
    String? id,
    int? SupId,
    String? CompanyName,
    String? Address,
    String? Tel,
    String? Email,
    String? TaxCode,
    String? Representative,
    String? Title,
    String? Status,
  }) {
    return Supplier(
      id: id ?? this.id,
      SupId: SupId ?? this.SupId,
      CompanyName: CompanyName ?? this.CompanyName,
      Address: Address ?? this.Address,
      Tel: Tel ?? this.Tel,
      Email: Email ?? this.Email,
      TaxCode: TaxCode ?? this.TaxCode,
      Representative: Representative ?? this.Representative,
      Title: Title ?? this.Title,
      Status: Status ?? this.Status,
    );
  }


  // `toMap` method: This method converts a `Supplier` object into a `Map<String, dynamic>`.
  // This format is what the Firestore SDK uses to write data to the database.
  // We exclude the `id` from this map because Firestore handles it separately.
  Map<String, dynamic> toMap() {
    return {
      'SupId': SupId,
      'CompanyName': CompanyName,
      'Address': Address,
      'Tel': Tel,
      'Email': Email,
      'TaxCode': TaxCode,
      'Representative': Representative,
      'Title': Title,
      'Status': Status,
    };
  }

  // `fromFirestore` factory constructor: This is a new factory constructor that
  // takes a `DocumentSnapshot` from Firestore and creates a new `Supplier` object from it.
  // This is how we convert data read from the database back into our model.
  factory Supplier.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    // We use a `try...catch` block to handle potential errors in case the data
    // read from Firestore is not in the expected format.
    try {
      final data = doc.data()!; // Get the data from the document snapshot.
      return Supplier(
        // The `id` is retrieved from the `doc.id` property of the snapshot.
        id: doc.id,
        SupId: data['SupId'] as int,
        CompanyName: data['CompanyName'] as String,
        Address: data['Address'] as String,
        Tel: data['Tel'] as String,
        Email: data['Email'] as String,
        TaxCode: data['TaxCode'] as String,
        Representative: data['Representative'] as String,
        Title: data['Title'] as String,
        Status: data['Status'] as String,
      );
    } catch (e) {
      // If there's an error during conversion, we print it and return a default
      // empty `Supplier` object to prevent the app from crashing.
      print('Error parsing supplier data from Firestore: $e');
      return Supplier(
        SupId: 0,
        CompanyName: '',
        Address: '',
        Tel: '',
        Email: '',
        TaxCode: '',
        Representative: '',
        Title: '',
        Status: '',
      );
    }
  }
}
