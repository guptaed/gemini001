// test/models/supplier_history_test.dart
// Unit tests for SupplierHistory and FieldChange models

import 'package:flutter_test/flutter_test.dart';
import 'package:gemini001/models/supplier_history.dart';

void main() {
  group('FieldChange', () {
    test('should create FieldChange with all properties', () {
      // Arrange & Act
      final fieldChange = FieldChange(
        fieldName: 'Address',
        fieldLabel: 'Address',
        oldValue: '123 Old Street',
        newValue: '456 New Avenue',
      );

      // Assert
      expect(fieldChange.fieldName, 'Address');
      expect(fieldChange.fieldLabel, 'Address');
      expect(fieldChange.oldValue, '123 Old Street');
      expect(fieldChange.newValue, '456 New Avenue');
    });

    test('toMap should convert FieldChange to Map correctly', () {
      // Arrange
      final fieldChange = FieldChange(
        fieldName: 'CompanyName',
        fieldLabel: 'Company Name',
        oldValue: 'ABC Corp',
        newValue: 'XYZ Ltd',
      );

      // Act
      final map = fieldChange.toMap();

      // Assert
      expect(map['fieldName'], 'CompanyName');
      expect(map['fieldLabel'], 'Company Name');
      expect(map['oldValue'], 'ABC Corp');
      expect(map['newValue'], 'XYZ Ltd');
    });

    test('fromMap should create FieldChange from Map correctly', () {
      // Arrange
      final map = {
        'fieldName': 'Tel',
        'fieldLabel': 'Telephone',
        'oldValue': '555-0001',
        'newValue': '555-0002',
      };

      // Act
      final fieldChange = FieldChange.fromMap(map);

      // Assert
      expect(fieldChange.fieldName, 'Tel');
      expect(fieldChange.fieldLabel, 'Telephone');
      expect(fieldChange.oldValue, '555-0001');
      expect(fieldChange.newValue, '555-0002');
    });

    test('toString should return formatted change description', () {
      // Arrange
      final fieldChange = FieldChange(
        fieldName: 'Email',
        fieldLabel: 'Email',
        oldValue: 'old@example.com',
        newValue: 'new@example.com',
      );

      // Act
      final result = fieldChange.toString();

      // Assert
      expect(result, 'Email: "old@example.com" → "new@example.com"');
    });

    test('should handle empty strings correctly', () {
      // Arrange & Act
      final fieldChange = FieldChange(
        fieldName: 'Address',
        fieldLabel: 'Address',
        oldValue: '',
        newValue: '123 New Street',
      );

      // Assert
      expect(fieldChange.oldValue, '');
      expect(fieldChange.newValue, '123 New Street');
    });
  });

  group('SupplierHistory', () {
    test('should create SupplierHistory with all required properties', () {
      // Arrange
      final changes = [
        FieldChange(
          fieldName: 'Address',
          fieldLabel: 'Address',
          oldValue: 'Old',
          newValue: 'New',
        ),
      ];
      final timestamp = DateTime(2026, 1, 15, 10, 30);

      // Act
      final history = SupplierHistory(
        supId: 123,
        documentId: 'doc123',
        timestamp: timestamp,
        userId: 'user@example.com',
        userName: 'John Doe',
        changes: changes,
      );

      // Assert
      expect(history.id, isNull);
      expect(history.supId, 123);
      expect(history.documentId, 'doc123');
      expect(history.timestamp, timestamp);
      expect(history.userId, 'user@example.com');
      expect(history.userName, 'John Doe');
      expect(history.changes.length, 1);
      expect(history.ipAddress, isNull);
      expect(history.reason, isNull);
    });

    test('should create SupplierHistory with optional properties', () {
      // Arrange
      final changes = [
        FieldChange(
          fieldName: 'Tel',
          fieldLabel: 'Telephone',
          oldValue: '555-0001',
          newValue: '555-0002',
        ),
      ];
      final timestamp = DateTime(2026, 1, 15, 10, 30);

      // Act
      final history = SupplierHistory(
        id: 'history123',
        supId: 456,
        documentId: 'doc456',
        timestamp: timestamp,
        userId: 'admin@example.com',
        userName: 'Admin User',
        changes: changes,
        ipAddress: '192.168.1.1',
        reason: 'Customer requested update',
      );

      // Assert
      expect(history.id, 'history123');
      expect(history.ipAddress, '192.168.1.1');
      expect(history.reason, 'Customer requested update');
    });

    test('toMap should convert SupplierHistory to Map correctly', () {
      // Arrange
      final changes = [
        FieldChange(
          fieldName: 'Address',
          fieldLabel: 'Address',
          oldValue: 'Old Address',
          newValue: 'New Address',
        ),
        FieldChange(
          fieldName: 'Tel',
          fieldLabel: 'Telephone',
          oldValue: '111-1111',
          newValue: '222-2222',
        ),
      ];
      final timestamp = DateTime(2026, 1, 15, 10, 30);

      final history = SupplierHistory(
        supId: 123,
        documentId: 'doc123',
        timestamp: timestamp,
        userId: 'user@example.com',
        userName: 'John Doe',
        changes: changes,
        reason: 'Test reason',
      );

      // Act
      final map = history.toMap();

      // Assert
      expect(map['supId'], 123);
      expect(map['documentId'], 'doc123');
      expect(map['userId'], 'user@example.com');
      expect(map['userName'], 'John Doe');
      expect(map['reason'], 'Test reason');
      expect(map['ipAddress'], isNull);
      expect(map['changes'], isA<List>());
      expect((map['changes'] as List).length, 2);
    });

    test('getChangesSummary should return correct summary for single change', () {
      // Arrange
      final changes = [
        FieldChange(
          fieldName: 'Address',
          fieldLabel: 'Address',
          oldValue: 'Old',
          newValue: 'New',
        ),
      ];

      final history = SupplierHistory(
        supId: 123,
        documentId: 'doc123',
        timestamp: DateTime.now(),
        userId: 'user@example.com',
        userName: 'John Doe',
        changes: changes,
      );

      // Act
      final summary = history.getChangesSummary();

      // Assert
      expect(summary, 'Address updated');
    });

    test('getChangesSummary should return correct summary for multiple changes', () {
      // Arrange
      final changes = [
        FieldChange(
          fieldName: 'Address',
          fieldLabel: 'Address',
          oldValue: 'Old',
          newValue: 'New',
        ),
        FieldChange(
          fieldName: 'Tel',
          fieldLabel: 'Telephone',
          oldValue: '111',
          newValue: '222',
        ),
        FieldChange(
          fieldName: 'Email',
          fieldLabel: 'Email',
          oldValue: 'old@test.com',
          newValue: 'new@test.com',
        ),
      ];

      final history = SupplierHistory(
        supId: 123,
        documentId: 'doc123',
        timestamp: DateTime.now(),
        userId: 'user@example.com',
        userName: 'John Doe',
        changes: changes,
      );

      // Act
      final summary = history.getChangesSummary();

      // Assert
      expect(summary, '3 fields updated: Address, Telephone, Email');
    });

    test('getChangesSummary should return "No changes" for empty changes list', () {
      // Arrange
      final history = SupplierHistory(
        supId: 123,
        documentId: 'doc123',
        timestamp: DateTime.now(),
        userId: 'user@example.com',
        userName: 'John Doe',
        changes: [],
      );

      // Act
      final summary = history.getChangesSummary();

      // Assert
      expect(summary, 'No changes');
    });

    test('toString should return formatted string representation', () {
      // Arrange
      final changes = [
        FieldChange(
          fieldName: 'Address',
          fieldLabel: 'Address',
          oldValue: 'Old',
          newValue: 'New',
        ),
      ];
      final timestamp = DateTime(2026, 1, 15, 10, 30);

      final history = SupplierHistory(
        supId: 123,
        documentId: 'doc123',
        timestamp: timestamp,
        userId: 'user@example.com',
        userName: 'John Doe',
        changes: changes,
      );

      // Act
      final result = history.toString();

      // Assert
      expect(result, contains('supId: 123'));
      expect(result, contains('user: John Doe'));
      expect(result, contains('changes: 1'));
    });
  });

  group('FieldChange - Edge Cases', () {
    test('should handle special characters in values', () {
      // Arrange & Act
      final fieldChange = FieldChange(
        fieldName: 'Address',
        fieldLabel: 'Address',
        oldValue: '123 "Main" St, Apt #5',
        newValue: "456 'Oak' Ave & Blvd",
      );

      // Assert
      expect(fieldChange.oldValue, '123 "Main" St, Apt #5');
      expect(fieldChange.newValue, "456 'Oak' Ave & Blvd");

      final map = fieldChange.toMap();
      final restored = FieldChange.fromMap(map);
      expect(restored.oldValue, fieldChange.oldValue);
      expect(restored.newValue, fieldChange.newValue);
    });

    test('should handle unicode characters', () {
      // Arrange & Act
      final fieldChange = FieldChange(
        fieldName: 'CompanyName',
        fieldLabel: 'Company Name',
        oldValue: '株式会社ABC',
        newValue: '有限会社XYZ',
      );

      // Assert
      expect(fieldChange.oldValue, '株式会社ABC');
      expect(fieldChange.newValue, '有限会社XYZ');
    });

    test('should handle very long strings', () {
      // Arrange
      final longString = 'A' * 1000;

      // Act
      final fieldChange = FieldChange(
        fieldName: 'Address',
        fieldLabel: 'Address',
        oldValue: 'Short',
        newValue: longString,
      );

      // Assert
      expect(fieldChange.newValue.length, 1000);
    });
  });

  group('SupplierHistory - Edge Cases', () {
    test('should handle many changes in a single history entry', () {
      // Arrange
      final changes = List.generate(
        10,
        (index) => FieldChange(
          fieldName: 'Field$index',
          fieldLabel: 'Field $index',
          oldValue: 'Old$index',
          newValue: 'New$index',
        ),
      );

      // Act
      final history = SupplierHistory(
        supId: 123,
        documentId: 'doc123',
        timestamp: DateTime.now(),
        userId: 'user@example.com',
        userName: 'John Doe',
        changes: changes,
      );

      // Assert
      expect(history.changes.length, 10);
      expect(history.getChangesSummary(), contains('10 fields updated'));
    });

    test('toMap and back should preserve all data', () {
      // Arrange
      final changes = [
        FieldChange(
          fieldName: 'Address',
          fieldLabel: 'Address',
          oldValue: 'Old Address',
          newValue: 'New Address',
        ),
      ];
      final timestamp = DateTime(2026, 1, 15, 10, 30, 45);

      final original = SupplierHistory(
        supId: 999,
        documentId: 'docXYZ',
        timestamp: timestamp,
        userId: 'test@test.com',
        userName: 'Test User',
        changes: changes,
        ipAddress: '10.0.0.1',
        reason: 'Testing round-trip',
      );

      // Act
      final map = original.toMap();

      // Assert - verify map structure
      expect(map['supId'], 999);
      expect(map['documentId'], 'docXYZ');
      expect(map['userId'], 'test@test.com');
      expect(map['userName'], 'Test User');
      expect(map['ipAddress'], '10.0.0.1');
      expect(map['reason'], 'Testing round-trip');
      expect((map['changes'] as List).length, 1);
    });
  });
}
