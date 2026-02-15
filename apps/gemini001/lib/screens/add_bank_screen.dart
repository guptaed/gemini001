import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/bank.dart';
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
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:gemini001/screens/list_fuel_types_screen.dart';
import 'package:gemini001/screens/add_fuel_type_screen.dart';
import 'package:gemini001/utils/logging.dart';

class AddBankScreen extends StatefulWidget {
  final int supId;
  final String companyName;
  final BankDetails? existingBank; // For edit mode

  const AddBankScreen({
    super.key,
    required this.supId,
    required this.companyName,
    this.existingBank,
  });

  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  final _formKey = GlobalKey<FormState>();
  final _paymentMethodIdController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _bankIdController = TextEditingController();
  final _branchIdController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _reasonController = TextEditingController(); // For edit reason
  bool _preferredBank = false;

  // Edit mode detection
  bool get isEditMode => widget.existingBank != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      // Pre-populate fields with existing bank data
      final existing = widget.existingBank!;
      _paymentMethodIdController.text = existing.PaymentMethodId;
      _bankNameController.text = existing.BankName;
      _branchNameController.text = existing.BranchName;
      _bankIdController.text = existing.BankId;
      _branchIdController.text = existing.BranchId;
      _accountNameController.text = existing.AccountName;
      _accountNumberController.text = existing.AccountNumber;
      _preferredBank = existing.PreferredBank;
    }
  }

  @override
  void dispose() {
    _paymentMethodIdController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _bankIdController.dispose();
    _branchIdController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _reasonController.dispose();
    super.dispose();
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

  // Detect changes between existing bank and form data
  List<FieldChange> _detectChanges() {
    if (!isEditMode) return [];

    final changes = <FieldChange>[];
    final existing = widget.existingBank!;

    // Check each field for changes
    if (_paymentMethodIdController.text != existing.PaymentMethodId) {
      changes.add(FieldChange(
        fieldName: 'PaymentMethodId',
        fieldLabel: 'Payment Method ID',
        oldValue: existing.PaymentMethodId,
        newValue: _paymentMethodIdController.text,
      ));
    }

    if (_bankNameController.text != existing.BankName) {
      changes.add(FieldChange(
        fieldName: 'BankName',
        fieldLabel: 'Bank Name',
        oldValue: existing.BankName,
        newValue: _bankNameController.text,
      ));
    }

    if (_branchNameController.text != existing.BranchName) {
      changes.add(FieldChange(
        fieldName: 'BranchName',
        fieldLabel: 'Branch Name',
        oldValue: existing.BranchName,
        newValue: _branchNameController.text,
      ));
    }

    if (_bankIdController.text != existing.BankId) {
      changes.add(FieldChange(
        fieldName: 'BankId',
        fieldLabel: 'Bank ID',
        oldValue: existing.BankId,
        newValue: _bankIdController.text,
      ));
    }

    if (_branchIdController.text != existing.BranchId) {
      changes.add(FieldChange(
        fieldName: 'BranchId',
        fieldLabel: 'Branch ID',
        oldValue: existing.BranchId,
        newValue: _branchIdController.text,
      ));
    }

    if (_accountNameController.text != existing.AccountName) {
      changes.add(FieldChange(
        fieldName: 'AccountName',
        fieldLabel: 'Account Name',
        oldValue: existing.AccountName,
        newValue: _accountNameController.text,
      ));
    }

    if (_accountNumberController.text != existing.AccountNumber) {
      changes.add(FieldChange(
        fieldName: 'AccountNumber',
        fieldLabel: 'Account Number',
        oldValue: existing.AccountNumber,
        newValue: _accountNumberController.text,
      ));
    }

    if (_preferredBank != existing.PreferredBank) {
      changes.add(FieldChange(
        fieldName: 'PreferredBank',
        fieldLabel: 'Preferred Bank',
        oldValue: existing.PreferredBank.toString(),
        newValue: _preferredBank.toString(),
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

  Future<void> _saveBankDetails() async {
    if (_formKey.currentState!.validate()) {
      // Edit mode: Detect changes and show confirmation
      if (isEditMode) {
        final changes = _detectChanges();

        // If no changes, show message and return
        if (changes.isEmpty) {
          await _showMessageDialog(
            title: 'No Changes',
            message: 'No modifications were made to the bank information.',
            isError: false,
          );
          return;
        }

        // Show confirmation dialog
        final confirmed = await _showConfirmationDialog(changes);
        if (!confirmed) {
          return; // User cancelled
        }

        // Update the bank details
        try {
          final updatedBank = widget.existingBank!.copyWith(
            PaymentMethodId: _paymentMethodIdController.text,
            BankName: _bankNameController.text,
            BranchName: _branchNameController.text,
            BankId: _bankIdController.text,
            BranchId: _branchIdController.text,
            AccountName: _accountNameController.text,
            AccountNumber: _accountNumberController.text,
            PreferredBank: _preferredBank,
          );

          final reason = _reasonController.text.trim().isEmpty
              ? null
              : _reasonController.text.trim();

          await FirestoreHelper().updateBankDetails(
            updatedBank,
            changes: changes,
            reason: reason,
            ipAddress: null, // Can be implemented later if needed
          );

          if (mounted) {
            await _showMessageDialog(
              title: 'Success',
              message: 'Bank information updated successfully!',
              isError: false,
            );

            // Return to previous screen with success indicator
            if (mounted) {
              Navigator.of(context).pop(true);
            }
          }
        } catch (e) {
          logger.e('Error updating bank details: $e');
          if (mounted) {
            await _showMessageDialog(
              title: 'Error',
              message: 'Failed to update bank information:\n\n$e',
              isError: true,
            );
          }
        }
      } else {
        // Add mode: Create new bank details
        final bankDetails = BankDetails(
          SupId: widget.supId,
          PaymentMethodId: _paymentMethodIdController.text,
          BankName: _bankNameController.text,
          BranchName: _branchNameController.text,
          BankId: _bankIdController.text,
          BranchId: _branchIdController.text,
          AccountName: _accountNameController.text,
          AccountNumber: _accountNumberController.text,
          PreferredBank: _preferredBank,
        );
        try {
          await FirestoreHelper().addBankDetails(bankDetails);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Bank Information added successfully!')),
            );
            Navigator.pop(context); // Pop back to SupplierDetailsScreen
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error adding bank details: $e')),
            );
            logger.e(
                'Error adding bank details for SupplierId: ${widget.supId}', e);
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
      title: isEditMode ? 'Edit Bank Information' : 'Add Bank Information',
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
              _buildTextField(
                controller: _paymentMethodIdController,
                labelText: 'Payment Method ID',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Payment Method ID' : null,
              ),
              _buildTextField(
                controller: _bankNameController,
                labelText: 'Bank Name',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Bank Name' : null,
              ),
              _buildTextField(
                controller: _branchNameController,
                labelText: 'Branch Name',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Branch Name' : null,
              ),
              _buildTextField(
                controller: _bankIdController,
                labelText: 'Bank ID',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Bank ID' : null,
              ),
              _buildTextField(
                controller: _branchIdController,
                labelText: 'Branch ID',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Branch ID' : null,
              ),
              _buildTextField(
                controller: _accountNameController,
                labelText: 'Account Name',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Account Name' : null,
              ),
              _buildTextField(
                controller: _accountNumberController,
                labelText: 'Account Number',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Account Number' : null,
              ),
              _buildPreferredBankSwitch(theme),
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
                          Text(
                            'Reason for Change (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.amber[800],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reasonController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Briefly describe why you are making this change...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0),
                          ),
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
                onPressed: _saveBankDetails,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(isEditMode ? 'Update Bank Information' : 'Save Bank Information'),
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

  Widget _buildPreferredBankSwitch(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 1.0),
          borderRadius: BorderRadius.circular(4),
        ),
        child: SwitchListTile(
          title: const Text('Preferred Bank'),
          subtitle: const Text('Set this as the preferred bank for payments'),
          value: _preferredBank,
          onChanged: (bool value) {
            setState(() {
              _preferredBank = value;
            });
          },
          activeTrackColor: theme.primaryColor.withValues(alpha: 0.5),
          thumbColor: WidgetStatePropertyAll(theme.primaryColor),
        ),
      ),
    );
  }
}
