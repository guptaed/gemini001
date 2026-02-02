import 'package:flutter/material.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/database/storage_helper.dart';
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
import 'dart:typed_data';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:gemini001/utils/logging.dart';
import 'package:file_picker/file_picker.dart';

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

  // PDF upload state
  Uint8List? _pdfBytes1;
  Uint8List? _pdfBytes2;
  Uint8List? _pdfBytes3;
  String? _pdfFileName1;
  String? _pdfFileName2;
  String? _pdfFileName3;

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

  // Show a dialog that requires user acknowledgment
  Future<void> _showMessageDialog({
    required String title,
    required String message,
    bool isError = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError ? Colors.red : Colors.green,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isError ? Colors.red[700] : Colors.green[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(message),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // Pick a PDF file
  Future<void> _pickPDF(int fieldNumber) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true, // This ensures bytes are loaded for web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;

        // Check if bytes are available
        if (fileBytes == null) {
          if (mounted) {
            await _showMessageDialog(
              title: 'Error',
              message: 'Could not read file data. Please try selecting the file again.',
              isError: true,
            );
          }
          return;
        }

        // Check file size (10 MB limit)
        final fileSize = fileBytes.length;
        const maxSize = 10 * 1024 * 1024; // 10 MB

        if (fileSize > maxSize) {
          if (mounted) {
            await _showMessageDialog(
              title: 'File Too Large',
              message: 'The selected file exceeds the 10 MB size limit.\n\nFile size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB\nMaximum allowed: 10 MB',
              isError: true,
            );
          }
          return;
        }

        setState(() {
          if (fieldNumber == 1) {
            _pdfBytes1 = fileBytes;
            _pdfFileName1 = fileName;
          } else if (fieldNumber == 2) {
            _pdfBytes2 = fileBytes;
            _pdfFileName2 = fileName;
          } else if (fieldNumber == 3) {
            _pdfBytes3 = fileBytes;
            _pdfFileName3 = fileName;
          }
        });
      }
    } catch (e) {
      logger.e('Error picking PDF: $e');
      if (mounted) {
        await _showMessageDialog(
          title: 'Error',
          message: 'Error selecting file:\n\n$e',
          isError: true,
        );
      }
    }
  }

  // Clear a PDF file
  void _clearPDF(int fieldNumber) {
    setState(() {
      if (fieldNumber == 1) {
        _pdfBytes1 = null;
        _pdfFileName1 = null;
      } else if (fieldNumber == 2) {
        _pdfBytes2 = null;
        _pdfFileName2 = null;
      } else if (fieldNumber == 3) {
        _pdfBytes3 = null;
        _pdfFileName3 = null;
      }
    });
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
        // First, save the supplier to Firestore
        await FirestoreHelper().addSupplier(supplier);

        // Upload PDFs if any are selected
        String? uploadedPDF1;
        String? uploadedPDF2;
        String? uploadedPDF3;
        final errors = <String>[];

        if (_pdfBytes1 != null && _pdfFileName1 != null) {
          try {
            uploadedPDF1 = await StorageHelper().uploadPDF(
              fileBytes: _pdfBytes1!,
              fileName: _pdfFileName1!,
              supplierId: supplier.SupId,
              fieldNumber: 1,
            );
          } catch (e) {
            logger.e('Error uploading PDF 1: $e');
            errors.add('Supporting PDF 1 ($_pdfFileName1): $e');
          }
        }

        if (_pdfBytes2 != null && _pdfFileName2 != null) {
          try {
            uploadedPDF2 = await StorageHelper().uploadPDF(
              fileBytes: _pdfBytes2!,
              fileName: _pdfFileName2!,
              supplierId: supplier.SupId,
              fieldNumber: 2,
            );
          } catch (e) {
            logger.e('Error uploading PDF 2: $e');
            errors.add('Supporting PDF 2 ($_pdfFileName2): $e');
          }
        }

        if (_pdfBytes3 != null && _pdfFileName3 != null) {
          try {
            uploadedPDF3 = await StorageHelper().uploadPDF(
              fileBytes: _pdfBytes3!,
              fileName: _pdfFileName3!,
              supplierId: supplier.SupId,
              fieldNumber: 3,
            );
          } catch (e) {
            logger.e('Error uploading PDF 3: $e');
            errors.add('Supporting PDF 3 ($_pdfFileName3): $e');
          }
        }

        // Update supplier with PDF filenames if any were uploaded
        if (uploadedPDF1 != null || uploadedPDF2 != null || uploadedPDF3 != null) {
          // Get the supplier from Firestore to get its document ID
          final savedSupplier = await FirestoreHelper().getSupplierBySupId(supplier.SupId);
          if (savedSupplier != null) {
            final updatedSupplier = savedSupplier.copyWith(
              SupportingPDF1: uploadedPDF1,
              SupportingPDF2: uploadedPDF2,
              SupportingPDF3: uploadedPDF3,
            );
            await FirestoreHelper().updateSupplier(updatedSupplier);
          }
        }

        if (mounted) {
          // Show success message with any errors
          String title;
          String message;
          bool isError = false;

          if (errors.isEmpty) {
            title = 'Success';
            message = 'Supplier added successfully!';
          } else {
            title = 'Partial Success';
            message = 'Supplier was added successfully, but some PDF files failed to upload:\n\n';
            message += errors.map((e) => '• $e').join('\n');
            message += '\n\nPlease check Firebase Storage permissions or try uploading the files again later.';
            isError = true;
          }

          await _showMessageDialog(
            title: title,
            message: message,
            isError: isError,
          );

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ListSuppliersScreen()),
            );
          }
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
            _pdfBytes1 = null;
            _pdfBytes2 = null;
            _pdfBytes3 = null;
            _pdfFileName1 = null;
            _pdfFileName2 = null;
            _pdfFileName3 = null;
          });
        }
      } catch (e) {
        logger.e('Error adding supplier with SupId: ${supplier.SupId}', e);
        if (mounted) {
          await _showMessageDialog(
            title: 'Error',
            message: 'Failed to add supplier:\n\n$e',
            isError: true,
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
        // Already on AddSupplierScreen, do nothing
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
                validator: (value) =>
                    value!.isEmpty ? 'ID should be generated' : null,
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
                validator: (value) =>
                    value!.isEmpty ? 'Enter Company Name' : null,
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
              const SizedBox(height: 30),
              // Supporting Documents Section
              Text(
                'Supporting Documents (Optional)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[700],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Upload up to 3 PDF files (Max 10 MB each)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildPDFUploadField(
                labelText: 'Supporting PDF 1',
                fieldNumber: 1,
                fileName: _pdfFileName1,
              ),
              _buildPDFUploadField(
                labelText: 'Supporting PDF 2',
                fieldNumber: 2,
                fileName: _pdfFileName2,
              ),
              _buildPDFUploadField(
                labelText: 'Supporting PDF 3',
                fieldNumber: 3,
                fileName: _pdfFileName3,
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
                      color: Colors.teal[700]!.withValues(alpha: 0.3),
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

  Widget _buildPDFUploadField({
    required String labelText,
    required int fieldNumber,
    required String? fileName,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    fileName ?? 'No file selected',
                    style: TextStyle(
                      color: fileName != null ? Colors.black87 : Colors.grey[600],
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                if (fileName != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => _clearPDF(fieldNumber),
                    color: Colors.red,
                    tooltip: 'Remove file',
                  ),
                ElevatedButton.icon(
                  onPressed: () => _pickPDF(fieldNumber),
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(fileName != null ? 'Change' : 'Choose PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
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
        validator: validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter $labelText';
              }
              return null;
            },
      ),
    );
  }
}
