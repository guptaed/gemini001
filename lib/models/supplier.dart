// lib/models/supplier.dart

// ignore_for_file: non_constant_identifier_names

// This is the `Supplier` model class. It represents the structure of a supplier's data
// in our application and will be used to interact with the database.
// The data for this class is now handled by Firestore.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

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
  final String? SupportingPDF1;
  final String? SupportingPDF2;
  final String? SupportingPDF3;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy; // User ID who created
  final String? CreatedByName; // User display name
  final DateTime? CreatedAt; // Creation timestamp
  final String? LastModifiedBy; // User ID who last modified
  final String? LastModifiedByName; // User display name
  final DateTime? LastModifiedAt; // Last modification timestamp

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
    this.SupportingPDF1,
    this.SupportingPDF2,
    this.SupportingPDF3,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  // `copyWith` method: This method allows us to create a new `Supplier` object
  // by copying the existing one and overriding specific fields.
  // This is useful for updating supplier information without modifying the original object.
  // Note: Uses Object? pattern to distinguish between "not provided" and "provided as null"
  Supplier copyWith({
    Object? id = _undefined,
    Object? SupId = _undefined,
    Object? CompanyName = _undefined,
    Object? Address = _undefined,
    Object? Tel = _undefined,
    Object? Email = _undefined,
    Object? TaxCode = _undefined,
    Object? Representative = _undefined,
    Object? Title = _undefined,
    Object? Status = _undefined,
    Object? SupportingPDF1 = _undefined,
    Object? SupportingPDF2 = _undefined,
    Object? SupportingPDF3 = _undefined,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return Supplier(
      id: id == _undefined ? this.id : id as String?,
      SupId: SupId == _undefined ? this.SupId : SupId as int,
      CompanyName: CompanyName == _undefined ? this.CompanyName : CompanyName as String,
      Address: Address == _undefined ? this.Address : Address as String,
      Tel: Tel == _undefined ? this.Tel : Tel as String,
      Email: Email == _undefined ? this.Email : Email as String,
      TaxCode: TaxCode == _undefined ? this.TaxCode : TaxCode as String,
      Representative: Representative == _undefined ? this.Representative : Representative as String,
      Title: Title == _undefined ? this.Title : Title as String,
      Status: Status == _undefined ? this.Status : Status as String,
      SupportingPDF1: SupportingPDF1 == _undefined ? this.SupportingPDF1 : SupportingPDF1 as String?,
      SupportingPDF2: SupportingPDF2 == _undefined ? this.SupportingPDF2 : SupportingPDF2 as String?,
      SupportingPDF3: SupportingPDF3 == _undefined ? this.SupportingPDF3 : SupportingPDF3 as String?,
      CreatedBy: CreatedBy == _undefined ? this.CreatedBy : CreatedBy as String?,
      CreatedByName: CreatedByName == _undefined ? this.CreatedByName : CreatedByName as String?,
      CreatedAt: CreatedAt == _undefined ? this.CreatedAt : CreatedAt as DateTime?,
      LastModifiedBy: LastModifiedBy == _undefined ? this.LastModifiedBy : LastModifiedBy as String?,
      LastModifiedByName: LastModifiedByName == _undefined ? this.LastModifiedByName : LastModifiedByName as String?,
      LastModifiedAt: LastModifiedAt == _undefined ? this.LastModifiedAt : LastModifiedAt as DateTime?,
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
      'SupportingPDF1': SupportingPDF1,
      'SupportingPDF2': SupportingPDF2,
      'SupportingPDF3': SupportingPDF3,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt': LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
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
        SupportingPDF1: data['SupportingPDF1'] as String?,
        SupportingPDF2: data['SupportingPDF2'] as String?,
        SupportingPDF3: data['SupportingPDF3'] as String?,
        CreatedBy: data['CreatedBy'] as String?,
        CreatedByName: data['CreatedByName'] as String?,
        CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
        LastModifiedBy: data['LastModifiedBy'] as String?,
        LastModifiedByName: data['LastModifiedByName'] as String?,
        LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      // If there's an error during conversion, we print it and return a default
      // empty `Supplier` object to prevent the app from crashing.
      logger.e('Error parsing supplier data from Firestore: $e');
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
