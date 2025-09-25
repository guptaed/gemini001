import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/announcement.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class AddAnnouncementScreen extends StatefulWidget {
  const AddAnnouncementScreen({super.key});

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _announceIdController = TextEditingController();
  final _announceDateController = TextEditingController();
  final _bidCloseDateController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  final _fuelTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _announceIdController.text = _generateAnnouncementId();
  }

  @override
  void dispose() {
    _announceIdController.dispose();
    _announceDateController.dispose();
    _bidCloseDateController.dispose();
    _deliveryDateController.dispose();
    _fuelTypeController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateAnnouncementId() {
    final now = DateTime.now();
    final random = Random().nextInt(10);
    return '1${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}$random';
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
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

  Future<void> _saveAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      final announcement = Announcement(
        announceId: int.parse(_announceIdController.text),
        announceDate: _announceDateController.text,
        bidCloseDate: _bidCloseDateController.text,
        deliveryDate: _deliveryDateController.text,
        fuelType: _fuelTypeController.text,
        quantity: int.parse(_quantityController.text),
        price: double.parse(_priceController.text),
        status: 'Active', // Hardcoded as per requirement
        notes: _notesController.text,
      );
      try {
        await FirestoreHelper().addAnnouncement(announcement);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Announcement added successfully!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListAnnouncementsScreen()),
          );
          _formKey.currentState!.reset();
          _announceDateController.clear();
          _bidCloseDateController.clear();
          _deliveryDateController.clear();
          _fuelTypeController.clear();
          _quantityController.clear();
          _priceController.clear();
          _notesController.clear();
          setState(() {
            _announceIdController.text = _generateAnnouncementId();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding announcement: $e')),
          );
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
      case 2:
        // Already on AddAnnouncementScreen, do nothing
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



    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    return CommonLayout(
      title: 'Add New Announcement',
      userName: userName,
      selectedPageIndex: 2,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _announceIdController,
                labelText: 'Announcement ID',
                enabled: false,
                fillColor: Colors.grey[300],
                validator: (value) => value!.isEmpty ? 'ID should be generated' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _announceDateController,
                labelText: 'Announce Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _announceDateController),
                validator: (value) => value!.isEmpty ? 'Enter Announce Date' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _bidCloseDateController,
                labelText: 'Bid Close Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _bidCloseDateController),
                validator: (value) => value!.isEmpty ? 'Enter Bid Close Date' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _deliveryDateController,
                labelText: 'Delivery Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _deliveryDateController),
                validator: (value) => value!.isEmpty ? 'Enter Delivery Date' : null,
              ),
              _buildTextField(
                controller: _fuelTypeController,
                labelText: 'Fuel Type',
                validator: (value) => value!.isEmpty ? 'Enter Fuel Type' : null,
              ),
              _buildTextField(
                controller: _quantityController,
                labelText: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter Quantity';
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue <= 0) return 'Enter a positive number';
                  return null;
                },
              ),
              _buildTextField(
                controller: _priceController,
                labelText: 'Price',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter Price';
                  final numValue = double.tryParse(value);
                  if (numValue == null || numValue < 0) return 'Enter a non-negative number';
                  return null;
                },
              ),
              _buildTextField(
                controller: _notesController,
                labelText: 'Notes',
                maxLines: 5,
                validator: null, // Optional field
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveAnnouncement,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Announcement'),
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
        readOnly: true, // Prevent manual editing
        onTap: onTap,
        validator: validator,
      ),
    );
  }
}
