import 'package:cloud_firestore/cloud_firestore.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class Shipment {
  final String? id; // Firestore document ID
  final int ShipmentId;
  final int SupId;
  final int BidId;
  final String Status;
  final String ShippedDate;
  final String ReceivedDate;
  final String Notes;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy; // User ID who created
  final String? CreatedByName; // User display name
  final DateTime? CreatedAt; // Creation timestamp
  final String? LastModifiedBy; // User ID who last modified
  final String? LastModifiedByName; // User display name
  final DateTime? LastModifiedAt; // Last modification timestamp

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

  // Note: Uses Object? pattern to distinguish between "not provided" and "provided as null"
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

  // Convert Firestore document to Shipment object
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

  // Convert Shipment object to Firestore map
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
