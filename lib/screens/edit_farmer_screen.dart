// lib/screens/edit_farmer_screen.dart

import 'package:flutter/material.dart';
import 'package:gemini001/models/farmer.dart';
import 'package:gemini001/widgets/custom_text_field.dart';
import 'package:gemini001/database/firestore_helper.dart';

class EditFarmerScreen extends StatefulWidget {
  final Farmer farmer; // The farmer to edit
  final bool isEmbedded; // For navigation context

  const EditFarmerScreen({super.key, required this.farmer, this.isEmbedded = false});

  @override
  State<EditFarmerScreen> createState() => _EditFarmerScreenState();
}

class _EditFarmerScreenState extends State<EditFarmerScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _companyNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _totalFarmSizeController;
  late TextEditingController _monthlyCapacityController;
  late TextEditingController _yearlyCapacityController;

  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<bool> _saveFarmer() async {
    if (_formKey.currentState!.validate()) {
      final updatedFarmer = Farmer(
        id: widget.farmer.id,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        companyName: _companyNameController.text,
        address: _addressController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        totalFarmSize: double.tryParse(_totalFarmSizeController.text) ?? 0.0,
        sellingCapacityPerMonthTons: double.tryParse(_monthlyCapacityController.text) ?? 0.0,
        sellingCapacityPerYearTons: double.tryParse(_yearlyCapacityController.text) ?? 0.0,
      );

      try {
        await _firestoreHelper.updateFarmer(updatedFarmer);
        if (mounted) {
          _showSnackBar('Farmer updated successfully!');
          if (widget.isEmbedded) {
            // Optional: Refresh parent
          } else {
            Navigator.pop(context, true);
          }
        }
        return true;
      } catch (e) {
        if (mounted) {
          _showSnackBar('Error updating farmer: $e');
        }
        return false;
      }
    } else {
      _showSnackBar('Please fill out all fields correctly.');
      return false;
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: CustomTextField(
        controller: controller,
        labelText: labelText,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.farmer.firstName);
    _lastNameController = TextEditingController(text: widget.farmer.lastName);
    _companyNameController = TextEditingController(text: widget.farmer.companyName);
    _addressController = TextEditingController(text: widget.farmer.address);
    _phoneController = TextEditingController(text: widget.farmer.phone);
    _emailController = TextEditingController(text: widget.farmer.email);
    _totalFarmSizeController = TextEditingController(text: widget.farmer.totalFarmSize.toString());
    _monthlyCapacityController = TextEditingController(text: widget.farmer.sellingCapacityPerMonthTons.toString());
    _yearlyCapacityController = TextEditingController(text: widget.farmer.sellingCapacityPerYearTons.toString());
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _totalFarmSizeController.dispose();
    _monthlyCapacityController.dispose();
    _yearlyCapacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Farmer')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    _buildTextField(controller: _firstNameController, labelText: 'First Name'),
                    _buildTextField(controller: _lastNameController, labelText: 'Last Name'),
                    _buildTextField(controller: _companyNameController, labelText: 'Company Name'),
                    _buildTextField(controller: _addressController, labelText: 'Address'),
                    _buildTextField(controller: _phoneController, labelText: 'Phone'),
                    _buildTextField(controller: _emailController, labelText: 'Email'),
                    _buildTextField(controller: _totalFarmSizeController, labelText: 'Total Farm Size (acres)', keyboardType: TextInputType.number),
                    _buildTextField(controller: _monthlyCapacityController, labelText: 'Selling Capacity per Month (tons)', keyboardType: TextInputType.number),
                    _buildTextField(controller: _yearlyCapacityController, labelText: 'Selling Capacity per Year (tons)', keyboardType: TextInputType.number),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _saveFarmer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Update Farmer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
