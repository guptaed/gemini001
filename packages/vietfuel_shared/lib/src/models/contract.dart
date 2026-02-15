// lib/src/models/contract.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vietfuel_shared/src/models/contract_fuel_type.dart';
import 'package:vietfuel_shared/src/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class ContractInfo {
  final String? id;
  final int SupId;
  final String ContractNo;
  final String SignedDate;
  final int ValidityYrs;
  final int MaxAutoValidity;
  final List<ContractFuelType> ContractedFuelTypes;
  final List<String> ContractedFuelTypeIds; // Flat list for Firestore arrayContains queries
  final String? PdfUrlMain;
  final String? PdfUrlAppendix1;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy;
  final String? CreatedByName;
  final DateTime? CreatedAt;
  final String? LastModifiedBy;
  final String? LastModifiedByName;
  final DateTime? LastModifiedAt;

  ContractInfo({
    this.id,
    required this.SupId,
    required this.ContractNo,
    required this.SignedDate,
    required this.ValidityYrs,
    required this.MaxAutoValidity,
    this.ContractedFuelTypes = const [],
    this.ContractedFuelTypeIds = const [],
    this.PdfUrlMain,
    this.PdfUrlAppendix1,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  ContractInfo copyWith({
    Object? id = _undefined,
    int? SupId,
    String? ContractNo,
    String? SignedDate,
    int? ValidityYrs,
    int? MaxAutoValidity,
    List<ContractFuelType>? ContractedFuelTypes,
    List<String>? ContractedFuelTypeIds,
    Object? PdfUrlMain = _undefined,
    Object? PdfUrlAppendix1 = _undefined,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return ContractInfo(
      id: id == _undefined ? this.id : id as String?,
      SupId: SupId ?? this.SupId,
      ContractNo: ContractNo ?? this.ContractNo,
      SignedDate: SignedDate ?? this.SignedDate,
      ValidityYrs: ValidityYrs ?? this.ValidityYrs,
      MaxAutoValidity: MaxAutoValidity ?? this.MaxAutoValidity,
      ContractedFuelTypes: ContractedFuelTypes ?? this.ContractedFuelTypes,
      ContractedFuelTypeIds: ContractedFuelTypeIds ?? this.ContractedFuelTypeIds,
      PdfUrlMain:
          PdfUrlMain == _undefined ? this.PdfUrlMain : PdfUrlMain as String?,
      PdfUrlAppendix1: PdfUrlAppendix1 == _undefined
          ? this.PdfUrlAppendix1
          : PdfUrlAppendix1 as String?,
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
      'SupId': SupId,
      'ContractNo': ContractNo,
      'SignedDate': SignedDate,
      'ValidityYrs': ValidityYrs,
      'MaxAutoValidity': MaxAutoValidity,
      'ContractedFuelTypes': ContractedFuelTypes.map((ft) => ft.toMap()).toList(),
      'ContractedFuelTypeIds': ContractedFuelTypeIds,
      'PdfUrlMain': PdfUrlMain,
      'PdfUrlAppendix1': PdfUrlAppendix1,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt':
          LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
    };
  }

  factory ContractInfo.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;

      // Parse ContractedFuelTypes from embedded array
      final fuelTypesRaw = data['ContractedFuelTypes'] as List<dynamic>? ?? [];
      final contractedFuelTypes = fuelTypesRaw
          .map((item) => ContractFuelType.fromMap(item as Map<String, dynamic>))
          .toList();

      // Parse ContractedFuelTypeIds
      final fuelTypeIdsRaw = data['ContractedFuelTypeIds'] as List<dynamic>? ?? [];
      final contractedFuelTypeIds = fuelTypeIdsRaw.cast<String>().toList();

      return ContractInfo(
        id: doc.id,
        SupId: data['SupId'] as int,
        ContractNo: data['ContractNo'] as String,
        SignedDate: data['SignedDate'] as String,
        ValidityYrs: data['ValidityYrs'] as int,
        MaxAutoValidity: data['MaxAutoValidity'] as int,
        ContractedFuelTypes: contractedFuelTypes,
        ContractedFuelTypeIds: contractedFuelTypeIds,
        PdfUrlMain: data['PdfUrlMain'] as String?,
        PdfUrlAppendix1: data['PdfUrlAppendix1'] as String?,
        CreatedBy: data['CreatedBy'] as String?,
        CreatedByName: data['CreatedByName'] as String?,
        CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
        LastModifiedBy: data['LastModifiedBy'] as String?,
        LastModifiedByName: data['LastModifiedByName'] as String?,
        LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      logger.e('Error parsing contract info from Firestore: $e');
      return ContractInfo(
        SupId: 0,
        ContractNo: '',
        SignedDate: '',
        ValidityYrs: 0,
        MaxAutoValidity: 0,
        PdfUrlMain: null,
        PdfUrlAppendix1: null,
      );
    }
  }
}
