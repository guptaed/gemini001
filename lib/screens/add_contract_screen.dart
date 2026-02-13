import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/contract.dart';
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
import 'package:gemini001/utils/logging.dart';

class AddContractScreen extends StatefulWidget {
  final int supId;
  final String companyName;

  const AddContractScreen({
    super.key,
    required this.supId,
    required this.companyName,
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
  final _stt1PriceController = TextEditingController();
  final _stt2PriceController = TextEditingController();
  final _pdfUrlMainController = TextEditingController();
  final _pdfUrlAppendix1Controller = TextEditingController();

  @override
  void dispose() {
    _contractNoController.dispose();
    _signedDateController.dispose();
    _validityYrsController.dispose();
    _maxAutoValidityController.dispose();
    _stt1PriceController.dispose();
    _stt2PriceController.dispose();
    _pdfUrlMainController.dispose();
    _pdfUrlAppendix1Controller.dispose();
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

  Future<void> _saveContract() async {
    if (_formKey.currentState!.validate()) {
      final contractInfo = ContractInfo(
        SupId: widget.supId,
        ContractNo: _contractNoController.text,
        SignedDate: _signedDateController.text,
        ValidityYrs: int.parse(_validityYrsController.text),
        MaxAutoValidity: int.parse(_maxAutoValidityController.text),
        STT1Price: double.parse(_stt1PriceController.text),
        STT2Price: double.parse(_stt2PriceController.text),
        PdfUrlMain: _pdfUrlMainController.text.isEmpty
            ? null
            : _pdfUrlMainController.text,
        PdfUrlAppendix1: _pdfUrlAppendix1Controller.text.isEmpty
            ? null
            : _pdfUrlAppendix1Controller.text,
      );
      try {
        await FirestoreHelper().addContractInfo(contractInfo);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Contract Information added successfully!')),
          );
          Navigator.pop(context); // Pop back to SupplierDetailsScreen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding contract: $e')),
          );
          logger.e(
              'Error adding contract for SupplierId: ${widget.supId}', e);
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
      title: 'Add Contract Information',
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
                controller: _contractNoController,
                labelText: 'Contract Number',
                validator: (value) =>
                    value!.isEmpty ? 'Enter Contract Number' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _signedDateController,
                labelText: 'Signed Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _signedDateController),
                validator: (value) =>
                    value!.isEmpty ? 'Enter Signed Date' : null,
              ),
              _buildTextField(
                controller: _validityYrsController,
                labelText: 'Validity Years',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter Validity Years';
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _maxAutoValidityController,
                labelText: 'Max Auto Validity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter Max Auto Validity';
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _stt1PriceController,
                labelText: 'STT1 Price',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter STT1 Price';
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _stt2PriceController,
                labelText: 'STT2 Price',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value!.isEmpty) return 'Enter STT2 Price';
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _pdfUrlMainController,
                labelText: 'Main Contract PDF URL (Optional)',
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
                controller: _pdfUrlAppendix1Controller,
                labelText: 'Appendix 1 PDF URL (Optional)',
                validator: (value) {
                  if (value!.isNotEmpty) {
                    if (!Uri.parse(value).isAbsolute) {
                      return 'Enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContract,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Contract Information'),
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
}
