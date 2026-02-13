import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class ContractInfo {
  final String? id;
  final int SupId;
  final String ContractNo;
  final String SignedDate;
  final int ValidityYrs;
  final int MaxAutoValidity;
  final double STT1Price;
  final double STT2Price;
  final String? PdfUrlMain;
  final String? PdfUrlAppendix1;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy; // User ID who created
  final String? CreatedByName; // User display name
  final DateTime? CreatedAt; // Creation timestamp
  final String? LastModifiedBy; // User ID who last modified
  final String? LastModifiedByName; // User display name
  final DateTime? LastModifiedAt; // Last modification timestamp

  ContractInfo({
    this.id,
    required this.SupId,
    required this.ContractNo,
    required this.SignedDate,
    required this.ValidityYrs,
    required this.MaxAutoValidity,
    required this.STT1Price,
    required this.STT2Price,
    this.PdfUrlMain,
    this.PdfUrlAppendix1,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  // Note: Uses Object? pattern to distinguish between "not provided" and "provided as null"
  ContractInfo copyWith({
    Object? id = _undefined,
    int? SupId,
    String? ContractNo,
    String? SignedDate,
    int? ValidityYrs,
    int? MaxAutoValidity,
    double? STT1Price,
    double? STT2Price,
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
      STT1Price: STT1Price ?? this.STT1Price,
      STT2Price: STT2Price ?? this.STT2Price,
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
      'STT1Price': STT1Price,
      'STT2Price': STT2Price,
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
      return ContractInfo(
        id: doc.id,
        SupId: data['SupId'] as int,
        ContractNo: data['ContractNo'] as String,
        SignedDate: data['SignedDate'] as String,
        ValidityYrs: data['ValidityYrs'] as int,
        MaxAutoValidity: data['MaxAutoValidity'] as int,
        STT1Price: (data['STT1Price'] as num).toDouble(),
        STT2Price: (data['STT2Price'] as num).toDouble(),
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
        STT1Price: 0.0,
        STT2Price: 0.0,
        PdfUrlMain: null,
        PdfUrlAppendix1: null,
      );
    }
  }
}
