// lib/src/models/announcement.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vietfuel_shared/src/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

class Announcement {
  final String? id;
  final int announceId;
  final String announceDate;
  final String bidCloseDate;
  final String deliveryDate;
  final String fuelTypeId; // References FuelTypes master (e.g. "WC-NC-001")
  final String fuelType; // Denormalized display name (e.g. "Wood Chips (Non-Certified)")
  final int quantity;
  final double price;
  final String status;
  final String notes;

  // Metadata fields for tracking creation and modification
  final String? CreatedBy;
  final String? CreatedByName;
  final DateTime? CreatedAt;
  final String? LastModifiedBy;
  final String? LastModifiedByName;
  final DateTime? LastModifiedAt;

  Announcement({
    this.id,
    required this.announceId,
    required this.announceDate,
    required this.bidCloseDate,
    required this.deliveryDate,
    this.fuelTypeId = '',
    required this.fuelType,
    required this.quantity,
    required this.price,
    required this.status,
    required this.notes,
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  Announcement copyWith({
    Object? id = _undefined,
    int? announceId,
    String? announceDate,
    String? bidCloseDate,
    String? deliveryDate,
    String? fuelTypeId,
    String? fuelType,
    int? quantity,
    double? price,
    String? status,
    String? notes,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return Announcement(
      id: id == _undefined ? this.id : id as String?,
      announceId: announceId ?? this.announceId,
      announceDate: announceDate ?? this.announceDate,
      bidCloseDate: bidCloseDate ?? this.bidCloseDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      fuelTypeId: fuelTypeId ?? this.fuelTypeId,
      fuelType: fuelType ?? this.fuelType,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      CreatedBy: CreatedBy == _undefined ? this.CreatedBy : CreatedBy as String?,
      CreatedByName: CreatedByName == _undefined ? this.CreatedByName : CreatedByName as String?,
      CreatedAt: CreatedAt == _undefined ? this.CreatedAt : CreatedAt as DateTime?,
      LastModifiedBy: LastModifiedBy == _undefined ? this.LastModifiedBy : LastModifiedBy as String?,
      LastModifiedByName: LastModifiedByName == _undefined ? this.LastModifiedByName : LastModifiedByName as String?,
      LastModifiedAt: LastModifiedAt == _undefined ? this.LastModifiedAt : LastModifiedAt as DateTime?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'AnnounceId': announceId,
      'AnnounceDate': announceDate,
      'BidCloseDate': bidCloseDate,
      'DeliveryDate': deliveryDate,
      'FuelTypeId': fuelTypeId,
      'FuelType': fuelType,
      'Quantity': quantity,
      'Price': price,
      'Status': status,
      'Notes': notes,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt': LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
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
        fuelTypeId: data['FuelTypeId'] as String? ?? '',
        fuelType: data['FuelType'] as String,
        quantity: data['Quantity'] as int,
        price: (data['Price'] as num).toDouble(),
        status: data['Status'] as String,
        notes: data['Notes'] as String,
        CreatedBy: data['CreatedBy'] as String?,
        CreatedByName: data['CreatedByName'] as String?,
        CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
        LastModifiedBy: data['LastModifiedBy'] as String?,
        LastModifiedByName: data['LastModifiedByName'] as String?,
        LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
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
