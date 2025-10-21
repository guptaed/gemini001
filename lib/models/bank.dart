import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

class BankDetails {
  final int SupId;
  final String PaymentMethodId;
  final String BankName;
  final String BranchName;
  final String BankId;
  final String BranchId;
  final String AccountName;
  final String AccountNumber;
  final bool PreferredBank;

  BankDetails({
    required this.SupId,
    required this.PaymentMethodId,
    required this.BankName,
    required this.BranchName,
    required this.BankId,
    required this.BranchId,
    required this.AccountName,
    required this.AccountNumber,
    required this.PreferredBank,
  });

  Map<String, dynamic> toMap() {
    return {
      'SupId': SupId,
      'PaymentMethodId': PaymentMethodId,
      'BankName': BankName,
      'BranchName': BranchName,
      'BankId': BankId,
      'BranchId': BranchId,
      'AccountName': AccountName,
      'AccountNumber': AccountNumber,
      'PreferredBank': PreferredBank,
    };
  }

  factory BankDetails.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return BankDetails(
        SupId: data['SupId'] as int,
        PaymentMethodId: data['PaymentMethodId'] as String,
        BankName: data['BankName'] as String,
        BranchName: data['BranchName'] as String,
        BankId: data['BankId'] as String,
        BranchId: data['BranchId'] as String,
        AccountName: data['AccountName'] as String,
        AccountNumber: data['AccountNumber'] as String,
        PreferredBank: data['PreferredBank'] as bool,
      );
    } catch (e) {
      logger.e('Error parsing bank details from Firestore: $e');
      return BankDetails(
        SupId: 0,
        PaymentMethodId: '',
        BankName: '',
        BranchName: '',
        BankId: '',
        BranchId: '',
        AccountName: '',
        AccountNumber: '',
        PreferredBank: false,
      );
    }
  }
}
