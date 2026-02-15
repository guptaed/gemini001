import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/fuel_type.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/list_fuel_types_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/utils/logging.dart';
import 'package:vietfuel_shared/vietfuel_shared.dart' show FieldChange;

class AddFuelTypeScreen extends StatefulWidget {
  final FuelType? fuelType; // null = add mode, non-null = edit mode

  const AddFuelTypeScreen({super.key, this.fuelType});

  @override
  State<AddFuelTypeScreen> createState() => _AddFuelTypeScreenState();
}

class _AddFuelTypeScreenState extends State<AddFuelTypeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fuelTypeIdController = TextEditingController();
  final _fuelTypeNameController = TextEditingController();
  final _fuelTypeNameViController = TextEditingController();
  final _subcategoryController = TextEditingController();
  final _unitOfMeasureController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Wood';
  String _selectedCertification = 'Non-Certified';
  bool _isActive = true;

  bool get _isEditMode => widget.fuelType != null;

  static const _categories = ['Wood', 'Agricultural Residue', 'Other Biomass'];
  static const _certifications = ['Certified', 'Non-Certified', 'N/A'];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final ft = widget.fuelType!;
      _fuelTypeIdController.text = ft.FuelTypeId;
      _fuelTypeNameController.text = ft.FuelTypeName;
      _fuelTypeNameViController.text = ft.FuelTypeNameVi;
      _selectedCategory = _categories.contains(ft.Category) ? ft.Category : 'Wood';
      _subcategoryController.text = ft.Subcategory;
      _selectedCertification = _certifications.contains(ft.CertificationStatus) ? ft.CertificationStatus : 'Non-Certified';
      _unitOfMeasureController.text = ft.UnitOfMeasure;
      _descriptionController.text = ft.Description;
      _isActive = ft.IsActive;
    } else {
      _unitOfMeasureController.text = 'ton';
    }
  }

  @override
  void dispose() {
    _fuelTypeIdController.dispose();
    _fuelTypeNameController.dispose();
    _fuelTypeNameViController.dispose();
    _subcategoryController.dispose();
    _unitOfMeasureController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<FieldChange> _detectChanges() {
    final existing = widget.fuelType!;
    final changes = <FieldChange>[];

    if (_fuelTypeNameController.text.trim() != existing.FuelTypeName) {
      changes.add(FieldChange(fieldName: 'FuelTypeName', fieldLabel: 'Fuel Type Name', oldValue: existing.FuelTypeName, newValue: _fuelTypeNameController.text.trim()));
    }
    if (_fuelTypeNameViController.text.trim() != existing.FuelTypeNameVi) {
      changes.add(FieldChange(fieldName: 'FuelTypeNameVi', fieldLabel: 'Vietnamese Name', oldValue: existing.FuelTypeNameVi, newValue: _fuelTypeNameViController.text.trim()));
    }
    if (_selectedCategory != existing.Category) {
      changes.add(FieldChange(fieldName: 'Category', fieldLabel: 'Category', oldValue: existing.Category, newValue: _selectedCategory));
    }
    if (_subcategoryController.text.trim() != existing.Subcategory) {
      changes.add(FieldChange(fieldName: 'Subcategory', fieldLabel: 'Subcategory', oldValue: existing.Subcategory, newValue: _subcategoryController.text.trim()));
    }
    if (_selectedCertification != existing.CertificationStatus) {
      changes.add(FieldChange(fieldName: 'CertificationStatus', fieldLabel: 'Certification Status', oldValue: existing.CertificationStatus, newValue: _selectedCertification));
    }
    if (_unitOfMeasureController.text.trim() != existing.UnitOfMeasure) {
      changes.add(FieldChange(fieldName: 'UnitOfMeasure', fieldLabel: 'Unit of Measure', oldValue: existing.UnitOfMeasure, newValue: _unitOfMeasureController.text.trim()));
    }
    if (_descriptionController.text.trim() != existing.Description) {
      changes.add(FieldChange(fieldName: 'Description', fieldLabel: 'Description', oldValue: existing.Description, newValue: _descriptionController.text.trim()));
    }
    if (_isActive != existing.IsActive) {
      changes.add(FieldChange(fieldName: 'IsActive', fieldLabel: 'Active', oldValue: existing.IsActive.toString(), newValue: _isActive.toString()));
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
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

  Future<void> _showMessageDialog({required String title, required String message, bool isError = false}) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red[700] : Colors.green[700],
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
          ),
          content: Text(message),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal[700], foregroundColor: Colors.white),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveFuelType() async {
    if (_formKey.currentState!.validate()) {
      // Edit mode: detect changes and show confirmation
      if (_isEditMode) {
        final changes = _detectChanges();

        if (changes.isEmpty) {
          await _showMessageDialog(
            title: 'No Changes',
            message: 'No modifications were made to the fuel type.',
          );
          return;
        }

        final confirmed = await _showConfirmationDialog(changes);
        if (!confirmed) return;

        try {
          final updatedFuelType = FuelType(
            id: widget.fuelType!.id,
            FuelTypeId: _fuelTypeIdController.text.trim(),
            FuelTypeName: _fuelTypeNameController.text.trim(),
            FuelTypeNameVi: _fuelTypeNameViController.text.trim(),
            Category: _selectedCategory,
            Subcategory: _subcategoryController.text.trim(),
            CertificationStatus: _selectedCertification,
            UnitOfMeasure: _unitOfMeasureController.text.trim(),
            Description: _descriptionController.text.trim(),
            IsActive: _isActive,
          );
          await FirestoreHelper().updateFuelType(updatedFuelType);
          if (mounted) {
            await _showMessageDialog(
              title: 'Success',
              message: 'Fuel type updated successfully!',
            );
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ListFuelTypesScreen()),
              );
            }
          }
        } catch (e) {
          if (mounted) {
            await _showMessageDialog(
              title: 'Error',
              message: 'Error updating fuel type: $e',
              isError: true,
            );
            logger.e('Error updating fuel type: $e');
          }
        }
        return;
      }

      // Add mode: save directly
      final fuelType = FuelType(
        id: null,
        FuelTypeId: _fuelTypeIdController.text.trim(),
        FuelTypeName: _fuelTypeNameController.text.trim(),
        FuelTypeNameVi: _fuelTypeNameViController.text.trim(),
        Category: _selectedCategory,
        Subcategory: _subcategoryController.text.trim(),
        CertificationStatus: _selectedCertification,
        UnitOfMeasure: _unitOfMeasureController.text.trim(),
        Description: _descriptionController.text.trim(),
        IsActive: _isActive,
      );
      try {
        await FirestoreHelper().addFuelType(fuelType);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fuel type added successfully!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListFuelTypesScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding fuel type: $e')),
          );
          logger.e('Error adding fuel type: $e');
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
        // Already on AddFuelTypeScreen
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    return CommonLayout(
      title: _isEditMode ? 'Edit Fuel Type' : 'Add New Fuel Type',
      userName: userName,
      selectedPageIndex: 12,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _fuelTypeIdController,
                labelText: 'Fuel Type Code (e.g. WC-NC-001)',
                enabled: !_isEditMode,
                fillColor: _isEditMode ? Colors.grey[300] : null,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a fuel type code' : null,
              ),
              _buildTextField(
                controller: _fuelTypeNameController,
                labelText: 'Fuel Type Name',
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a fuel type name' : null,
              ),
              _buildTextField(
                controller: _fuelTypeNameViController,
                labelText: 'Vietnamese Name (optional)',
                validator: null,
              ),
              // Category dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
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
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value ?? 'Wood'),
                ),
              ),
              _buildTextField(
                controller: _subcategoryController,
                labelText: 'Subcategory (e.g. Chips, Pellets, Husk)',
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter a subcategory' : null,
              ),
              // Certification dropdown
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedCertification,
                  decoration: InputDecoration(
                    labelText: 'Certification Status',
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
                  items: _certifications.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => _selectedCertification = value ?? 'Non-Certified'),
                ),
              ),
              _buildTextField(
                controller: _unitOfMeasureController,
                labelText: 'Unit of Measure (e.g. ton, m3)',
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter unit of measure' : null,
              ),
              _buildTextField(
                controller: _descriptionController,
                labelText: 'Description (optional)',
                maxLines: 3,
                validator: null,
              ),
              // Active toggle
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: SwitchListTile(
                  title: const Text('Active'),
                  subtitle: Text(_isActive ? 'This fuel type is available for use' : 'This fuel type is inactive'),
                  value: _isActive,
                  activeThumbColor: Colors.teal[700],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey[400]!, width: 1.0),
                  ),
                  onChanged: (value) => setState(() => _isActive = value),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveFuelType,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(_isEditMode ? 'Update Fuel Type' : 'Save Fuel Type'),
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
    String? Function(String?)? validator,
    int? maxLines,
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
}
