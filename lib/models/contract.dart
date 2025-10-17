import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

class ContractInfo {
  final int SupId;
  final String ContractNo;
  final String SignedDate;
  final int ValidityYrs;
  final int MaxAutoValidity;
  final double STT1Price;
  final double STT2Price;
  final String? PdfUrlMain;
  final String? PdfUrlAppendix1;

  ContractInfo({
    required this.SupId,
    required this.ContractNo,
    required this.SignedDate,
    required this.ValidityYrs,
    required this.MaxAutoValidity,
    required this.STT1Price,
    required this.STT2Price,
    this.PdfUrlMain,
    this.PdfUrlAppendix1,
  });

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
    };
  } 

  factory ContractInfo.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return ContractInfo(
        SupId: data['SupId'] as int,
        ContractNo: data['ContractNo'] as String,
        SignedDate: data['SignedDate'] as String,
        ValidityYrs: data['ValidityYrs'] as int,
        MaxAutoValidity: data['MaxAutoValidity'] as int,
        STT1Price: (data['STT1Price'] as num).toDouble(),
        STT2Price: (data['STT2Price'] as num).toDouble(),
        PdfUrlMain: data['PdfUrlMain'] as String?,
        PdfUrlAppendix1: data['PdfUrlAppendix1'] as String?,
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

