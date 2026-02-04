// lib/utils/change_detector.dart
// Utility class for detecting changes between Supplier objects

import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/supplier_history.dart';

/// Utility class to detect field-level changes between Supplier objects
class SupplierChangeDetector {
  /// Detects changes between an original supplier and updated values
  /// Returns a list of FieldChange objects representing the modifications
  static List<FieldChange> detectChanges({
    required Supplier original,
    required String companyName,
    required String address,
    required String tel,
    required String email,
    required String taxCode,
    required String representative,
    required String title,
  }) {
    final changes = <FieldChange>[];

    if (companyName != original.CompanyName) {
      changes.add(FieldChange(
        fieldName: 'CompanyName',
        fieldLabel: 'Company Name',
        oldValue: original.CompanyName,
        newValue: companyName,
      ));
    }

    if (address != original.Address) {
      changes.add(FieldChange(
        fieldName: 'Address',
        fieldLabel: 'Address',
        oldValue: original.Address,
        newValue: address,
      ));
    }

    if (tel != original.Tel) {
      changes.add(FieldChange(
        fieldName: 'Tel',
        fieldLabel: 'Telephone',
        oldValue: original.Tel,
        newValue: tel,
      ));
    }

    if (email != original.Email) {
      changes.add(FieldChange(
        fieldName: 'Email',
        fieldLabel: 'Email',
        oldValue: original.Email,
        newValue: email,
      ));
    }

    if (taxCode != original.TaxCode) {
      changes.add(FieldChange(
        fieldName: 'TaxCode',
        fieldLabel: 'Tax Code',
        oldValue: original.TaxCode,
        newValue: taxCode,
      ));
    }

    if (representative != original.Representative) {
      changes.add(FieldChange(
        fieldName: 'Representative',
        fieldLabel: 'Representative',
        oldValue: original.Representative,
        newValue: representative,
      ));
    }

    if (title != original.Title) {
      changes.add(FieldChange(
        fieldName: 'Title',
        fieldLabel: 'Title',
        oldValue: original.Title,
        newValue: title,
      ));
    }

    return changes;
  }

  /// Convenience method to detect changes between two Supplier objects
  static List<FieldChange> detectChangesBetweenSuppliers({
    required Supplier original,
    required Supplier updated,
  }) {
    return detectChanges(
      original: original,
      companyName: updated.CompanyName,
      address: updated.Address,
      tel: updated.Tel,
      email: updated.Email,
      taxCode: updated.TaxCode,
      representative: updated.Representative,
      title: updated.Title,
    );
  }
}
