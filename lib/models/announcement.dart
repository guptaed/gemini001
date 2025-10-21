import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

class Announcement {
  final String? id;
  final int announceId;
  final String announceDate;
  final String bidCloseDate;
  final String deliveryDate;
  final String fuelType;
  final int quantity;
  final double price;
  final String status;
  final String notes;

  Announcement({
    this.id,
    required this.announceId,
    required this.announceDate,
    required this.bidCloseDate,
    required this.deliveryDate,
    required this.fuelType,
    required this.quantity,
    required this.price,
    required this.status,
    required this.notes,
  });

  Announcement copyWith({
    String? id,
    int? announceId,
    String? announceDate,
    String? bidCloseDate,
    String? deliveryDate,
    String? fuelType,
    int? quantity,
    double? price,
    String? status,
    String? notes,
  }) {
    return Announcement(
      id: id ?? this.id,
      announceId: announceId ?? this.announceId,
      announceDate: announceDate ?? this.announceDate,
      bidCloseDate: bidCloseDate ?? this.bidCloseDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      fuelType: fuelType ?? this.fuelType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'AnnounceId': announceId,
      'AnnounceDate': announceDate,
      'BidCloseDate': bidCloseDate,
      'DeliveryDate': deliveryDate,
      'FuelType': fuelType,
      'Quantity': quantity,
      'Price': price,
      'Status': status,
      'Notes': notes,
    };
  }

  factory Announcement.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;
      return Announcement(
        id: doc.id,
        announceId: data['AnnounceId'] as int,
        announceDate: data['AnnounceDate'] as String,
        bidCloseDate: data['BidCloseDate'] as String,
        deliveryDate: data['DeliveryDate'] as String,
        fuelType: data['FuelType'] as String,
        quantity: data['Quantity'] as int,
        price: (data['Price'] as num).toDouble(),
        status: data['Status'] as String,
        notes: data['Notes'] as String,
      );
    } catch (e) {
      logger.e('Error parsing announcement data from Firestore: $e');
      return Announcement(
        announceId: 0,
        announceDate: '',
        bidCloseDate: '',
        deliveryDate: '',
        fuelType: '',
        quantity: 0,
        price: 0.0,
        status: '',
        notes: '',
      );
    }
  }
}
