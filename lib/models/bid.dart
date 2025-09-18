import 'package:cloud_firestore/cloud_firestore.dart';

class Bid {
  final String? id;
  final int supId;
  final int announceId;
  final int bidId;
  final String submittedDate;
  final int quantity;
  final String status;
  final int quantityAccepted;
  final String acceptRejectDate;
  final String notes;

  Bid({
    this.id,
    required this.supId,
    required this.announceId,
    required this.bidId,
    required this.submittedDate,
    required this.quantity,
    required this.status,
    required this.quantityAccepted,
    required this.acceptRejectDate,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'SupId': supId,
      'AnnounceId': announceId,
      'BidId': bidId,
      'SubmittedDate': submittedDate,
      'Quantity': quantity,
      'Status': status,
      'QuantityAccepted': quantityAccepted,
      'AcceptRejectDate': acceptRejectDate,
      'Notes': notes,
    };
  }

  factory Bid.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return Bid(
        id: doc.id,
        supId: data['SupId'] as int,
        announceId: data['AnnounceId'] as int,
        bidId: data['BidId'] as int,
        submittedDate: data['SubmittedDate'] as String,
        quantity: data['Quantity'] as int,
        status: data['Status'] as String,
        quantityAccepted: data['QuantityAccepted'] as int,
        acceptRejectDate: data['AcceptRejectDate'] as String,
        notes: data['Notes'] as String,
      );
    } catch (e) {
      print('Error parsing bid data from Firestore: $e');
      return Bid(
        supId: 0,
        announceId: 0,
        bidId: 0,
        submittedDate: '',
        quantity: 0,
        status: '',
        quantityAccepted: 0,
        acceptRejectDate: '',
        notes: '',
      );
    }
  }
}
