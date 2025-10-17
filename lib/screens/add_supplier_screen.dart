import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'dart:math';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:gemini001/utils/logging.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _supIdController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _representativeController = TextEditingController();
  final _titleController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _supIdController.text = _generateSupplierId();
  }

  @override
  void dispose() {
    _supIdController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    _telController.dispose();
    _emailController.dispose();
    _taxCodeController.dispose();
    _representativeController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  String _generateSupplierId() {
    final now = DateTime.now();
    final random = Random().nextInt(10);
    return '5${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}$random';
  }

  Future<void> _saveSupplier() async {
    if (_formKey.currentState!.validate()) {
      final supplier = Supplier(
        SupId: int.parse(_supIdController.text),
        CompanyName: _companyNameController.text,
        Address: _addressController.text,
        Tel: _telController.text,
        Email: _emailController.text,
        TaxCode: _taxCodeController.text,
        Representative: _representativeController.text,
        Title: _titleController.text,
        Status: 'New',
      );
      try {
        await FirestoreHelper().addSupplier(supplier);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier added successfully!')));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListSuppliersScreen()),
          );
          _formKey.currentState!.reset();
          _companyNameController.clear();
          _addressController.clear();
          _telController.clear();
          _emailController.clear();
          _taxCodeController.clear();
          _representativeController.clear();
          _titleController.clear();
          setState(() {
            _supIdController.text = _generateSupplierId();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding supplier: $e')));
          logger.e('Error adding supplier with SupId: ${supplier.SupId}', e);
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
        // Already on AddSupplierScreen, do nothing
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddAnnouncementScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ListAnnouncementsScreen()),
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
          MaterialPageRoute(builder: (context) => const SupplierOnboardingDashboard()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    return CommonLayout(
      title: 'Add New Supplier',
      userName: userName,
      selectedPageIndex: 1,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _supIdController,
                labelText: 'Supplier ID',
                enabled: false,
                fillColor: Colors.grey[300],
                validator: (value) => value!.isEmpty ? 'ID should be generated' : null,
              ),
              _buildTextField(
                controller: TextEditingController(text: 'New'),
                labelText: 'Status',
                enabled: false,
                fillColor: Colors.grey[300],
              ),              
              _buildTextField(
                controller: _companyNameController,
                labelText: 'Company Name',
                validator: (value) => value!.isEmpty ? 'Enter Company Name' : null,
              ),
              _buildTextField(
                controller: _representativeController,
                labelText: 'Representative',
              ),
              _buildTextField(
                controller: _titleController,
                labelText: 'Title',
              ),
              _buildTextField(
                controller: _addressController,
                labelText: 'Address',
              ),
              _buildTextField(
                controller: _telController,
                labelText: 'Telephone',
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
              ),
              _buildTextField(
                controller: _taxCodeController,
                labelText: 'Tax Code',
              ),
              const SizedBox(height: 20),
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
                      color: Colors.teal[700]!.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: _saveSupplier,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Supplier',
                    style: TextStyle(
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
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    int? maxLength,
    TextInputAction? textInputAction = TextInputAction.next,
    bool enabled = true,
    Color? fillColor,
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
          filled: !enabled,
          fillColor: fillColor ?? Colors.grey[300],
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        textInputAction: textInputAction,
        enabled: enabled,
        validator: validator ?? (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }
}