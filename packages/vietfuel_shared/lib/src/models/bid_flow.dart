// lib/src/models/bid_flow.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

class BidFlow {
  final int supplierId;
  final int announceId;
  final int bidId;
  final int? shipmentId;
  final int? qaId;
  final int? paymentId;
  final String? currentStage;
  final String? currentStageStatus;

  BidFlow({
    required this.supplierId,
    required this.announceId,
    required this.bidId,
    this.shipmentId,
    this.qaId,
    this.paymentId,
    this.currentStage,
    this.currentStageStatus,
  });

  factory BidFlow.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BidFlow(
      supplierId: data['SupId'] ?? 0,
      announceId: data['AnnounceId'] ?? 0,
      bidId: data['BidId'] ?? 0,
      shipmentId: data['ShipmentId'],
      qaId: data['QAId'],
      paymentId: data['PaymentId'],
      currentStage: data['CurrentStage'],
      currentStageStatus: data['CurrentStageStatus'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'SupId': supplierId,
      'AnnounceId': announceId,
      'BidId': bidId,
      'ShipmentId': shipmentId,
      'QAId': qaId,
      'PaymentId': paymentId,
      'CurrentStage': currentStage,
      'CurrentStageStatus': currentStageStatus,
    };
  }
}
