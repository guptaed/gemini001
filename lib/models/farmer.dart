// lib/models/farmer.dart

// This is the `Farmer` model class. It represents the structure of a farmer's data
// in our application and will be used to interact with the database.
// The data for this class is now handled by Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';

class Farmer {
  // `id` is now a nullable `String?` because Firestore will automatically
  // assign a unique ID when a new document is added.
  // We will need this ID to reference and update/delete a specific farmer.
  final String? id;
  final String firstName;
  final String lastName;
  final String companyName;
  final String address;
  final String phone;
  final String email;
  final double totalFarmSize;
  final double sellingCapacityPerMonthTons;
  final double sellingCapacityPerYearTons;
  final String? contractPdfUrl; // Optional URL to the contract PDF

  // The constructor for the `Farmer` class.
  // The `id` is optional when creating a new farmer object, as it will be null initially.
  Farmer({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.companyName,
    required this.address,
    required this.phone,
    required this.email,
    required this.totalFarmSize,
    required this.sellingCapacityPerMonthTons,
    required this.sellingCapacityPerYearTons,
    this.contractPdfUrl,
  });

// `copyWith` method: This method allows us to create a new `Farmer` object
// by copying the existing one and overriding specific fields.
// This is useful for updating farmer information without modifying the original object.
Farmer copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? companyName,
    String? address,
    String? phone,
    String? email,
    double? totalFarmSize,
    double? sellingCapacityPerMonthTons,
    double? sellingCapacityPerYearTons,
    String? contractPdfUrl,
  }) {
    return Farmer(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      totalFarmSize: totalFarmSize ?? this.totalFarmSize,
      sellingCapacityPerMonthTons: sellingCapacityPerMonthTons ?? this.sellingCapacityPerMonthTons,
      sellingCapacityPerYearTons: sellingCapacityPerYearTons ?? this.sellingCapacityPerYearTons,
      contractPdfUrl: contractPdfUrl ?? this.contractPdfUrl,
    );
  }


  // `toMap` method: This method converts a `Farmer` object into a `Map<String, dynamic>`.
  // This format is what the Firestore SDK uses to write data to the database.
  // We exclude the `id` from this map because Firestore handles it separately.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'companyName': companyName,
      'address': address,
      'phone': phone,
      'email': email,
      'totalFarmSize': totalFarmSize,
      'sellingCapacityPerMonthTons': sellingCapacityPerMonthTons,
      'sellingCapacityPerYearTons': sellingCapacityPerYearTons,
      'contractPdfUrl': contractPdfUrl,
    };
  }

  // `fromFirestore` factory constructor: This is a new factory constructor that
  // takes a `DocumentSnapshot` from Firestore and creates a new `Farmer` object from it.
  // This is how we convert data read from the database back into our model.
  factory Farmer.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    // We use a `try...catch` block to handle potential errors in case the data
    // read from Firestore is not in the expected format.
    try {
      final data = doc.data()!; // Get the data from the document snapshot.
      return Farmer(
        // The `id` is retrieved from the `doc.id` property of the snapshot.
        id: doc.id,
        firstName: data['firstName'] as String,
        lastName: data['lastName'] as String,
        companyName: data['companyName'] as String,
        address: data['address'] as String,
        phone: data['phone'] as String,
        email: data['email'] as String,
        // The `totalFarmSize` and capacity fields are retrieved as doubles.
        // We use `?? 0.0` to provide a default value in case the field is null.
        totalFarmSize: (data['totalFarmSize'] as num?)?.toDouble() ?? 0.0,
        sellingCapacityPerMonthTons: (data['sellingCapacityPerMonthTons'] as num?)?.toDouble() ?? 0.0,
        sellingCapacityPerYearTons: (data['sellingCapacityPerYearTons'] as num?)?.toDouble() ?? 0.0,
        contractPdfUrl: data['contractPdfUrl'] as String?,
      );
    } catch (e) {
      // If there's an error during conversion, we print it and return a default
      // empty `Farmer` object to prevent the app from crashing.
      print('Error parsing farmer data from Firestore: $e');
      return Farmer(
        firstName: '',
        lastName: '',
        companyName: '',
        address: '',
        phone: '',
        email: '',
        totalFarmSize: 0.0,
        sellingCapacityPerMonthTons: 0.0,
        sellingCapacityPerYearTons: 0.0,
        contractPdfUrl: null,
      );
    }
  }
}
