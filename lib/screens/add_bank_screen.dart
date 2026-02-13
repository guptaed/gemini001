import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/bank.dart';
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
import 'package:gemini001/utils/logging.dart';

class AddBankScreen extends StatefulWidget {
  final int supId;
  final String companyName;

  const AddBankScreen({
    super.key,
    required this.supId,
    required this.companyName,
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
  bool _preferredBank = false;

  @override
  void dispose() {
    _paymentMethodIdController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _bankIdController.dispose();
    _branchIdController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveBankDetails() async {
    if (_formKey.currentState!.validate()) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    final theme = Theme.of(context);
    return CommonLayout(
      title: 'Add Bank Information',
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
                child: const Text('Save Bank Information'),
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
