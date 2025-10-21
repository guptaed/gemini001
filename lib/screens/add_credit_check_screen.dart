import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/credit_check.dart';
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

class AddCreditCheckScreen extends StatefulWidget {
  final int supId;
  final String companyName;

  const AddCreditCheckScreen({
    super.key,
    required this.supId,
    required this.companyName,
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
  String? _selectedStatus;

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

  Future<void> _saveCreditCheck() async {
    if (_formKey.currentState!.validate()) {
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
            const SnackBar(content: Text('Credit Check added successfully!')),
          );
          Navigator.pop(context); // Pop back to SupplierDetailsScreen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding credit check: $e')),
          );
          logger.e(
              'Error adding credit check for SupplierId: ${widget.supId}', e);
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
      title: 'Add Credit Check Information',
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
              ElevatedButton(
                onPressed: _saveCreditCheck,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Credit Check'),
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
