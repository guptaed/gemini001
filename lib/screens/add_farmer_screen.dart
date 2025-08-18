// lib/screens/add_farmer_screen.dart

import 'package:flutter/material.dart';                                                      
import 'package:gemini001/models/farmer.dart';                                                // Importing our `Farmer` model.
import 'package:gemini001/widgets/custom_text_field.dart';                                    // Importing our custom `CustomTextField` widget.
import 'package:gemini001/database/firestore_helper.dart';                                    // Importing our new Firestore helper.


class AddFarmerScreen extends StatefulWidget {                                                // `AddFarmerScreen` is a `StatefulWidget`. it manages the state of the form's input fields.
  const AddFarmerScreen({super.key});                                                         // Constructor for AddFarmerScreen.
  @override
  State<AddFarmerScreen> createState() => _AddFarmerScreenState();                            // Creates the mutable state for this widget.
}

class _AddFarmerScreenState extends State<AddFarmerScreen> {                                  // `_AddFarmerScreenState` holds the mutable state for `AddFarmerScreen`.
  
  final _formKey = GlobalKey<FormState>();                                                    // `_formKey` is a `GlobalKey` that uniquely identifies the `Form` widget. used to validate the form fields.

  final _firstNameController = TextEditingController();                                       // `TextEditingController`s for each text input field in the form.
  final _lastNameController = TextEditingController();                                        // This is provided in: package:flutter/src/widgets/editable_text.dart
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _totalFarmSizeController = TextEditingController();
  final _monthlyCapacityController = TextEditingController();
  final _yearlyCapacityController = TextEditingController();

  final FirestoreHelper _firestoreHelper = FirestoreHelper();                                 // Instance of our new Firestore helper.

  void _showSnackBar(String message) {                                                        // `_showSnackBar` is a helper method to show a confirmation message.    
    ScaffoldMessenger.of(context).showSnackBar(                                               // `ScaffoldMessenger` is used to manage `SnackBar`s.
      SnackBar(content: Text(message)),
    );
  }

  
  Future<void> _saveFarmer() async {                                                          // `_saveFarmer` method: Handles the logic for saving the farmer data.
    
    if (_formKey.currentState!.validate()) {                                                  // Check if the form is valid. `validate()` returns true if all validators pass.
      
      final newFarmer = Farmer(                                                               // Create a `Farmer` object from the data in the controllers.
        id: null,                                                                             // ID is handled by Firestore automatically.
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

      await _firestoreHelper.addFarmer(newFarmer);                                            // Use the new Firestore helper to add the farmer.
      _showSnackBar('Farmer added successfully!');                                            // Show a confirmation message.

      _formKey.currentState!.reset();                                                         // Reset the form fields after successful save.
      
      _firstNameController.clear();                                                           // Clear the text controllers.
      _lastNameController.clear();
      _companyNameController.clear();
      _addressController.clear();
      _phoneController.clear();
      _emailController.clear();
      _totalFarmSizeController.clear();
      _monthlyCapacityController.clear();
      _yearlyCapacityController.clear();

    }
  }

  
  Widget _buildTextField({                                                                    // `_buildTextField` is a helper function to build our `CustomTextField`s.
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
        
        validator: (value) {                                                                 // The validator ensures the field is not empty.
          if (value == null || value.isEmpty) {
            return 'Please enter $labelText';
          }
          return null;
        },
      ),
    );
  }

  
  @override                                                                                   // `dispose` method: Called when this `State` object is removed permanently.
  void dispose() {                                                                            // It's important to dispose of all `TextEditingController`s to prevent memory leaks.
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
  Widget build(BuildContext context) {                                                        // The `build` method describes the UI.
    return Padding(      
      padding: const EdgeInsets.all(16.0),                                                    // Padding around the entire form.
      child: Center(
        child: SingleChildScrollView(          
          child: ConstrainedBox(                                                              // Constrains the width of the form for better desktop layout.
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,                                                                  // Assign the key to the form.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,                               // Stretch children horizontally.
                children: <Widget>[
                                                                                              // Our custom text fields.
                  _buildTextField(controller: _firstNameController, labelText: 'First Name'),
                  _buildTextField(controller: _lastNameController, labelText: 'Last Name'),
                  _buildTextField(controller: _companyNameController, labelText: 'Company Name'),
                  _buildTextField(controller: _addressController, labelText: 'Address'),
                  _buildTextField(controller: _phoneController, labelText: 'Phone'),
                  _buildTextField(controller: _emailController, labelText: 'Email'),
                  _buildTextField(controller: _totalFarmSizeController, labelText: 'Total Farm Size (acres)', keyboardType: TextInputType.number,),
                  _buildTextField(controller: _monthlyCapacityController,
                    labelText: 'Selling Capacity per Month (tons)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(controller: _yearlyCapacityController,
                    labelText: 'Selling Capacity per Year (tons)',
                    keyboardType: TextInputType.number,
                  ),
                  
                  const SizedBox(height: 16), // Spacing before the button.
                  
                  ElevatedButton(                                                               // The "Save" button.
                    onPressed: _saveFarmer,                                                     // Call `_saveFarmer` when pressed.
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8),),
                    ),
                    child: const Text('Save Farmer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
