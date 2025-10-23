import 'package:flutter_test/flutter_test.dart';

bool isValidSupplierName(String name) =>
    name.trim().isNotEmpty && name.trim().length >= 3;

void main() {
  test('supplier name validation', () {
    expect(isValidSupplierName(''), false);
    expect(isValidSupplierName('AB'), false);
    expect(isValidSupplierName('Acme Wood'), true);
  });
}
