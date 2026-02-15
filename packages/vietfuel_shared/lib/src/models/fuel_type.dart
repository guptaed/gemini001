// lib/src/models/fuel_type.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vietfuel_shared/src/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class FuelType {
  final String? id;
  final String FuelTypeId;
  final String FuelTypeName;
  final String FuelTypeNameVi;
  final String Category;
  final String Subcategory;
  final String CertificationStatus;
  final String UnitOfMeasure;
  final String Description;
  final bool IsActive;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy;
  final String? CreatedByName;
  final DateTime? CreatedAt;
  final String? LastModifiedBy;
  final String? LastModifiedByName;
  final DateTime? LastModifiedAt;

  FuelType({
    this.id,
    required this.FuelTypeId,
    required this.FuelTypeName,
    this.FuelTypeNameVi = '',
    required this.Category,
    required this.Subcategory,
    required this.CertificationStatus,
    required this.UnitOfMeasure,
    this.Description = '',
    required this.IsActive,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  FuelType copyWith({
    Object? id = _undefined,
    String? FuelTypeId,
    String? FuelTypeName,
    String? FuelTypeNameVi,
    String? Category,
    String? Subcategory,
    String? CertificationStatus,
    String? UnitOfMeasure,
    String? Description,
    bool? IsActive,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return FuelType(
      id: id == _undefined ? this.id : id as String?,
      FuelTypeId: FuelTypeId ?? this.FuelTypeId,
      FuelTypeName: FuelTypeName ?? this.FuelTypeName,
      FuelTypeNameVi: FuelTypeNameVi ?? this.FuelTypeNameVi,
      Category: Category ?? this.Category,
      Subcategory: Subcategory ?? this.Subcategory,
      CertificationStatus: CertificationStatus ?? this.CertificationStatus,
      UnitOfMeasure: UnitOfMeasure ?? this.UnitOfMeasure,
      Description: Description ?? this.Description,
      IsActive: IsActive ?? this.IsActive,
      CreatedBy:
          CreatedBy == _undefined ? this.CreatedBy : CreatedBy as String?,
      CreatedByName: CreatedByName == _undefined
          ? this.CreatedByName
          : CreatedByName as String?,
      CreatedAt:
          CreatedAt == _undefined ? this.CreatedAt : CreatedAt as DateTime?,
      LastModifiedBy: LastModifiedBy == _undefined
          ? this.LastModifiedBy
          : LastModifiedBy as String?,
      LastModifiedByName: LastModifiedByName == _undefined
          ? this.LastModifiedByName
          : LastModifiedByName as String?,
      LastModifiedAt: LastModifiedAt == _undefined
          ? this.LastModifiedAt
          : LastModifiedAt as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'FuelTypeId': FuelTypeId,
      'FuelTypeName': FuelTypeName,
      'FuelTypeNameVi': FuelTypeNameVi,
      'Category': Category,
      'Subcategory': Subcategory,
      'CertificationStatus': CertificationStatus,
      'UnitOfMeasure': UnitOfMeasure,
      'Description': Description,
      'IsActive': IsActive,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt':
          LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
    };
  }

  factory FuelType.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return FuelType(
        id: doc.id,
        FuelTypeId: data['FuelTypeId'] as String? ?? '',
        FuelTypeName: data['FuelTypeName'] as String? ?? '',
        FuelTypeNameVi: data['FuelTypeNameVi'] as String? ?? '',
        Category: data['Category'] as String? ?? '',
        Subcategory: data['Subcategory'] as String? ?? '',
        CertificationStatus: data['CertificationStatus'] as String? ?? '',
        UnitOfMeasure: data['UnitOfMeasure'] as String? ?? '',
        Description: data['Description'] as String? ?? '',
        IsActive: data['IsActive'] as bool? ?? true,
        CreatedBy: data['CreatedBy'] as String?,
        CreatedByName: data['CreatedByName'] as String?,
        CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
        LastModifiedBy: data['LastModifiedBy'] as String?,
        LastModifiedByName: data['LastModifiedByName'] as String?,
        LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      logger.e('Error parsing fuel type from Firestore: $e');
      return FuelType(
        FuelTypeId: '',
        FuelTypeName: '',
        Category: '',
        Subcategory: '',
        CertificationStatus: '',
        UnitOfMeasure: '',
        IsActive: true,
      );
    }
  }

  @override
  String toString() => '$FuelTypeId - $FuelTypeName';
}
