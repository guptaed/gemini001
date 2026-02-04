// lib/models/supplier_history.dart

// ignore_for_file: non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gemini001/utils/logging.dart';

// FieldChange represents a single field modification
class FieldChange {
  final String fieldName;   // Internal field name (e.g., "Address")
  final String fieldLabel;  // Display name (e.g., "Address")
  final String oldValue;    // Previous value (stored as string for simplicity)
  final String newValue;    // New value (stored as string for simplicity)

  FieldChange({
    required this.fieldName,
    required this.fieldLabel,
    required this.oldValue,
    required this.newValue,
  });

  // Convert FieldChange to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'fieldName': fieldName,
      'fieldLabel': fieldLabel,
      'oldValue': oldValue,
      'newValue': newValue,
    };
  }

  // Create FieldChange from Map
  factory FieldChange.fromMap(Map<String, dynamic> map) {
    return FieldChange(
      fieldName: map['fieldName'] as String,
      fieldLabel: map['fieldLabel'] as String,
      oldValue: map['oldValue'] as String,
      newValue: map['newValue'] as String,
    );
  }

  @override
  String toString() {
    return '$fieldLabel: "$oldValue" → "$newValue"';
  }
}

// SupplierHistory represents a historical record of supplier changes
class SupplierHistory {
  final String? id;              // Firestore document ID
  final int supId;               // Supplier ID
  final String documentId;       // Supplier Firestore document ID
  final DateTime timestamp;      // When the change occurred
  final String userId;           // User email/ID who made the change
  final String userName;         // User display name
  final List<FieldChange> changes; // List of field changes in this edit
  final String? ipAddress;       // IP address of user (optional)
  final String? reason;          // Reason for the change (optional)

  SupplierHistory({
    this.id,
    required this.supId,
    required this.documentId,
    required this.timestamp,
    required this.userId,
    required this.userName,
    required this.changes,
    this.ipAddress,
    this.reason,
  });

  // Convert SupplierHistory to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'supId': supId,
      'documentId': documentId,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'userName': userName,
      'changes': changes.map((change) => change.toMap()).toList(),
      'ipAddress': ipAddress,
      'reason': reason,
    };
  }

  // Create SupplierHistory from Firestore DocumentSnapshot
  factory SupplierHistory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data()!;

      // Parse the changes list
      final changesData = data['changes'] as List<dynamic>;
      final changes = changesData
          .map((changeMap) => FieldChange.fromMap(changeMap as Map<String, dynamic>))
          .toList();

      return SupplierHistory(
        id: doc.id,
        supId: data['supId'] as int,
        documentId: data['documentId'] as String,
        timestamp: (data['timestamp'] as Timestamp).toDate(),
        userId: data['userId'] as String,
        userName: data['userName'] as String,
        changes: changes,
        ipAddress: data['ipAddress'] as String?,
        reason: data['reason'] as String?,
      );
    } catch (e) {
      logger.e('Error parsing supplier history from Firestore: $e');
      rethrow;
    }
  }

  // Helper method to get a summary of changes
  String getChangesSummary() {
    if (changes.isEmpty) return 'No changes';
    if (changes.length == 1) {
      return '${changes[0].fieldLabel} updated';
    }
    return '${changes.length} fields updated: ${changes.map((c) => c.fieldLabel).join(', ')}';
  }

  @override
  String toString() {
    return 'SupplierHistory(supId: $supId, timestamp: $timestamp, user: $userName, changes: ${changes.length})';
  }
}
