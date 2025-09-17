import 'package:cloud_firestore/cloud_firestore.dart';

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
  });

  CreditCheck copyWith({
    String? id,
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
  }) {
    return CreditCheck(
      id: id ?? this.id,
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
    };
  }

  factory CreditCheck.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
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
      );
    } catch (e) {
      print('Error parsing credit check data from Firestore: $e');
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
