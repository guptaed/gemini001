import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/bid.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/shipment.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';

class AddShipmentScreen extends StatefulWidget {
  const AddShipmentScreen({super.key});

  @override
  State<AddShipmentScreen> createState() => _AddShipmentScreenState();
}

class _AddShipmentScreenState extends State<AddShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedSupId;
  String? _selectedSupplierName;
  int? _selectedBidId;
  String? _selectedStatus;
  final _shipmentIdController = TextEditingController();
  final _shippedDateController = TextEditingController();
  final _receivedDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _supplierController = TextEditingController();
  late Stream<List<Supplier>> _suppliersStream;
  late Stream<List<Bid>> _bidsStream;

  @override
  void initState() {
    super.initState();
    _shipmentIdController.text = _generateShipmentId();
    _suppliersStream = FirestoreHelper().streamSuppliers();
    _bidsStream = FirestoreHelper().streamBids();
  }

  @override
  void dispose() {
    _shipmentIdController.dispose();
    _shippedDateController.dispose();
    _receivedDateController.dispose();
    _notesController.dispose();
    _supplierController.dispose();
    super.dispose();
  }

  String _generateShipmentId() {
    final now = DateTime.now();
    final random = Random().nextInt(10);
    return '3${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}$random';
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

  Future<void> _saveShipment() async {
    if (_formKey.currentState!.validate()) {
      final shipment = Shipment(
        ShipmentId: _shipmentIdController.text,
        SupId: _selectedSupId!,
        BidId: _selectedBidId!,
        Status: _selectedStatus!,
        ShippedDate: _shippedDateController.text,
        ReceivedDate: _receivedDateController.text,
        Notes: _notesController.text,
      );
      try {
        await FirestoreHelper().addShipment(shipment);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shipment added successfully!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ListShipmentsScreen()),
          );
          _formKey.currentState!.reset();
          setState(() {
            _selectedSupId = null;
            _selectedSupplierName = null;
            _selectedBidId = null;
            _selectedStatus = null;
            _shipmentIdController.text = _generateShipmentId();
            _shippedDateController.clear();
            _receivedDateController.clear();
            _notesController.clear();
            _supplierController.clear();
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding shipment: $e')),
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
        // Already on AddShipmentScreen
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
      title: 'Add New Shipment',
      userName: userName,
      selectedPageIndex: 6,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(
                controller: _shipmentIdController,
                labelText: 'Shipment ID',
                enabled: false,
                fillColor: Colors.grey[300],
                validator: (value) => value!.isEmpty ? 'ID should be generated' : null,
              ),
              _buildBidDropdown(theme),
              _buildSupplierField(theme),
              _buildStatusDropdown(theme),
              _buildTextFieldWithDatePicker(
                controller: _shippedDateController,
                labelText: 'Shipped Date (YYYY-MM-DD)',
                onTap: () => _selectDate(context, _shippedDateController),
                validator: (value) => value!.isEmpty ? 'Enter Shipped Date' : null,
              ),
              _buildTextFieldWithDatePicker(
                controller: _receivedDateController,
                labelText: 'Received Date (Optional, YYYY-MM-DD)',
                onTap: () => _selectDate(context, _receivedDateController),
                validator: null,
              ),
              _buildTextField(
                controller: _notesController,
                labelText: 'Notes (Optional)',
                maxLines: 5,
                validator: null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveShipment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Save Shipment'),
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
        readOnly: true,
        onTap: onTap,
        validator: validator,
      ),
    );
  }

  Widget _buildSupplierField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _supplierController,
        decoration: InputDecoration(
          labelText: 'Supplier',
          hintText: 'Select a Bid to populate Supplier',
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.teal[700]!, width: 2.0),
          ),
          filled: true,
          fillColor: Colors.grey[300],
        ),
        enabled: false,
        validator: (value) => value!.isEmpty ? 'Select a Bid to populate Supplier' : null,
      ),
    );
  }

  Widget _buildBidDropdown(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownSearch<Bid>(
        popupProps: PopupProps.menu(
          showSearchBox: true,
          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              labelText: 'Search Bid ID or Supplier ID',
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
          emptyBuilder: (context, searchEntry) => const Center(child: Text('No bids found')),
        ),
        dropdownDecoratorProps: DropDownDecoratorProps(
          dropdownSearchDecoration: InputDecoration(
            labelText: 'Bid ID',
            hintText: 'Select Bid',
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
            final bids = await _bidsStream.first;
            if (bids.isEmpty) return [];
            return bids.where((bid) {
              final searchText = filter.toLowerCase();
              return bid.bidId.toString().contains(searchText) ||
                  bid.supId.toString().contains(searchText);
            }).toList();
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading bids: $e')),
              );
            }
            return [];
          }
        },
        itemAsString: (Bid bid) => '${bid.bidId} - SupId: ${bid.supId}, AnnounceId: ${bid.announceId}',
        onChanged: (Bid? bid) async {
          if (bid != null) {
            try {
              final suppliers = await _suppliersStream.first;
              final supplier = suppliers.firstWhere(
                (sup) => sup.SupId == bid.supId,
                orElse: () => Supplier(
                  SupId: 0,
                  CompanyName: 'Unknown',
                  Address: '',
                  Tel: '',
                  Email: '',
                  TaxCode: '',
                  Representative: '',
                  Title: '',
                  Status: '',
                ),
              );
              setState(() {
                _selectedBidId = bid.bidId;
                _selectedSupId = bid.supId;
                _selectedSupplierName = supplier.CompanyName;
                _supplierController.text = '${bid.supId} - ${supplier.CompanyName}';
              });
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error loading supplier: $e')),
                );
              }
            }
          } else {
            setState(() {
              _selectedBidId = null;
              _selectedSupId = null;
              _selectedSupplierName = null;
              _supplierController.clear();
            });
          }
        },
        validator: (Bid? value) => value == null ? 'Select a Bid' : null,
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
        items: ['Shipped', 'Received'].map((String status) {
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
