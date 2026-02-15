import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/credit_check.dart';
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

class AddCreditCheckScreen extends StatefulWidget {
  final int supId;
  final String companyName;
  final CreditCheck? existingCreditCheck; // For edit mode

  const AddCreditCheckScreen({
    super.key,
    required this.supId,
    required this.companyName,
    this.existingCreditCheck,
  });

  @override
  State<AddCreditCheckScreen> createState() => _AddCreditCheckScreenState();
}

class _AddCreditCheckScreenState extends State<AddCreditCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _establishedDateController = TextEditingController();
  final _rawMaterialTypesController = TextEditingController();
  final _supplyCapacityController = TextEditingController();
  final _trackRecordController = TextEditingController();
  final _pdfUrlPhotoERCController = TextEditingController();
  final _checkCompanyController = TextEditingController();
  final _checkStartDateController = TextEditingController();
  final _checkFinishDateController = TextEditingController();
  final _reasonController = TextEditingController(); // For edit reason
  String? _selectedStatus;

  // Edit mode detection
  bool get isEditMode => widget.existingCreditCheck != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Pre-populate fields with existing credit check data
      final existing = widget.existingCreditCheck!;
      _establishedDateController.text = existing.establishedDate;
      _rawMaterialTypesController.text = existing.rawMaterialTypes;
      _supplyCapacityController.text = existing.supplyCapacity.toString();
      _trackRecordController.text = existing.trackRecord;
      _pdfUrlPhotoERCController.text = existing.pdfUrlPhotoERC;
      _checkCompanyController.text = existing.checkCompany;
      _checkStartDateController.text = existing.checkStartDate;
      _checkFinishDateController.text = existing.checkFinishDate;
      _selectedStatus = existing.status;
    }
  }

  @override
  void dispose() {
    _establishedDateController.dispose();
    _rawMaterialTypesController.dispose();
    _supplyCapacityController.dispose();
    _trackRecordController.dispose();
    _pdfUrlPhotoERCController.dispose();
    _checkCompanyController.dispose();
    _checkStartDateController.dispose();
    _checkFinishDateController.dispose();
    _reasonController.dispose();
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

  // Show a dialog that requires user acknowledgment
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
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Detect changes between existing credit check and form data
  List<FieldChange> _detectChanges() {
    if (!isEditMode) return [];

    final changes = <FieldChange>[];
    final existing = widget.existingCreditCheck!;

    // Check each field for changes
    if (_establishedDateController.text != existing.establishedDate) {
      changes.add(FieldChange(
        fieldName: 'establishedDate',
        fieldLabel: 'Established Date',
        oldValue: existing.establishedDate,
        newValue: _establishedDateController.text,
      ));
    }

    if (_rawMaterialTypesController.text != existing.rawMaterialTypes) {
      changes.add(FieldChange(
        fieldName: 'rawMaterialTypes',
        fieldLabel: 'Raw Material Types',
        oldValue: existing.rawMaterialTypes,
        newValue: _rawMaterialTypesController.text,
      ));
    }

    final newCapacity = int.tryParse(_supplyCapacityController.text) ?? 0;
    if (newCapacity != existing.supplyCapacity) {
      changes.add(FieldChange(
        fieldName: 'supplyCapacity',
        fieldLabel: 'Supply Capacity',
        oldValue: existing.supplyCapacity.toString(),
        newValue: newCapacity.toString(),
      ));
    }

    if (_trackRecordController.text != existing.trackRecord) {
      changes.add(FieldChange(
        fieldName: 'trackRecord',
        fieldLabel: 'Track Record',
        oldValue: existing.trackRecord,
        newValue: _trackRecordController.text,
      ));
    }

    if (_pdfUrlPhotoERCController.text != existing.pdfUrlPhotoERC) {
      changes.add(FieldChange(
        fieldName: 'pdfUrlPhotoERC',
        fieldLabel: 'PDF URL for ERC',
        oldValue: existing.pdfUrlPhotoERC,
        newValue: _pdfUrlPhotoERCController.text,
      ));
    }

    if (_checkCompanyController.text != existing.checkCompany) {
      changes.add(FieldChange(
        fieldName: 'checkCompany',
        fieldLabel: 'Check Company',
        oldValue: existing.checkCompany,
        newValue: _checkCompanyController.text,
      ));
    }

    if (_checkStartDateController.text != existing.checkStartDate) {
      changes.add(FieldChange(
        fieldName: 'checkStartDate',
        fieldLabel: 'Check Start Date',
        oldValue: existing.checkStartDate,
        newValue: _checkStartDateController.text,
      ));
    }

    if (_checkFinishDateController.text != existing.checkFinishDate) {
      changes.add(FieldChange(
        fieldName: 'checkFinishDate',
        fieldLabel: 'Check Finish Date',
        oldValue: existing.checkFinishDate,
        newValue: _checkFinishDateController.text,
      ));
    }

    if (_selectedStatus != existing.status) {
      changes.add(FieldChange(
        fieldName: 'status',
        fieldLabel: 'Status',
        oldValue: existing.status,
        newValue: _selectedStatus ?? '',
      ));
    }

    return changes;
  }

  // Show confirmation dialog with changes before saving
  Future<bool> _showConfirmationDialog(List<FieldChange> changes) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange[700], size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Confirm Changes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                          Text(
                            change.fieldLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'From: "${change.oldValue}"',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            'To: "${change.newValue}"',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 24),
                const Text(
                  'Do you want to proceed with these changes?',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  Future<void> _saveCreditCheck() async {
    if (_formKey.currentState!.validate()) {
      // Edit mode: Detect changes and show confirmation
      if (isEditMode) {
        final changes = _detectChanges();

        // If no changes, show message and return
        if (changes.isEmpty) {
          await _showMessageDialog(
            title: 'No Changes',
            message:
                'No modifications were made to the credit check information.',
            isError: false,
          );
          return;
        }

        // Show confirmation dialog
        final confirmed = await _showConfirmationDialog(changes);
        if (!confirmed) {
          return; // User cancelled
        }

        // Update the credit check
        try {
          final updatedCreditCheck = widget.existingCreditCheck!.copyWith(
            establishedDate: _establishedDateController.text,
            rawMaterialTypes: _rawMaterialTypesController.text,
            supplyCapacity: int.parse(_supplyCapacityController.text),
            trackRecord: _trackRecordController.text,
            pdfUrlPhotoERC: _pdfUrlPhotoERCController.text,
            checkCompany: _checkCompanyController.text,
            checkStartDate: _checkStartDateController.text,
            checkFinishDate: _checkFinishDateController.text,
            status: _selectedStatus!,
          );

          final reason = _reasonController.text.trim().isEmpty
              ? null
              : _reasonController.text.trim();

          await FirestoreHelper().updateCreditCheck(
            updatedCreditCheck,
            changes: changes,
            reason: reason,
            ipAddress: null, // Can be implemented later if needed
          );

          if (mounted) {
            await _showMessageDialog(
              title: 'Success',
              message: 'Credit check information updated successfully!',
              isError: false,
            );

            // Return to previous screen with success indicator
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          }
        } catch (e) {
          logger.e('Error updating credit check: $e');
          if (mounted) {
            await _showMessageDialog(
              title: 'Error',
              message: 'Failed to update credit check:\n\n$e',
              isError: true,
            );
          }
        }
      } else {
        // Add mode: Create new credit check
        final creditCheck = CreditCheck(
          supId: widget.supId,
          establishedDate: _establishedDateController.text,
          rawMaterialTypes: _rawMaterialTypesController.text,
          supplyCapacity: int.parse(_supplyCapacityController.text),
          trackRecord: _trackRecordController.text,
          pdfUrlPhotoERC: _pdfUrlPhotoERCController.text,
          checkCompany: _checkCompanyController.text,
          checkStartDate: _checkStartDateController.text,
          checkFinishDate: _checkFinishDateController.text,
          status: _selectedStatus!,
        );
        try {
          await FirestoreHelper().addCreditCheck(creditCheck);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Credit Check added successfully!')),
            );
            Navigator.pop(context); // Pop back to SupplierDetailsScreen
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding credit check: $e')),
            );
            logger.e(
                'Error adding credit check for SupplierId: ${widget.supId}',
                e);
          }
        }
      }
    }
  }

  void _onMenuItemSelected(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListSuppliersScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AddAnnouncementScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ListAnnouncementsScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddBidScreen()),
        );
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListBidsScreen()),
        );
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddShipmentScreen()),
        );
        break;
      case 7:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListShipmentsScreen()),
        );
        break;

      case 10:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SupplierOnboardingDashboard()),
        );
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
      title: isEditMode ? 'Edit Credit Check' : 'Add Credit Check Information',
      userName: userName,
      selectedPageIndex: 0, // Same as SupplierDetailsScreen
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
                validator: (value) =>
                    value!.isEmpty ? 'Supplier ID is required' : null,
              ),
              _buildTextField(
                labelText: 'Supplier Name',
                initialValue: widget.companyName,
                enabled: false,
                fillColor: Colors.grey[300],
                validator: (value) =>
                    value!.isEmpty ? 'Supplier Name is required' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _establishedDateController,
                labelText: 'Established Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _establishedDateController),
                validator: (value) =>
                    value!.isEmpty ? 'Enter Established Date' : null,
              ),
              _buildTextField(
                controller: _rawMaterialTypesController,
                labelText: 'Raw Material Types',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Raw Material Types' : null,
              ),
              _buildTextField(
                controller: _supplyCapacityController,
                labelText: 'Supply Capacity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter Supply Capacity';
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _trackRecordController,
                labelText: 'Track Record',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Track Record' : null,
              ),
              _buildTextField(
                controller: _pdfUrlPhotoERCController,
                labelText: 'PDF URL for ERC (Optional)',
                validator: (value) {
                  if (value!.isNotEmpty) {
                    if (!Uri.parse(value).isAbsolute) {
                      return 'Enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _checkCompanyController,
                labelText: 'Check Company',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Credit Check Company Name' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _checkStartDateController,
                labelText: 'Check Start Date (Optional, YYYY-MM-DD)',
                onTap: () => _selectDate(context, _checkStartDateController),
                validator: null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _checkFinishDateController,
                labelText: 'Check Finish Date (Optional, YYYY-MM-DD)',
                onTap: () => _selectDate(context, _checkFinishDateController),
                validator: null,
              ),
              _buildStatusDropdown(theme),
              const SizedBox(height: 20),
              // Reason for change field (Edit mode only)
              if (isEditMode) ...[
                Text(
                  'Reason for Change',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Optional: Explain why you are making these changes',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _reasonController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'e.g., Updated credit check results',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[400]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.teal[700]!, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[700]!, Colors.teal[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal[700]!.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveCreditCheck,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isEditMode ? 'Update Credit Check' : 'Save Credit Check',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
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
    bool obscureText = false,
    String? Function(String?)? validator,
    int? maxLines,
    int? maxLength,
    TextInputAction? textInputAction = TextInputAction.next,
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
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0),
          ),
          filled: !enabled,
          fillColor: fillColor,
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        maxLength: maxLength,
        textInputAction: textInputAction,
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
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0),
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: onTap,
          ),
        ),
        readOnly: true,
        onTap: onTap,
        validator: validator,
      ),
    );
  }

  Widget _buildStatusDropdown(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Status',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0),
          ),
        ),
        initialValue: _selectedStatus,
        items: ['To Start', 'In Progress', 'Successful', 'Rejected']
            .map((String status) {
          return DropdownMenuItem<String>(
            value: status,
            child: Text(status),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedStatus = newValue;
          });
        },
        validator: (value) => value == null ? 'Select a Status' : null,
      ),
    );
  }
}
