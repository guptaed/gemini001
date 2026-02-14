// lib/src/models/credit_check.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vietfuel_shared/src/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class CreditCheck {
  final String? id;
  final int supId;
  final String status;
  final String establishedDate;
  final int supplyCapacity;
  final String trackRecord;
  final String rawMaterialTypes;
  final String checkStartDate;
  final String checkFinishDate;
  final String checkCompany;
  final String pdfUrlPhotoERC;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy;
  final String? CreatedByName;
  final DateTime? CreatedAt;
  final String? LastModifiedBy;
  final String? LastModifiedByName;
  final DateTime? LastModifiedAt;

  CreditCheck({
    this.id,
    required this.supId,
    required this.status,
    required this.establishedDate,
    required this.supplyCapacity,
    required this.trackRecord,
    required this.rawMaterialTypes,
    required this.checkStartDate,
    required this.checkFinishDate,
    required this.checkCompany,
    required this.pdfUrlPhotoERC,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  CreditCheck copyWith({
    Object? id = _undefined,
    int? supId,
    String? status,
    String? establishedDate,
    int? supplyCapacity,
    String? trackRecord,
    String? rawMaterialTypes,
    String? checkStartDate,
    String? checkFinishDate,
    String? checkCompany,
    String? pdfUrlPhotoERC,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return CreditCheck(
      id: id == _undefined ? this.id : id as String?,
      supId: supId ?? this.supId,
      status: status ?? this.status,
      establishedDate: establishedDate ?? this.establishedDate,
      supplyCapacity: supplyCapacity ?? this.supplyCapacity,
      trackRecord: trackRecord ?? this.trackRecord,
      rawMaterialTypes: rawMaterialTypes ?? this.rawMaterialTypes,
      checkStartDate: checkStartDate ?? this.checkStartDate,
      checkFinishDate: checkFinishDate ?? this.checkFinishDate,
      checkCompany: checkCompany ?? this.checkCompany,
      pdfUrlPhotoERC: pdfUrlPhotoERC ?? this.pdfUrlPhotoERC,
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
      'SupId': supId,
      'Status': status,
      'EstablishedDate': establishedDate,
      'SupplyCapacity': supplyCapacity,
      'TrackRecord': trackRecord,
      'RawMaterialTypes': rawMaterialTypes,
      'CheckStartDate': checkStartDate,
      'CheckFinishDate': checkFinishDate,
      'CheckCompany': checkCompany,
      'PdfUrlPhotoERC': pdfUrlPhotoERC,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt': LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
    };
  }

  factory CreditCheck.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return CreditCheck(
        id: doc.id,
        supId: data['SupId'] as int,
        status: data['Status'] as String,
        establishedDate: data['EstablishedDate'] as String,
        supplyCapacity: data['SupplyCapacity'] as int,
        trackRecord: data['TrackRecord'] as String,
        rawMaterialTypes: data['RawMaterialTypes'] as String,
        checkStartDate: data['CheckStartDate'] as String,
        checkFinishDate: data['CheckFinishDate'] as String,
        checkCompany: data['CheckCompany'] as String,
        pdfUrlPhotoERC: data['PdfUrlPhotoERC'] as String,
        CreatedBy: data['CreatedBy'] as String?,
        CreatedByName: data['CreatedByName'] as String?,
        CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
        LastModifiedBy: data['LastModifiedBy'] as String?,
        LastModifiedByName: data['LastModifiedByName'] as String?,
        LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      logger.e('Error parsing credit check data from Firestore: $e');
      return CreditCheck(
        supId: 0,
        status: '',
        establishedDate: '',
        supplyCapacity: 0,
        trackRecord: '',
        rawMaterialTypes: '',
        checkStartDate: '',
        checkFinishDate: '',
        checkCompany: '',
        pdfUrlPhotoERC: '',
      );
    }
  }
}
