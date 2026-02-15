// lib/src/models/contract_fuel_type.dart

// ignore_for_file: non_constant_identifier_names

/// Represents a fuel type linked to a contract with its negotiated price.
/// Stored as an embedded array within ContractInfo documents in Firestore.
class ContractFuelType {
  final String FuelTypeId;
  final String FuelTypeName;
  final double BaseUnitPrice;
  final String PriceUnit;

  ContractFuelType({
    required this.FuelTypeId,
    required this.FuelTypeName,
    required this.BaseUnitPrice,
    this.PriceUnit = 'VND/ton',
  });

  factory ContractFuelType.fromMap(Map<String, dynamic> data) {
    return ContractFuelType(
      FuelTypeId: data['FuelTypeId'] as String? ?? '',
      FuelTypeName: data['FuelTypeName'] as String? ?? '',
      BaseUnitPrice: (data['BaseUnitPrice'] as num?)?.toDouble() ?? 0.0,
      PriceUnit: data['PriceUnit'] as String? ?? 'VND/ton',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'FuelTypeId': FuelTypeId,
      'FuelTypeName': FuelTypeName,
      'BaseUnitPrice': BaseUnitPrice,
      'PriceUnit': PriceUnit,
    };
  }

  @override
  String toString() => '$FuelTypeName @ $BaseUnitPrice $PriceUnit';
}
