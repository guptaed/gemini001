// lib/src/models/supplier.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vietfuel_shared/src/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class Supplier {
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
  final String? CreatedBy;
  final String? CreatedByName;
  final DateTime? CreatedAt;
  final String? LastModifiedBy;
  final String? LastModifiedByName;
  final DateTime? LastModifiedAt;

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

  factory Supplier.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return Supplier(
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
