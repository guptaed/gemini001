import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

// Sentinel value to distinguish between "not provided" and "provided as null"
const Object _undefined = Object();

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

  // Metadata fields for tracking creation and modification
  final String? CreatedBy; // User ID who created
  final String? CreatedByName; // User display name
  final DateTime? CreatedAt; // Creation timestamp
  final String? LastModifiedBy; // User ID who last modified
  final String? LastModifiedByName; // User display name
  final DateTime? LastModifiedAt; // Last modification timestamp

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
    this.CreatedBy,
    this.CreatedByName,
    this.CreatedAt,
    this.LastModifiedBy,
    this.LastModifiedByName,
    this.LastModifiedAt,
  });

  // Note: Uses Object? pattern to distinguish between "not provided" and "provided as null"
  Bid copyWith({
    Object? id = _undefined,
    int? supId,
    int? announceId,
    int? bidId,
    String? submittedDate,
    int? quantity,
    String? status,
    int? quantityAccepted,
    String? acceptRejectDate,
    String? notes,
    Object? CreatedBy = _undefined,
    Object? CreatedByName = _undefined,
    Object? CreatedAt = _undefined,
    Object? LastModifiedBy = _undefined,
    Object? LastModifiedByName = _undefined,
    Object? LastModifiedAt = _undefined,
  }) {
    return Bid(
      id: id == _undefined ? this.id : id as String?,
      supId: supId ?? this.supId,
      announceId: announceId ?? this.announceId,
      bidId: bidId ?? this.bidId,
      submittedDate: submittedDate ?? this.submittedDate,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      quantityAccepted: quantityAccepted ?? this.quantityAccepted,
      acceptRejectDate: acceptRejectDate ?? this.acceptRejectDate,
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
      'SupId': supId,
      'AnnounceId': announceId,
      'BidId': bidId,
      'SubmittedDate': submittedDate,
      'Quantity': quantity,
      'Status': status,
      'QuantityAccepted': quantityAccepted,
      'AcceptRejectDate': acceptRejectDate,
      'Notes': notes,
      'CreatedBy': CreatedBy,
      'CreatedByName': CreatedByName,
      'CreatedAt': CreatedAt != null ? Timestamp.fromDate(CreatedAt!) : null,
      'LastModifiedBy': LastModifiedBy,
      'LastModifiedByName': LastModifiedByName,
      'LastModifiedAt': LastModifiedAt != null ? Timestamp.fromDate(LastModifiedAt!) : null,
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
        CreatedBy: data['CreatedBy'] as String?,
        CreatedByName: data['CreatedByName'] as String?,
        CreatedAt: (data['CreatedAt'] as Timestamp?)?.toDate(),
        LastModifiedBy: data['LastModifiedBy'] as String?,
        LastModifiedByName: data['LastModifiedByName'] as String?,
        LastModifiedAt: (data['LastModifiedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      logger.e('Error parsing bid data from Firestore: $e');
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
