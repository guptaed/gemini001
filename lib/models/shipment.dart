import 'package:cloud_firestore/cloud_firestore.dart';

class Shipment {
  final String? id; // Firestore document ID
  final int ShipmentId;
  final int SupId;
  final int BidId;
  final String Status;
  final String ShippedDate;
  final String ReceivedDate;
  final String Notes;

  Shipment({
    this.id,
    required this.ShipmentId,
    required this.SupId,
    required this.BidId,
    required this.Status,
    required this.ShippedDate,
    required this.ReceivedDate,
    required this.Notes,
  });

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
    };
  }
}
