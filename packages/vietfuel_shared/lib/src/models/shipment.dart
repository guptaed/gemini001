// lib/src/models/shipment.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class Shipment {
  final String? id;
  final int ShipmentId;
  final int SupId;
  final int BidId;
  final String Status;
  final String ShippedDate;
  final String ReceivedDate;
  final String Notes;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy;
  final String? CreatedByName;
  final DateTime? CreatedAt;
  final String? LastModifiedBy;
  final String? LastModifiedByName;
  final DateTime? LastModifiedAt;

  Shipment({
    this.id,
    required this.ShipmentId,
    required this.SupId,
    required this.BidId,
    required this.Status,
    required this.ShippedDate,
    required this.ReceivedDate,
    required this.Notes,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  Shipment copyWith({
    Object? id = _undefined,
    int? ShipmentId,
    int? SupId,
    int? BidId,
    String? Status,
    String? ShippedDate,
    String? ReceivedDate,
    String? Notes,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return Shipment(
      id: id == _undefined ? this.id : id as String?,
      ShipmentId: ShipmentId ?? this.ShipmentId,
      SupId: SupId ?? this.SupId,
      BidId: BidId ?? this.BidId,
      Status: Status ?? this.Status,
      ShippedDate: ShippedDate ?? this.ShippedDate,
      ReceivedDate: ReceivedDate ?? this.ReceivedDate,
      Notes: Notes ?? this.Notes,
      CreatedBy: CreatedBy == _undefined ? this.CreatedBy : CreatedBy as String?,
      CreatedByName: CreatedByName == _undefined ? this.CreatedByName : CreatedByName as String?,
      CreatedAt: CreatedAt == _undefined ? this.CreatedAt : CreatedAt as DateTime?,
      LastModifiedBy: LastModifiedBy == _undefined ? this.LastModifiedBy : LastModifiedBy as String?,
      LastModifiedByName: LastModifiedByName == _undefined ? this.LastModifiedByName : LastModifiedByName as String?,
      LastModifiedAt: LastModifiedAt == _undefined ? this.LastModifiedAt : LastModifiedAt as DateTime?,
    );
  }

  factory Shipment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Shipment(
      id: doc.id,
      ShipmentId: data['ShipmentId'] ?? 0,
      SupId: data['SupId'] ?? 0,
      BidId: data['BidId'] ?? 0,
      Status: data['Status'] ?? '',
      ShippedDate: data['ShippedDate'] ?? '',
      ReceivedDate: data['ReceivedDate'] ?? '',
      Notes: data['Notes'] ?? '',
      CreatedBy: data['CreatedBy'] as String?,
      CreatedByName: data['CreatedByName'] as String?,
      CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
      LastModifiedBy: data['LastModifiedBy'] as String?,
      LastModifiedByName: data['LastModifiedByName'] as String?,
      LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ShipmentId': ShipmentId,
      'SupId': SupId,
      'BidId': BidId,
      'Status': Status,
      'ShippedDate': ShippedDate,
      'ReceivedDate': ReceivedDate,
      'Notes': Notes,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt': LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
    };
  }
}
