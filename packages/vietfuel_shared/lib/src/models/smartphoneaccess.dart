// lib/src/models/smartphoneaccess.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vietfuel_shared/src/utils/logging.dart';

class SmartphoneAccess {
  final String? id;
  final int supId;
  final String loginName;
  final String password;
  final String status;
  final String statusDate;

  SmartphoneAccess({
    this.id,
    required this.supId,
    required this.loginName,
    required this.password,
    required this.status,
    required this.statusDate,
  });

  SmartphoneAccess copyWith({
    String? id,
    int? supId,
    String? loginName,
    String? password,
    String? status,
    String? statusDate,
  }) {
    return SmartphoneAccess(
      id: id ?? this.id,
      supId: supId ?? this.supId,
      loginName: loginName ?? this.loginName,
      password: password ?? this.password,
      status: status ?? this.status,
      statusDate: statusDate ?? this.statusDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'SupId': supId,
      'LoginName': loginName,
      'Password': password,
      'Status': status,
      'StatusDate': statusDate,
    };
  }

  factory SmartphoneAccess.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return SmartphoneAccess(
        id: doc.id,
        supId: data['SupId'] as int,
        loginName: data['LoginName'] as String,
        password: data['Password'] as String,
        status: data['Status'] as String,
        statusDate: data['StatusDate'] as String,
      );
    } catch (e) {
      logger.e('Error parsing smartphone access data from Firestore: $e');
      return SmartphoneAccess(
        supId: 0,
        loginName: '',
        password: '',
        status: '',
        statusDate: '',
      );
    }
  }
}
