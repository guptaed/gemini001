import 'package:flutter/material.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/bank.dart';
import 'package:gemini001/models/credit_check.dart';
import 'package:gemini001/models/bid_flow.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/database/storage_helper.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:gemini001/screens/add_credit_check_screen.dart';
import 'package:gemini001/screens/add_contract_screen.dart';
import 'package:gemini001/screens/add_bank_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gemini001/utils/logging.dart';
import 'package:file_picker/file_picker.dart';

class SupplierDetailsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailsScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  late Future<ContractInfo?> _contractInfoFuture;
  late Future<BankDetails?> _bankDetailsFuture;
  late Future<CreditCheck?> _creditCheckFuture;
  late Future<List<BidFlow>> _bidFlowsFuture;
  late Supplier _currentSupplier;

  @override
  void initState() {
    super.initState();
    _currentSupplier = widget.supplier;
    _contractInfoFuture =
        FirestoreHelper().getContractInfo(widget.supplier.SupId);
    _bankDetailsFuture =
        FirestoreHelper().getBankDetails(widget.supplier.SupId);
    _creditCheckFuture =
        FirestoreHelper().getCreditCheck(widget.supplier.SupId);
    _bidFlowsFuture =
        FirestoreHelper().getBidFlowsBySupplier(widget.supplier.SupId);

    // Fetch latest supplier data from Firestore on screen load
    _refreshSupplier();
  }

  void _refreshCreditCheck() {
    setState(() {
      _creditCheckFuture =
          FirestoreHelper().getCreditCheck(widget.supplier.SupId);
    });
  }

  // Refresh supplier data from Firestore
  Future<void> _refreshSupplier() async {
    try {
      final updatedSupplier = await FirestoreHelper().getSupplierBySupId(widget.supplier.SupId);
      if (updatedSupplier != null && mounted) {
        setState(() {
          _currentSupplier = updatedSupplier;
        });
      }
    } catch (e) {
      logger.e('Error refreshing supplier: $e');
    }
  }

  // Upload a new PDF to an empty slot
  Future<void> _uploadPDF(int fieldNumber) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;

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
        const maxSize = 10 * 1024 * 1024;

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

        // Upload the PDF
        try {
          // Show loading dialog
          if (mounted) {
            _showLoadingDialog('Uploading PDF...');
          }

          final uploadedFileName = await StorageHelper().uploadPDF(
            fileBytes: fileBytes,
            fileName: fileName,
            supplierId: _currentSupplier.SupId,
            fieldNumber: fieldNumber,
          );

          // Dismiss loading dialog
          if (mounted) {
            _dismissLoadingDialog();
          }

          if (uploadedFileName != null) {
            // Update local state immediately
            setState(() {
              _currentSupplier = _currentSupplier.copyWith(
                SupportingPDF1: fieldNumber == 1 ? uploadedFileName : _currentSupplier.SupportingPDF1,
                SupportingPDF2: fieldNumber == 2 ? uploadedFileName : _currentSupplier.SupportingPDF2,
                SupportingPDF3: fieldNumber == 3 ? uploadedFileName : _currentSupplier.SupportingPDF3,
              );
            });

            // Update Firestore in the background
            await FirestoreHelper().updateSupplier(_currentSupplier);

            if (mounted) {
              await _showMessageDialog(
                title: 'Success',
                message: 'PDF uploaded successfully!',
                isError: false,
              );
            }
          }
        } catch (e) {
          logger.e('Error uploading PDF: $e');
          // Dismiss loading dialog if still showing
          if (mounted) {
            _dismissLoadingDialog();
          }
          if (mounted) {
            await _showMessageDialog(
              title: 'Upload Failed',
              message: 'Failed to upload PDF:\n\n$e',
              isError: true,
            );
          }
        }
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

  // Replace an existing PDF
  Future<void> _replacePDF(String oldFileName, int fieldNumber) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Replace PDF'),
          content: Text('Are you sure you want to replace "$oldFileName"?\n\nThe old file will be deleted from storage.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Replace'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final fileBytes = result.files.single.bytes;
        final fileName = result.files.single.name;

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

        // Check file size
        final fileSize = fileBytes.length;
        const maxSize = 10 * 1024 * 1024;

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

        try {
          // Show loading dialog
          if (mounted) {
            _showLoadingDialog('Replacing PDF...');
          }

          // Delete old file from storage
          await StorageHelper().deletePDF(
            supplierId: _currentSupplier.SupId,
            fileName: oldFileName,
          );

          // Upload new file
          final uploadedFileName = await StorageHelper().uploadPDF(
            fileBytes: fileBytes,
            fileName: fileName,
            supplierId: _currentSupplier.SupId,
            fieldNumber: fieldNumber,
          );

          // Dismiss loading dialog
          if (mounted) {
            _dismissLoadingDialog();
          }

          if (uploadedFileName != null) {
            // Update local state immediately
            setState(() {
              _currentSupplier = _currentSupplier.copyWith(
                SupportingPDF1: fieldNumber == 1 ? uploadedFileName : _currentSupplier.SupportingPDF1,
                SupportingPDF2: fieldNumber == 2 ? uploadedFileName : _currentSupplier.SupportingPDF2,
                SupportingPDF3: fieldNumber == 3 ? uploadedFileName : _currentSupplier.SupportingPDF3,
              );
            });

            // Update Firestore in the background
            await FirestoreHelper().updateSupplier(_currentSupplier);

            if (mounted) {
              await _showMessageDialog(
                title: 'Success',
                message: 'PDF replaced successfully!',
                isError: false,
              );
            }
          }
        } catch (e) {
          logger.e('Error replacing PDF: $e');
          // Dismiss loading dialog if still showing
          if (mounted) {
            _dismissLoadingDialog();
          }
          // Refresh from server in case of error
          await _refreshSupplier();
          if (mounted) {
            await _showMessageDialog(
              title: 'Replace Failed',
              message: 'Failed to replace PDF:\n\n$e',
              isError: true,
            );
          }
        }
      }
    } catch (e) {
      logger.e('Error picking replacement PDF: $e');
      if (mounted) {
        await _showMessageDialog(
          title: 'Error',
          message: 'Error selecting file:\n\n$e',
          isError: true,
        );
      }
    }
  }

  // Delete a PDF
  Future<void> _deletePDF(String fileName, int fieldNumber) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete PDF'),
          content: Text('Are you sure you want to delete "$fileName"?\n\nThis action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      // Show loading dialog
      if (mounted) {
        _showLoadingDialog('Deleting PDF...');
      }

      // Delete from storage
      await StorageHelper().deletePDF(
        supplierId: _currentSupplier.SupId,
        fileName: fileName,
      );

      // Update local state immediately
      setState(() {
        _currentSupplier = _currentSupplier.copyWith(
          SupportingPDF1: fieldNumber == 1 ? null : _currentSupplier.SupportingPDF1,
          SupportingPDF2: fieldNumber == 2 ? null : _currentSupplier.SupportingPDF2,
          SupportingPDF3: fieldNumber == 3 ? null : _currentSupplier.SupportingPDF3,
        );
      });

      // Update Firestore in the background
      await FirestoreHelper().updateSupplier(_currentSupplier);

      // Dismiss loading dialog
      if (mounted) {
        _dismissLoadingDialog();
      }

      if (mounted) {
        await _showMessageDialog(
          title: 'Success',
          message: 'PDF deleted successfully!',
          isError: false,
        );
      }
    } catch (e) {
      logger.e('Error deleting PDF: $e');
      // Dismiss loading dialog if still showing
      if (mounted) {
        _dismissLoadingDialog();
      }
      // Refresh from server in case of error
      await _refreshSupplier();
      if (mounted) {
        await _showMessageDialog(
          title: 'Delete Failed',
          message: 'Failed to delete PDF:\n\n$e',
          isError: true,
        );
      }
    }
  }

  // Download/Open PDF file
  Future<void> _downloadPDF(String fileName, int fieldNumber) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fetching PDF...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Get download URL from Firebase Storage
      final downloadUrl = await StorageHelper().getPDFDownloadUrl(
        supplierId: _currentSupplier.SupId,
        fileName: fileName,
      );

      if (downloadUrl == null) {
        if (mounted) {
          await _showMessageDialog(
            title: 'Error',
            message: 'Failed to get download URL for the PDF file.',
            isError: true,
          );
        }
        return;
      }

      // Open the URL in browser/download
      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          await _showMessageDialog(
            title: 'Error',
            message: 'Could not open the PDF file. URL: $downloadUrl',
            isError: true,
          );
        }
      }
    } catch (e) {
      logger.e('Error downloading PDF: $e');
      if (mounted) {
        await _showMessageDialog(
          title: 'Error',
          message: 'Error downloading PDF:\n\n$e',
          isError: true,
        );
      }
    }
  }

  // Show a loading dialog during operations
  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dismiss the loading dialog
  void _dismissLoadingDialog() {
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  // Show a dialog that requires user acknowledgment
  Future<void> _showMessageDialog({
    required String title,
    required String message,
    bool isError = false,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
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

  void _onMenuItemSelected(int index) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) {
          if (route.settings.name == '/list_suppliers' || route.isFirst) {
            return true;
          }
          return false;
        });
        if (ModalRoute.of(context)?.settings.name != '/list_suppliers') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => const ListSuppliersScreen()),
          );
        }
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

  // Helper method for gradient badge colors (global supplier status)
  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return [
          const Color.fromARGB(255, 19, 18, 18),
          const Color.fromARGB(255, 110, 110, 110)
        ];
      case 'active':
        return [
          const Color.fromARGB(255, 19, 88, 82),
          const Color.fromARGB(255, 35, 170, 157)
        ];
      case 'at risk':
        return [
          const Color.fromARGB(255, 238, 149, 16),
          const Color.fromARGB(255, 221, 146, 34)
        ];
      case 'terminated':
        return [
          const Color.fromARGB(255, 151, 35, 33),
          const Color.fromARGB(255, 167, 41, 41)
        ];
      default:
        return [Colors.grey[400]!, Colors.grey[200]!];
    }
  }

  // Helper method for status icon (global supplier status)
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Icons.circle_outlined;
      case 'active':
        return Icons.check_circle_outline;
      case 'at risk':
        return Icons.warning_amber_outlined;
      case 'terminated':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  // Helper method for gradient badge colors (workflow stage-specific statuses)
  List<Color> _getWorkflowStatusGradient(String stage, bool isCurrent) {
    if (isCurrent) {
      return [
        Colors.green[900]!,
        Colors.green[700]!
      ]; // Green for current stage
    }
    return [Colors.black, Colors.grey[800]!]; // Dark grey for non-current
  }

  // Helper method for status icon (workflow stage-specific statuses)
  IconData _getWorkflowStatusIcon(String stage) {
    final stageIcons = {
      'bidding': Icons.pending,
      'shipment': Icons.local_shipping_outlined,
      'qa': Icons.schedule,
      'payment': Icons.payment,
    };
    return stageIcons[stage.toLowerCase()] ?? Icons.help_outline;
  }

  // Helper method to build the gradient badge with icon - NOW WITH SHADOW!
  Widget _buildStatusBadge(String status, ThemeData theme,
      {String? stage,
      bool isWorkflow = false,
      String? id,
      bool isCurrent = false,
      String? currentStatus}) {
    final double baseSizeFactor = 1.0;
    final double sizeFactor = isCurrent ? 1.4 : baseSizeFactor;
    final List<Color> gradientColors = isCurrent && isWorkflow && stage != null
        ? _getWorkflowStatusGradient(stage, isCurrent)
        : (isCurrent
            ? _getStatusGradient(status)
            : [Colors.grey[700]!, Colors.grey[500]!]);

    return Semantics(
      label:
          'Status: ${isCurrent ? status : stage ?? status}${isWorkflow && stage != null ? ", Stage: $stage" : ""}${isCurrent ? ", current" : ""}${currentStatus != null ? ", Status: $currentStatus" : ""}',
      child: GestureDetector(
        onTap: isWorkflow && stage != null && isCurrent
            ? () {
                // TODO: Navigate to bid details when Bid object is available
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bid details for ID: ${id ?? 'N/A'} - Feature coming soon!'),
                  ),
                );
              }
            : null,
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: 6 * sizeFactor, horizontal: 12 * sizeFactor),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16 * sizeFactor),
            // ADDED: Subtle shadow for depth
            boxShadow: [
              BoxShadow(
                color: Colors.black..withValues(alpha: isCurrent ? 0.3 : 0.15),
                blurRadius: isCurrent ? 8 : 4,
                offset: Offset(0, isCurrent ? 3 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isWorkflow && stage != null
                        ? _getWorkflowStatusIcon(stage)
                        : _getStatusIcon(status),
                    size: 14 * sizeFactor,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCurrent
                        ? status.toUpperCase()
                        : stage?.toUpperCase() ?? status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12 * sizeFactor,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              if (isCurrent && currentStatus != null)
                Column(
                  children: [
                    SizedBox(
                      width: 100,
                      child: const Divider(
                        color: Colors.white,
                        thickness: 2,
                        height: 14,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 1 * sizeFactor),
                      child: Text(
                        currentStatus,
                        style: TextStyle(
                          fontSize: 10 * sizeFactor,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to determine if connector should be active
  bool _isConnectorActive(String currentStage, String fromStage) {
    const stageOrder = ['bidding', 'shipment', 'qa', 'payment'];
    final currentIndex = stageOrder.indexOf(currentStage.toLowerCase());
    final fromIndex = stageOrder.indexOf(fromStage.toLowerCase());
    return currentIndex > fromIndex;
  }

  // Helper method to build workflow timeline - ENHANCED VERSION
  Widget _buildWorkflowTimeline(List<BidFlow> bidFlows, ThemeData theme) {
    return Card(
      elevation: 4, // Increased elevation
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)), // More rounded
      child: Container(
        decoration: BoxDecoration(
          // ADDED: Subtle gradient background
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey[50]!],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24.0), // Increased padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ENHANCED: Header with icon
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Bid Workflow Progress',
                  style: theme.textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.grey, thickness: 1, height: 30),
            const SizedBox(height: 8),
            if (bidFlows.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bidFlows.length,
                itemBuilder: (context, index) {
                  final bidFlow = bidFlows[index];
                  final currentStage =
                      bidFlow.currentStage?.toLowerCase() ?? 'bidding';
                  final currentStatus = bidFlow.currentStageStatus ?? 'N/A';
                  return Column(
                    children: [
                      if (index > 0)
                        const SizedBox(height: 24), // Increased spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary
                                ..withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary
                                    .withValues(alpha: 0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Bid: ${bidFlow.bidId}',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 24), // Increased spacing
                          _buildStatusBadge('Bidding', theme,
                              stage: 'Bidding',
                              isWorkflow: true,
                              id: bidFlow.bidId.toString(),
                              isCurrent: currentStage == 'bidding',
                              currentStatus: currentStage == 'bidding'
                                  ? currentStatus
                                  : null),
                          const SizedBox(width: 24), // Increased spacing
                          CustomPaint(
                            painter: CurvedConnectorPainter(
                              isActive:
                                  _isConnectorActive(currentStage, 'bidding'),
                            ),
                            size: const Size(80, 20), // Longer and taller
                          ),
                          const SizedBox(width: 24),
                          _buildStatusBadge('Shipment', theme,
                              stage: 'Shipment',
                              isWorkflow: true,
                              id: bidFlow.bidId.toString(),
                              isCurrent: currentStage == 'shipment',
                              currentStatus: currentStage == 'shipment'
                                  ? currentStatus
                                  : null),
                          const SizedBox(width: 24),
                          CustomPaint(
                            painter: CurvedConnectorPainter(
                              isActive:
                                  _isConnectorActive(currentStage, 'shipment'),
                            ),
                            size: const Size(80, 20),
                          ),
                          const SizedBox(width: 24),
                          _buildStatusBadge('QA', theme,
                              stage: 'QA',
                              isWorkflow: true,
                              id: bidFlow.bidId.toString(),
                              isCurrent: currentStage == 'qa',
                              currentStatus:
                                  currentStage == 'qa' ? currentStatus : null),
                          const SizedBox(width: 24),
                          CustomPaint(
                            painter: CurvedConnectorPainter(
                              isActive: _isConnectorActive(currentStage, 'qa'),
                            ),
                            size: const Size(80, 20),
                          ),
                          const SizedBox(width: 24),
                          _buildStatusBadge('Payment', theme,
                              stage: 'Payment',
                              isWorkflow: true,
                              id: bidFlow.bidId.toString(),
                              isCurrent: currentStage == 'payment',
                              currentStatus: currentStage == 'payment'
                                  ? currentStatus
                                  : null),
                        ],
                      ),
                    ],
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No bid flows found for this supplier',
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
      String label, String value, TextStyle style, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: style.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface..withValues(alpha: 0.7)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: style.copyWith(color: theme.colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(ThemeData theme) {
    final metadataStyle = TextStyle(
      fontSize: 12,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );

    String formatDateTime(DateTime? dt) {
      if (dt == null) return 'N/A';
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentSupplier.CreatedAt != null) ...[
          Row(
            children: [
              Icon(Icons.add_circle_outline,
                  size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Created by ${_currentSupplier.CreatedByName ?? 'Unknown'} on ${formatDateTime(_currentSupplier.CreatedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
        if (_currentSupplier.LastModifiedAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Last modified by ${_currentSupplier.LastModifiedByName ?? 'Unknown'} on ${formatDateTime(_currentSupplier.LastModifiedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCreditCheckMetadataSection(
      CreditCheck creditCheck, ThemeData theme) {
    final metadataStyle = TextStyle(
      fontSize: 12,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );

    String formatDateTime(DateTime? dt) {
      if (dt == null) return 'N/A';
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (creditCheck.CreatedAt != null) ...[
          Row(
            children: [
              Icon(Icons.add_circle_outline,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Created by ${creditCheck.CreatedByName ?? 'Unknown'} on ${formatDateTime(creditCheck.CreatedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
        if (creditCheck.LastModifiedAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Last modified by ${creditCheck.LastModifiedByName ?? 'Unknown'} on ${formatDateTime(creditCheck.LastModifiedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildContractMetadataSection(
      ContractInfo contractInfo, ThemeData theme) {
    final metadataStyle = TextStyle(
      fontSize: 12,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
    );

    String formatDateTime(DateTime? dt) {
      if (dt == null) return 'N/A';
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (contractInfo.CreatedAt != null) ...[
          Row(
            children: [
              Icon(Icons.add_circle_outline,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Created by ${contractInfo.CreatedByName ?? 'Unknown'} on ${formatDateTime(contractInfo.CreatedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
        if (contractInfo.LastModifiedAt != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.edit_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Last modified by ${contractInfo.LastModifiedByName ?? 'Unknown'} on ${formatDateTime(contractInfo.LastModifiedAt)}',
                  style: metadataStyle,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyPDFCard({
    required int fieldNumber,
    required ThemeData theme,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[50]!, Colors.grey[100]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[400]!,
          width: 1.5,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.upload_file,
              color: Colors.grey[600],
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Supporting PDF $fieldNumber',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No file uploaded',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _uploadPDF(fieldNumber),
              icon: const Icon(Icons.cloud_upload, size: 18),
              label: const Text('Upload PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPDFCard({
    required String fileName,
    required int fieldNumber,
    required ThemeData theme,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.grey[100]!, Colors.grey[200]!],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.teal[700]!.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.teal[700]!.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal[700]!, Colors.teal[600]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Supporting PDF $fieldNumber',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal[800],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileName,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _downloadPDF(fileName, fieldNumber),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download / View'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _replacePDF(fileName, fieldNumber),
                  icon: const Icon(Icons.swap_horiz, size: 16),
                  label: const Text('Replace'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange[700],
                    side: BorderSide(color: Colors.orange[700]!),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _deletePDF(fileName, fieldNumber),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[700]!),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle headlineSmall = theme.textTheme.headlineSmall!;
    final TextStyle bodyMedium = theme.textTheme.bodyMedium!;
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';

    return CommonLayout(
      title: 'Supplier Details',
      mainContentPanel: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentSupplier.CompanyName,
                      style: headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(_currentSupplier.Status, theme),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 10,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Supplier ID',
                        _currentSupplier.SupId.toString(), bodyMedium, theme),
                    _buildDetailRow('Representative',
                        _currentSupplier.Representative, bodyMedium, theme),
                    _buildDetailRow(
                        'Title', _currentSupplier.Title, bodyMedium, theme),
                    _buildDetailRow(
                        'Address', _currentSupplier.Address, bodyMedium, theme),
                    _buildDetailRow(
                        'Telephone', _currentSupplier.Tel, bodyMedium, theme),
                    _buildDetailRow(
                        'Email', _currentSupplier.Email, bodyMedium, theme),
                    _buildDetailRow(
                        'Tax Code', _currentSupplier.TaxCode, bodyMedium, theme),
                    // Metadata section
                    if (_currentSupplier.CreatedAt != null ||
                        _currentSupplier.LastModifiedAt != null) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 0.5),
                      const SizedBox(height: 8),
                      _buildMetadataSection(theme),
                    ],
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              // Navigate to edit screen
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddSupplierScreen(
                                    existingSupplier: _currentSupplier,
                                  ),
                                ),
                              );
                              // Refresh if changes were saved
                              if (result == true && mounted) {
                                _refreshSupplier();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Edit'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Supporting Documents Section - Always visible
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          color: theme.colorScheme.primary,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Supporting Documents',
                          style: headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 30,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        // Slot 1
                        _currentSupplier.SupportingPDF1 != null
                            ? _buildPDFCard(
                                fileName: _currentSupplier.SupportingPDF1!,
                                fieldNumber: 1,
                                theme: theme,
                              )
                            : _buildEmptyPDFCard(
                                fieldNumber: 1,
                                theme: theme,
                              ),
                        // Slot 2
                        _currentSupplier.SupportingPDF2 != null
                            ? _buildPDFCard(
                                fileName: _currentSupplier.SupportingPDF2!,
                                fieldNumber: 2,
                                theme: theme,
                              )
                            : _buildEmptyPDFCard(
                                fieldNumber: 2,
                                theme: theme,
                              ),
                        // Slot 3
                        _currentSupplier.SupportingPDF3 != null
                            ? _buildPDFCard(
                                fileName: _currentSupplier.SupportingPDF3!,
                                fieldNumber: 3,
                                theme: theme,
                              )
                            : _buildEmptyPDFCard(
                                fieldNumber: 3,
                                theme: theme,
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<BidFlow>>(
              future: _bidFlowsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}', style: bodyMedium);
                }
                final bidFlows = snapshot.data ?? [];
                return _buildWorkflowTimeline(bidFlows, theme);
              },
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Credit Check Information',
                            style: headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 10,
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<CreditCheck?>(
                            future: _creditCheckFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}',
                                    style: bodyMedium);
                              }
                              final creditCheck = snapshot.data;
                              if (creditCheck == null) {
                                return Center(
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddCreditCheckScreen(
                                              supId: _currentSupplier.SupId,
                                              companyName:
                                                  _currentSupplier.CompanyName,
                                            ),
                                          ),
                                        );
                                        if (mounted) {
                                          _refreshCreditCheck();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Add Credit Check'),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Status', creditCheck.status,
                                      bodyMedium, theme),
                                  _buildDetailRow(
                                      'Established Date',
                                      creditCheck.establishedDate,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Supply Capacity',
                                      creditCheck.supplyCapacity.toString(),
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Track Record',
                                      creditCheck.trackRecord,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Raw Material Types',
                                      creditCheck.rawMaterialTypes,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Check Start Date',
                                      creditCheck.checkStartDate.isEmpty
                                          ? 'Not set'
                                          : creditCheck.checkStartDate,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Check Finish Date',
                                      creditCheck.checkFinishDate.isEmpty
                                          ? 'Not set'
                                          : creditCheck.checkFinishDate,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Check Company',
                                      creditCheck.checkCompany,
                                      bodyMedium,
                                      theme),
                                  // Metadata section
                                  if (creditCheck.CreatedAt != null ||
                                      creditCheck.LastModifiedAt != null) ...[
                                    const SizedBox(height: 8),
                                    const Divider(height: 16),
                                    _buildCreditCheckMetadataSection(
                                        creditCheck, theme),
                                  ],
                                  const SizedBox(height: 16),
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddCreditCheckScreen(
                                                  supId: _currentSupplier.SupId,
                                                  companyName:
                                                      _currentSupplier.CompanyName,
                                                  existingCreditCheck: creditCheck,
                                                ),
                                              ),
                                            );
                                            // Refresh if changes were saved
                                            if (result == true && mounted) {
                                              _refreshCreditCheck();
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            foregroundColor:
                                                theme.colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: const Text('Edit'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contract Information',
                            style: headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 10,
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<ContractInfo?>(
                            future: _contractInfoFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}',
                                    style: bodyMedium);
                              }
                              final contractInfo = snapshot.data;
                              if (contractInfo == null) {
                                return Center(
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddContractScreen(
                                              supId: widget.supplier.SupId,
                                              companyName:
                                                  widget.supplier.CompanyName,
                                            ),
                                          ),
                                        );
                                        // Refresh contract info after returning
                                        setState(() {
                                          _contractInfoFuture = FirestoreHelper()
                                              .getContractInfo(
                                                  widget.supplier.SupId);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text(
                                          'Add Contract Information'),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                      'Contract No',
                                      contractInfo.ContractNo,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Signed Date',
                                      contractInfo.SignedDate,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Validity Years',
                                      contractInfo.ValidityYrs.toString(),
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Max Auto Validity',
                                      contractInfo.MaxAutoValidity.toString(),
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'STT1 Price',
                                      contractInfo.STT1Price.toString(),
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'STT2 Price',
                                      contractInfo.STT2Price.toString(),
                                      bodyMedium,
                                      theme),
                                  // Metadata section
                                  if (contractInfo.CreatedAt != null ||
                                      contractInfo.LastModifiedAt != null) ...[
                                    const SizedBox(height: 8),
                                    const Divider(height: 16),
                                    _buildContractMetadataSection(
                                        contractInfo, theme),
                                  ],
                                  const SizedBox(height: 16),
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddContractScreen(
                                                  supId: widget.supplier.SupId,
                                                  companyName:
                                                      widget.supplier.CompanyName,
                                                  existingContract: contractInfo,
                                                ),
                                              ),
                                            );
                                            // Refresh if changes were saved
                                            if (result == true && mounted) {
                                              setState(() {
                                                _contractInfoFuture = FirestoreHelper()
                                                    .getContractInfo(widget.supplier.SupId);
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            foregroundColor:
                                                theme.colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: const Text('Edit'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank Details',
                            style: headlineSmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 10,
                          ),
                          const SizedBox(height: 16),
                          FutureBuilder<BankDetails?>(
                            future: _bankDetailsFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}',
                                    style: bodyMedium);
                              }
                              final bankDetails = snapshot.data;
                              if (bankDetails == null) {
                                return Center(
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddBankScreen(
                                              supId: widget.supplier.SupId,
                                              companyName:
                                                  widget.supplier.CompanyName,
                                            ),
                                          ),
                                        );
                                        // Refresh bank details after returning
                                        setState(() {
                                          _bankDetailsFuture = FirestoreHelper()
                                              .getBankDetails(
                                                  widget.supplier.SupId);
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                        foregroundColor:
                                            theme.colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Add Bank Information'),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                      'Payment Method ID',
                                      bankDetails.PaymentMethodId,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow('Bank Name',
                                      bankDetails.BankName, bodyMedium, theme),
                                  _buildDetailRow(
                                      'Branch Name',
                                      bankDetails.BranchName,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow('Bank ID', bankDetails.BankId,
                                      bodyMedium, theme),
                                  _buildDetailRow('Branch ID',
                                      bankDetails.BranchId, bodyMedium, theme),
                                  _buildDetailRow(
                                      'Account Name',
                                      bankDetails.AccountName,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Account Number',
                                      bankDetails.AccountNumber,
                                      bodyMedium,
                                      theme),
                                  _buildDetailRow(
                                      'Preferred Bank',
                                      bankDetails.PreferredBank.toString(),
                                      bodyMedium,
                                      theme),
                                  const SizedBox(height: 16),
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                theme.colorScheme.primary,
                                            foregroundColor:
                                                theme.colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                          ),
                                          child: const Text('Edit'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      userName: userName,
      selectedPageIndex: 0,
      onMenuItemSelected: _onMenuItemSelected,
    );
  }
}

// Custom painter for curved connector with gradient - OPTION 1
class CurvedConnectorPainter extends CustomPainter {
  final bool isActive;

  CurvedConnectorPainter({this.isActive = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: isActive
            ? [Colors.green[700]!, Colors.green[400]!]
            : [Colors.grey[600]!, Colors.grey[400]!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height / 2)
      ..cubicTo(
        size.width * 0.3,
        size.height / 2,
        size.width * 0.7,
        size.height / 2,
        size.width,
        size.height / 2,
      );

    canvas.drawPath(path, paint);

    // Arrowhead
    final arrowPaint = Paint()
      ..color = isActive ? Colors.green[400]! : Colors.grey[400]!
      ..style = PaintingStyle.fill;

    final arrowPath = Path()
      ..moveTo(size.width - 8, size.height / 2 - 6)
      ..lineTo(size.width, size.height / 2)
      ..lineTo(size.width - 8, size.height / 2 + 6)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
