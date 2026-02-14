// test/utils/change_detector_test.dart
// Unit tests for SupplierChangeDetector

import 'package:flutter_test/flutter_test.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/utils/change_detector.dart';

void main() {
  // Create a sample original supplier for testing
  Supplier createTestSupplier() {
    return Supplier(
      id: 'doc123',
      SupId: 12345,
      CompanyName: 'Original Company',
      Address: '123 Original Street',
      Tel: '555-0001',
      Email: 'original@example.com',
      TaxCode: 'TAX-001',
      Representative: 'John Original',
      Title: 'Original Title',
      Status: 'Active',
    );
  }

  group('SupplierChangeDetector.detectChanges', () {
    test('should return empty list when no changes', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: original.Address,
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes, isEmpty);
    });

    test('should detect single field change', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: '456 New Street', // Changed
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].fieldName, 'Address');
      expect(changes[0].fieldLabel, 'Address');
      expect(changes[0].oldValue, '123 Original Street');
      expect(changes[0].newValue, '456 New Street');
    });

    test('should detect multiple field changes', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: 'New Company', // Changed
        address: '456 New Street', // Changed
        tel: '555-9999', // Changed
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 3);

      // Verify each change
      final fieldNames = changes.map((c) => c.fieldName).toList();
      expect(fieldNames, contains('CompanyName'));
      expect(fieldNames, contains('Address'));
      expect(fieldNames, contains('Tel'));
    });

    test('should detect all field changes', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: 'New Company',
        address: 'New Address',
        tel: 'New Tel',
        email: 'new@email.com',
        taxCode: 'NEW-TAX',
        representative: 'New Rep',
        title: 'New Title',
      );

      // Assert
      expect(changes.length, 7);
    });

    test('should correctly identify CompanyName change', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: 'Updated Company Name',
        address: original.Address,
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].fieldName, 'CompanyName');
      expect(changes[0].fieldLabel, 'Company Name');
      expect(changes[0].oldValue, 'Original Company');
      expect(changes[0].newValue, 'Updated Company Name');
    });

    test('should correctly identify Email change', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: original.Address,
        tel: original.Tel,
        email: 'newemail@company.com',
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].fieldName, 'Email');
      expect(changes[0].fieldLabel, 'Email');
    });

    test('should correctly identify TaxCode change', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: original.Address,
        tel: original.Tel,
        email: original.Email,
        taxCode: 'NEW-TAX-CODE',
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].fieldName, 'TaxCode');
      expect(changes[0].fieldLabel, 'Tax Code');
    });

    test('should correctly identify Representative change', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: original.Address,
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: 'Jane New',
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].fieldName, 'Representative');
      expect(changes[0].fieldLabel, 'Representative');
    });

    test('should correctly identify Title change', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: original.Address,
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: 'New Title',
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].fieldName, 'Title');
      expect(changes[0].fieldLabel, 'Title');
    });
  });

  group('SupplierChangeDetector.detectChangesBetweenSuppliers', () {
    test('should return empty list when suppliers are identical', () {
      // Arrange
      final original = createTestSupplier();
      final updated = Supplier(
        id: original.id,
        SupId: original.SupId,
        CompanyName: original.CompanyName,
        Address: original.Address,
        Tel: original.Tel,
        Email: original.Email,
        TaxCode: original.TaxCode,
        Representative: original.Representative,
        Title: original.Title,
        Status: original.Status,
      );

      // Act
      final changes = SupplierChangeDetector.detectChangesBetweenSuppliers(
        original: original,
        updated: updated,
      );

      // Assert
      expect(changes, isEmpty);
    });

    test('should detect changes between two supplier objects', () {
      // Arrange
      final original = createTestSupplier();
      final updated = Supplier(
        id: original.id,
        SupId: original.SupId,
        CompanyName: 'New Company Name',
        Address: 'New Address',
        Tel: original.Tel,
        Email: original.Email,
        TaxCode: original.TaxCode,
        Representative: original.Representative,
        Title: original.Title,
        Status: original.Status,
      );

      // Act
      final changes = SupplierChangeDetector.detectChangesBetweenSuppliers(
        original: original,
        updated: updated,
      );

      // Assert
      expect(changes.length, 2);
      expect(changes.map((c) => c.fieldName), containsAll(['CompanyName', 'Address']));
    });
  });

  group('Edge Cases', () {
    test('should handle empty string to non-empty change', () {
      // Arrange
      final original = Supplier(
        id: 'doc123',
        SupId: 12345,
        CompanyName: 'Company',
        Address: '', // Empty
        Tel: '555-0001',
        Email: 'test@test.com',
        TaxCode: 'TAX-001',
        Representative: 'Rep',
        Title: 'Title',
        Status: 'Active',
      );

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: '123 New Street', // Now has value
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].oldValue, '');
      expect(changes[0].newValue, '123 New Street');
    });

    test('should handle non-empty to empty string change', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: '', // Changed to empty
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].oldValue, '123 Original Street');
      expect(changes[0].newValue, '');
    });

    test('should handle whitespace differences as changes', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: '123 Original Street ', // Trailing space
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].newValue, '123 Original Street ');
    });

    test('should handle case sensitivity', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: 'ORIGINAL COMPANY', // Different case
        address: original.Address,
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].oldValue, 'Original Company');
      expect(changes[0].newValue, 'ORIGINAL COMPANY');
    });

    test('should handle unicode characters', () {
      // Arrange
      final original = Supplier(
        id: 'doc123',
        SupId: 12345,
        CompanyName: '株式会社ABC',
        Address: '東京都',
        Tel: '03-1234-5678',
        Email: 'test@test.co.jp',
        TaxCode: 'JP-TAX-001',
        Representative: '山田太郎',
        Title: '代表取締役',
        Status: 'Active',
      );

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: '有限会社XYZ', // Changed
        address: original.Address,
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].oldValue, '株式会社ABC');
      expect(changes[0].newValue, '有限会社XYZ');
    });

    test('should handle special characters', () {
      // Arrange
      final original = createTestSupplier();

      // Act
      final changes = SupplierChangeDetector.detectChanges(
        original: original,
        companyName: original.CompanyName,
        address: '123 Main St, Apt #5 & "Suite" 100',
        tel: original.Tel,
        email: original.Email,
        taxCode: original.TaxCode,
        representative: original.Representative,
        title: original.Title,
      );

      // Assert
      expect(changes.length, 1);
      expect(changes[0].newValue, '123 Main St, Apt #5 & "Suite" 100');
    });
  });
}
