import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/bid.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/announcement.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';

class AddBidScreen extends StatefulWidget {
  const AddBidScreen({super.key});

  @override
  State<AddBidScreen> createState() => _AddBidScreenState();
}

class _AddBidScreenState extends State<AddBidScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedSupId;
  int? _selectedAnnounceId;
  int? _selectedAnnouncementQuantity; // To store selected announcement's Quantity
  final _bidIdController = TextEditingController();
  final _submittedDateController = TextEditingController();
  final _quantityController = TextEditingController();
  final _quantityAcceptedController = TextEditingController();
  final _acceptRejectDateController = TextEditingController();
  final _notesController = TextEditingController();
  late Stream<List<Supplier>> _suppliersStream;
  late Stream<List<Announcement>> _announcementsStream;

  @override
  void initState() {
    super.initState();
    _bidIdController.text = _generateBidId();
    _suppliersStream = FirestoreHelper().streamSuppliers();
    _announcementsStream = FirestoreHelper().streamAnnouncements();
  }

  @override
  void dispose() {
    _bidIdController.dispose();
    _submittedDateController.dispose();
    _quantityController.dispose();
    _quantityAcceptedController.dispose();
    _acceptRejectDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _generateBidId() {
    final now = DateTime.now();
    final random = Random().nextInt(10);
    return '2${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}$random';
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

  Future<void> _saveBid() async {
    if (_formKey.currentState!.validate()) {
      final bid = Bid(
        supId: _selectedSupId!,
        announceId: _selectedAnnounceId!,
        bidId: int.parse(_bidIdController.text),
        submittedDate: _submittedDateController.text,
        quantity: int.parse(_quantityController.text),
        status: 'Submitted', // Hardcoded as per requirement
        quantityAccepted: _quantityAcceptedController.text.isEmpty ? 0 : int.parse(_quantityAcceptedController.text),
        acceptRejectDate: _acceptRejectDateController.text,
        notes: _notesController.text,
      );
      try {
        await FirestoreHelper().addBid(bid);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bid added successfully!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListBidsScreen()),
          );
          _formKey.currentState!.reset();
          setState(() {
            _selectedSupId = null;
            _selectedAnnounceId = null;
            _selectedAnnouncementQuantity = null;
            _bidIdController.text = _generateBidId();
            _submittedDateController.clear();
            _quantityController.clear();
            _quantityAcceptedController.clear();
            _acceptRejectDateController.clear();
            _notesController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding bid: $e')),
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
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddSupplierScreen()),
        );
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
        // Already on AddBidScreen, do nothing
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
    final theme = Theme.of(context);
    return CommonLayout(
      title: 'Add New Bid',
      userName: userName,
      selectedPageIndex: 4,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _bidIdController,
                labelText: 'Bid ID',
                enabled: false,
                fillColor: Colors.grey[300],
                validator: (value) => value!.isEmpty ? 'ID should be generated' : null,
              ),
              _buildSupplierDropdown(theme),
              _buildAnnouncementDropdown(theme),
              _buildTextFieldWithDatePicker(
                controller: _submittedDateController,
                labelText: 'Submitted Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _submittedDateController),
                validator: (value) => value!.isEmpty ? 'Enter Submitted Date' : null,
              ),
              _buildTextField(
                controller: _quantityController,
                labelText: 'Quantity',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter Quantity';
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue <= 0) return 'Enter a positive number';
                  if (_selectedAnnouncementQuantity != null && numValue > _selectedAnnouncementQuantity!) {
                    return 'Quantity must be less than or equal to $_selectedAnnouncementQuantity';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _quantityAcceptedController,
                labelText: 'Quantity Accepted (Optional)',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final numValue = int.tryParse(value);
                  if (numValue == null || numValue < 0) return 'Enter a non-negative number';
                  return null;
                },
              ),
              _buildTextFieldWithDatePicker(
                controller: _acceptRejectDateController,
                labelText: 'Accept/Reject Date (Optional, YYYY-MM-DD)',
                onTap: () => _selectDate(context, _acceptRejectDateController),
                validator: null,
              ),
              _buildTextField(
                controller: _notesController,
                labelText: 'Notes',
                maxLines: 5,
                validator: null, // Optional field
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
                  onPressed: _saveBid,
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
                    'Save Bid',
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

  Widget _buildSupplierDropdown(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownSearch<Supplier>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: 'Search Supplier ID or Name',
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
          ),
          emptyBuilder: (context, searchEntry) => const Center(child: Text('No suppliers found')),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Supplier ID',
            hintText: 'Select Supplier',
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
        ),
        asyncItems: (String filter) async {
          try {
            final suppliers = await _suppliersStream.first;
            if (suppliers.isEmpty) return [];
            return suppliers.where((supplier) {
              final searchText = filter.toLowerCase();
              return supplier.SupId.toString().contains(searchText) ||
                  supplier.CompanyName.toLowerCase().contains(searchText);
            }).toList();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading suppliers: $e')),
              );
            }
            return [];
          }
        },
        itemAsString: (Supplier supplier) => '${supplier.SupId} - ${supplier.CompanyName}',
        onChanged: (Supplier? supplier) {
          setState(() {
            _selectedSupId = supplier?.SupId;
          });
        },
        validator: (Supplier? value) => value == null ? 'Select a Supplier' : null,
      ),
    );
  }

  Widget _buildAnnouncementDropdown(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownSearch<Announcement>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: 'Search Announcement ID, Fuel Type, or Quantity',
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
          ),
          emptyBuilder: (context, searchEntry) => const Center(child: Text('No announcements found')),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Announcement ID',
            hintText: 'Select Announcement',
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
        ),
        asyncItems: (String filter) async {
          try {
            final announcements = await _announcementsStream.first;
            if (announcements.isEmpty) return [];
            return announcements.where((announcement) {
              final searchText = filter.toLowerCase();
              return announcement.announceId.toString().contains(searchText) ||
                  announcement.fuelType.toLowerCase().contains(searchText) ||
                  announcement.quantity.toString().contains(searchText);
            }).toList();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading announcements: $e')),
              );
            }
            return [];
          }
        },
        itemAsString: (Announcement announcement) => '${announcement.announceId} - ${announcement.fuelType} (Quantity: ${announcement.quantity})',
        onChanged: (Announcement? announcement) {
          setState(() {
            _selectedAnnounceId = announcement?.announceId;
            _selectedAnnouncementQuantity = announcement?.quantity;
          });
        },
        validator: (Announcement? value) => value == null ? 'Select an Announcement' : null,
      ),
    );
  }
}
