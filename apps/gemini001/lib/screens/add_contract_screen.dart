import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/contract_fuel_type.dart';
import 'package:gemini001/models/fuel_type.dart';
import 'package:gemini001/models/supplier_history.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:gemini001/screens/list_fuel_types_screen.dart';
import 'package:gemini001/screens/add_fuel_type_screen.dart';
import 'package:gemini001/utils/logging.dart';

class AddContractScreen extends StatefulWidget {
  final int supId;
  final String companyName;
  final ContractInfo? existingContract; // For edit mode

  const AddContractScreen({
    super.key,
    required this.supId,
    required this.companyName,
    this.existingContract,
  });

  @override
  State<AddContractScreen> createState() => _AddContractScreenState();
}

class _AddContractScreenState extends State<AddContractScreen> {
  final _formKey = GlobalKey<FormState>();
  final _contractNoController = TextEditingController();
  final _signedDateController = TextEditingController();
  final _validityYrsController = TextEditingController();
  final _maxAutoValidityController = TextEditingController();
  final _pdfUrlMainController = TextEditingController();
  final _pdfUrlAppendix1Controller = TextEditingController();
  final _reasonController = TextEditingController();

  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  late Stream<List<FuelType>> _activeFuelTypesStream;

  // Contracted fuel types with their prices
  final List<_ContractedFuelTypeEntry> _contractedFuelTypeEntries = [];

  bool get isEditMode => widget.existingContract != null;

  @override
  void initState() {
    super.initState();
    _activeFuelTypesStream = _firestoreHelper.streamActiveFuelTypes();
    if (isEditMode) {
      final existing = widget.existingContract!;
      _contractNoController.text = existing.ContractNo;
      _signedDateController.text = existing.SignedDate;
      _validityYrsController.text = existing.ValidityYrs.toString();
      _maxAutoValidityController.text = existing.MaxAutoValidity.toString();
      _pdfUrlMainController.text = existing.PdfUrlMain ?? '';
      _pdfUrlAppendix1Controller.text = existing.PdfUrlAppendix1 ?? '';
      // Load existing contracted fuel types
      for (final cft in existing.ContractedFuelTypes) {
        _contractedFuelTypeEntries.add(_ContractedFuelTypeEntry(
          fuelTypeId: cft.FuelTypeId,
          fuelTypeName: cft.FuelTypeName,
          priceController: TextEditingController(text: cft.BaseUnitPrice.toString()),
          priceUnit: cft.PriceUnit,
        ));
      }
    }
  }

  @override
  void dispose() {
    _contractNoController.dispose();
    _signedDateController.dispose();
    _validityYrsController.dispose();
    _maxAutoValidityController.dispose();
    _pdfUrlMainController.dispose();
    _pdfUrlAppendix1Controller.dispose();
    _reasonController.dispose();
    for (final entry in _contractedFuelTypeEntries) {
      entry.priceController.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  List<ContractFuelType> _buildContractedFuelTypes() {
    return _contractedFuelTypeEntries.map((entry) => ContractFuelType(
      FuelTypeId: entry.fuelTypeId,
      FuelTypeName: entry.fuelTypeName,
      BaseUnitPrice: double.tryParse(entry.priceController.text) ?? 0.0,
      PriceUnit: entry.priceUnit,
    )).toList();
  }

  List<String> _buildContractedFuelTypeIds() {
    return _contractedFuelTypeEntries.map((e) => e.fuelTypeId).toList();
  }

  void _addFuelTypeEntry(FuelType ft) {
    // Don't add duplicates
    if (_contractedFuelTypeEntries.any((e) => e.fuelTypeId == ft.FuelTypeId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${ft.FuelTypeName} is already added')),
      );
      return;
    }
    setState(() {
      _contractedFuelTypeEntries.add(_ContractedFuelTypeEntry(
        fuelTypeId: ft.FuelTypeId,
        fuelTypeName: ft.FuelTypeName,
        priceController: TextEditingController(),
        priceUnit: 'VND/${ft.UnitOfMeasure}',
      ));
    });
  }

  void _removeFuelTypeEntry(int index) {
    setState(() {
      _contractedFuelTypeEntries[index].priceController.dispose();
      _contractedFuelTypeEntries.removeAt(index);
    });
  }

  Future<void> _showMessageDialog({
    required String title,
    required String message,
    bool isError = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red : Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isError ? Colors.red[700] : Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(child: Text(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  List<FieldChange> _detectChanges() {
    if (!isEditMode) return [];

    final changes = <FieldChange>[];
    final existing = widget.existingContract!;

    if (_contractNoController.text != existing.ContractNo) {
      changes.add(FieldChange(
        fieldName: 'ContractNo', fieldLabel: 'Contract Number',
        oldValue: existing.ContractNo, newValue: _contractNoController.text,
      ));
    }
    if (_signedDateController.text != existing.SignedDate) {
      changes.add(FieldChange(
        fieldName: 'SignedDate', fieldLabel: 'Signed Date',
        oldValue: existing.SignedDate, newValue: _signedDateController.text,
      ));
    }
    final newValidityYrs = int.tryParse(_validityYrsController.text) ?? 0;
    if (newValidityYrs != existing.ValidityYrs) {
      changes.add(FieldChange(
        fieldName: 'ValidityYrs', fieldLabel: 'Validity Years',
        oldValue: existing.ValidityYrs.toString(), newValue: newValidityYrs.toString(),
      ));
    }
    final newMaxAutoValidity = int.tryParse(_maxAutoValidityController.text) ?? 0;
    if (newMaxAutoValidity != existing.MaxAutoValidity) {
      changes.add(FieldChange(
        fieldName: 'MaxAutoValidity', fieldLabel: 'Max Auto Validity',
        oldValue: existing.MaxAutoValidity.toString(), newValue: newMaxAutoValidity.toString(),
      ));
    }

    // Detect fuel type changes
    final oldFuelTypeIds = existing.ContractedFuelTypeIds.toSet();
    final newFuelTypeIds = _buildContractedFuelTypeIds().toSet();
    if (!oldFuelTypeIds.containsAll(newFuelTypeIds) || !newFuelTypeIds.containsAll(oldFuelTypeIds)) {
      changes.add(FieldChange(
        fieldName: 'ContractedFuelTypeIds', fieldLabel: 'Contracted Fuel Types',
        oldValue: existing.ContractedFuelTypeIds.join(', '),
        newValue: _buildContractedFuelTypeIds().join(', '),
      ));
    } else {
      // Check if any prices changed
      for (final entry in _contractedFuelTypeEntries) {
        final oldEntry = existing.ContractedFuelTypes
            .where((cft) => cft.FuelTypeId == entry.fuelTypeId)
            .firstOrNull;
        if (oldEntry != null) {
          final newPrice = double.tryParse(entry.priceController.text) ?? 0.0;
          if (newPrice != oldEntry.BaseUnitPrice) {
            changes.add(FieldChange(
              fieldName: 'BaseUnitPrice_${entry.fuelTypeId}',
              fieldLabel: 'Price for ${entry.fuelTypeName}',
              oldValue: oldEntry.BaseUnitPrice.toString(),
              newValue: newPrice.toString(),
            ));
          }
        }
      }
    }

    final newPdfUrlMain = _pdfUrlMainController.text.isEmpty ? null : _pdfUrlMainController.text;
    if (newPdfUrlMain != existing.PdfUrlMain) {
      changes.add(FieldChange(
        fieldName: 'PdfUrlMain', fieldLabel: 'Main Contract PDF URL',
        oldValue: existing.PdfUrlMain ?? '', newValue: newPdfUrlMain ?? '',
      ));
    }
    final newPdfUrlAppendix1 = _pdfUrlAppendix1Controller.text.isEmpty ? null : _pdfUrlAppendix1Controller.text;
    if (newPdfUrlAppendix1 != existing.PdfUrlAppendix1) {
      changes.add(FieldChange(
        fieldName: 'PdfUrlAppendix1', fieldLabel: 'Appendix 1 PDF URL',
        oldValue: existing.PdfUrlAppendix1 ?? '', newValue: newPdfUrlAppendix1 ?? '',
      ));
    }

    return changes;
  }

  Future<bool> _showConfirmationDialog(List<FieldChange> changes) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Confirm Changes', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You are about to modify the following ${changes.length} field${changes.length > 1 ? 's' : ''}:',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                ...changes.map((change) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(change.fieldLabel, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[700])),
                      const SizedBox(height: 4),
                      Text('From: "${change.oldValue}"', style: TextStyle(color: Colors.grey[700])),
                      Text('To: "${change.newValue}"', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87)),
                    ],
                  ),
                )),
                const Divider(height: 24),
                const Text('Do you want to proceed with these changes?', style: TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], foregroundColor: Colors.white),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  Future<void> _saveContract() async {
    if (_formKey.currentState!.validate()) {
      if (isEditMode) {
        final changes = _detectChanges();
        if (changes.isEmpty) {
          await _showMessageDialog(title: 'No Changes', message: 'No modifications were made to the contract information.');
          return;
        }
        final confirmed = await _showConfirmationDialog(changes);
        if (!confirmed) return;

        try {
          final updatedContract = widget.existingContract!.copyWith(
            ContractNo: _contractNoController.text,
            SignedDate: _signedDateController.text,
            ValidityYrs: int.parse(_validityYrsController.text),
            MaxAutoValidity: int.parse(_maxAutoValidityController.text),
            ContractedFuelTypes: _buildContractedFuelTypes(),
            ContractedFuelTypeIds: _buildContractedFuelTypeIds(),
            PdfUrlMain: _pdfUrlMainController.text.isEmpty ? null : _pdfUrlMainController.text,
            PdfUrlAppendix1: _pdfUrlAppendix1Controller.text.isEmpty ? null : _pdfUrlAppendix1Controller.text,
          );

          final reason = _reasonController.text.trim().isEmpty ? null : _reasonController.text.trim();
          await _firestoreHelper.updateContractInfo(updatedContract, changes: changes, reason: reason);

          if (mounted) {
            await _showMessageDialog(title: 'Success', message: 'Contract information updated successfully!');
            if (mounted) Navigator.of(context).pop(true);
          }
        } catch (e) {
          logger.e('Error updating contract: $e');
          if (mounted) {
            await _showMessageDialog(title: 'Error', message: 'Failed to update contract:\n\n$e', isError: true);
          }
        }
      } else {
        final contractInfo = ContractInfo(
          SupId: widget.supId,
          ContractNo: _contractNoController.text,
          SignedDate: _signedDateController.text,
          ValidityYrs: int.parse(_validityYrsController.text),
          MaxAutoValidity: int.parse(_maxAutoValidityController.text),
          ContractedFuelTypes: _buildContractedFuelTypes(),
          ContractedFuelTypeIds: _buildContractedFuelTypeIds(),
          PdfUrlMain: _pdfUrlMainController.text.isEmpty ? null : _pdfUrlMainController.text,
          PdfUrlAppendix1: _pdfUrlAppendix1Controller.text.isEmpty ? null : _pdfUrlAppendix1Controller.text,
        );
        try {
          await _firestoreHelper.addContractInfo(contractInfo);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Contract Information added successfully!')),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding contract: $e')));
            logger.e('Error adding contract for SupplierId: ${widget.supId}', e);
          }
        }
      }
    }
  }

  void _onMenuItemSelected(int index) {
    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListSuppliersScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddSupplierScreen()));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListAnnouncementsScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddBidScreen()));
        break;
      case 5:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListBidsScreen()));
        break;
      case 6:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddShipmentScreen()));
        break;
      case 7:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListShipmentsScreen()));
        break;
      case 10:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SupplierOnboardingDashboard()));
        break;
      case 11:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListFuelTypesScreen()));
        break;
      case 12:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelTypeScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    final theme = Theme.of(context);
    return CommonLayout(
      title: isEditMode ? 'Edit Contract Information' : 'Add Contract Information',
      userName: userName,
      selectedPageIndex: 0,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                labelText: 'Supplier ID',
                initialValue: widget.supId.toString(),
                enabled: false,
                fillColor: Colors.grey[300],
              ),
              _buildTextField(
                labelText: 'Supplier Name',
                initialValue: widget.companyName,
                enabled: false,
                fillColor: Colors.grey[300],
              ),
              _buildTextField(
                controller: _contractNoController,
                labelText: 'Contract Number',
                validator: (value) => value!.isEmpty ? 'Enter Contract Number' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _signedDateController,
                labelText: 'Signed Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _signedDateController),
                validator: (value) => value!.isEmpty ? 'Enter Signed Date' : null,
              ),
              _buildTextField(
                controller: _validityYrsController,
                labelText: 'Validity Years',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter Validity Years';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              _buildTextField(
                controller: _maxAutoValidityController,
                labelText: 'Max Auto Validity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter Max Auto Validity';
                  if (int.tryParse(value) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              // Contracted Fuel Types section
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.teal[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Contracted Fuel Types',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800], fontSize: 16),
                        ),
                        const Spacer(),
                        // Add fuel type button
                        StreamBuilder<List<FuelType>>(
                          stream: _activeFuelTypesStream,
                          builder: (context, snapshot) {
                            final fuelTypes = snapshot.data ?? [];
                            return PopupMenuButton<FuelType>(
                              tooltip: 'Add fuel type',
                              icon: Icon(Icons.add_circle, color: Colors.teal[700], size: 28),
                              onSelected: _addFuelTypeEntry,
                              itemBuilder: (context) {
                                if (fuelTypes.isEmpty) {
                                  return [
                                    const PopupMenuItem(
                                      enabled: false,
                                      child: Text('No fuel types available'),
                                    ),
                                  ];
                                }
                                return fuelTypes.map((ft) => PopupMenuItem<FuelType>(
                                  value: ft,
                                  child: Text('${ft.FuelTypeName} (${ft.FuelTypeId})'),
                                )).toList();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    if (_contractedFuelTypeEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No fuel types added yet. Use the + button to add fuel types covered by this contract.',
                          style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                        ),
                      ),
                    ..._contractedFuelTypeEntries.asMap().entries.map((mapEntry) {
                      final index = mapEntry.key;
                      final entry = mapEntry.value;
                      return Card(
                        margin: const EdgeInsets.only(top: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.fuelTypeName,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    Text(entry.fuelTypeId, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  controller: entry.priceController,
                                  decoration: InputDecoration(
                                    labelText: 'Price (${entry.priceUnit})',
                                    border: const OutlineInputBorder(),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  ),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) return 'Required';
                                    if (double.tryParse(value) == null) return 'Invalid';
                                    return null;
                                  },
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_circle, color: Colors.red[400]),
                                onPressed: () => _removeFuelTypeEntry(index),
                                tooltip: 'Remove',
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _pdfUrlMainController,
                labelText: 'Main Contract PDF URL (Optional)',
                validator: (value) {
                  if (value!.isNotEmpty && !Uri.parse(value).isAbsolute) return 'Enter a valid URL';
                  return null;
                },
              ),
              _buildTextField(
                controller: _pdfUrlAppendix1Controller,
                labelText: 'Appendix 1 PDF URL (Optional)',
                validator: (value) {
                  if (value!.isNotEmpty && !Uri.parse(value).isAbsolute) return 'Enter a valid URL';
                  return null;
                },
              ),
              // Reason for change field (edit mode only)
              if (isEditMode) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                          const SizedBox(width: 8),
                          Text('Reason for Change (Optional)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber[800])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Briefly describe why you are making this change...',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0)),
                          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0)),
                          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0)),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContract,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(isEditMode ? 'Update Contract Information' : 'Save Contract Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String labelText,
    TextEditingController? controller,
    String? initialValue,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int? maxLines,
    bool enabled = true,
    Color? fillColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0)),
          filled: !enabled,
          fillColor: fillColor,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: TextInputAction.next,
        enabled: enabled,
        validator: validator,
      ),
    );
  }

  Widget _buildTextFieldWithDatePicker({
    required TextEditingController controller,
    required String labelText,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0)),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0)),
          suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: onTap),
        ),
        readOnly: true,
        onTap: onTap,
        validator: validator,
      ),
    );
  }
}

/// Internal helper class for managing contracted fuel type entries in the form
class _ContractedFuelTypeEntry {
  final String fuelTypeId;
  final String fuelTypeName;
  final TextEditingController priceController;
  final String priceUnit;

  _ContractedFuelTypeEntry({
    required this.fuelTypeId,
    required this.fuelTypeName,
    required this.priceController,
    this.priceUnit = 'VND/ton',
  });
}
