import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class BankDetails {
  final String? id;
  final int SupId;
  final String PaymentMethodId;
  final String BankName;
  final String BranchName;
  final String BankId;
  final String BranchId;
  final String AccountName;
  final String AccountNumber;
  final bool PreferredBank;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy; // User ID who created
  final String? CreatedByName; // User display name
  final DateTime? CreatedAt; // Creation timestamp
  final String? LastModifiedBy; // User ID who last modified
  final String? LastModifiedByName; // User display name
  final DateTime? LastModifiedAt; // Last modification timestamp

  BankDetails({
    this.id,
    required this.SupId,
    required this.PaymentMethodId,
    required this.BankName,
    required this.BranchName,
    required this.BankId,
    required this.BranchId,
    required this.AccountName,
    required this.AccountNumber,
    required this.PreferredBank,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  // Note: Uses Object? pattern to distinguish between "not provided" and "provided as null"
  BankDetails copyWith({
    Object? id = _undefined,
    int? SupId,
    String? PaymentMethodId,
    String? BankName,
    String? BranchName,
    String? BankId,
    String? BranchId,
    String? AccountName,
    String? AccountNumber,
    bool? PreferredBank,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return BankDetails(
      id: id == _undefined ? this.id : id as String?,
      SupId: SupId ?? this.SupId,
      PaymentMethodId: PaymentMethodId ?? this.PaymentMethodId,
      BankName: BankName ?? this.BankName,
      BranchName: BranchName ?? this.BranchName,
      BankId: BankId ?? this.BankId,
      BranchId: BranchId ?? this.BranchId,
      AccountName: AccountName ?? this.AccountName,
      AccountNumber: AccountNumber ?? this.AccountNumber,
      PreferredBank: PreferredBank ?? this.PreferredBank,
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
      'PaymentMethodId': PaymentMethodId,
      'BankName': BankName,
      'BranchName': BranchName,
      'BankId': BankId,
      'BranchId': BranchId,
      'AccountName': AccountName,
      'AccountNumber': AccountNumber,
      'PreferredBank': PreferredBank,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt':
          LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
    };
  }

  factory BankDetails.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return BankDetails(
        id: doc.id,
        SupId: data['SupId'] as int,
        PaymentMethodId: data['PaymentMethodId'] as String,
        BankName: data['BankName'] as String,
        BranchName: data['BranchName'] as String,
        BankId: data['BankId'] as String,
        BranchId: data['BranchId'] as String,
        AccountName: data['AccountName'] as String,
        AccountNumber: data['AccountNumber'] as String,
        PreferredBank: data['PreferredBank'] as bool,
        CreatedBy: data['CreatedBy'] as String?,
        CreatedByName: data['CreatedByName'] as String?,
        CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
        LastModifiedBy: data['LastModifiedBy'] as String?,
        LastModifiedByName: data['LastModifiedByName'] as String?,
        LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
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
