import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/supplier.dart';
import 'dart:math';

class AddSupplierScreen extends StatefulWidget {
  final bool isPushed;

  const AddSupplierScreen({super.key, this.isPushed = false});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();
  final _formKey = GlobalKey<FormState>();
  final _supIdController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _telController = TextEditingController();
  final _emailController = TextEditingController();
  final _taxCodeController = TextEditingController();
  final _representativeController = TextEditingController();
  final _titleController = TextEditingController();
  String? _selectedStatus;

  // List of status options
  final List<String> _statusOptions = ['New', 'CreditCheckOk', 'ContractSigned'];

  @override
  void initState() {
    super.initState();
    // Generate and set Supplier ID on screen load
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

  // Generate Supplier ID in format YYYYMMDDHHMMX
  String _generateSupplierId() {
    final now = DateTime.now();
    final random = Random().nextInt(10); // Random digit 0-9
    final id = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}$random';
    return id; // Will be parsed to int later
  }

  void _saveSupplier() async {
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
        Status: _selectedStatus!,
      );

      try {
        await _firestoreHelper.addSupplier(supplier);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Supplier added successfully!')));
        if (widget.isPushed) {
          Navigator.pop(context, true);
        } else {
          // Reset all fields
          _formKey.currentState!.reset();
          _companyNameController.clear();
          _addressController.clear();
          _telController.clear();
          _emailController.clear();
          _taxCodeController.clear();
          _representativeController.clear();
          _titleController.clear();
          setState(() {
            _selectedStatus = 'New'; // Reset dropdown to default
            _supIdController.text = _generateSupplierId(); // Generate new ID
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error adding supplier: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedStatus, // Updated from value to initialValue
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
                  items: _statusOptions.map((String status) {
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
                  validator: (value) => value == null ? 'Please select a status' : null,
                ),
              ),
              
              const SizedBox(height: 20),

              ElevatedButton(                                                               // The "Save" button.
                onPressed: _saveSupplier,                                                     // Call `_saveFarmer` when pressed.
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                ),
                child: const Text('Save Supplier'),
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