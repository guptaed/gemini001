import 'package:flutter/material.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/bank.dart';
import 'package:gemini001/models/credit_check.dart';
import 'package:gemini001/models/bid_flow.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:gemini001/screens/add_credit_check_screen.dart';
import 'package:gemini001/screens/bid_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:gemini001/screens/supplier_onboarding_dashboard.dart';

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

  @override
  void initState() {
    super.initState();
    _contractInfoFuture = FirestoreHelper().getContractInfo(widget.supplier.SupId);
    _bankDetailsFuture = FirestoreHelper().getBankDetails(widget.supplier.SupId);
    _creditCheckFuture = FirestoreHelper().getCreditCheck(widget.supplier.SupId);
    _bidFlowsFuture = FirestoreHelper().getBidFlowsBySupplier(widget.supplier.SupId);
  }

  void _refreshCreditCheck() {
    setState(() {
      _creditCheckFuture = FirestoreHelper().getCreditCheck(widget.supplier.SupId);
    });
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
            MaterialPageRoute(builder: (context) => const ListSuppliersScreen()),
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

  // Helper method for gradient badge colors (global supplier status)
  List<Color> _getStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return [const Color.fromARGB(255, 19, 18, 18), const Color.fromARGB(255, 110, 110, 110)];
      case 'active':
        return [const Color.fromARGB(255, 19, 88, 82), const Color.fromARGB(255, 35, 170, 157)];
      case 'at risk':
        return [const Color.fromARGB(255, 238, 149, 16), const Color.fromARGB(255, 221, 146, 34)];
      case 'terminated':
        return [const Color.fromARGB(255, 151, 35, 33), const Color.fromARGB(255, 167, 41, 41)];
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
      return [Colors.green[900]!, Colors.green[700]!]; // Green for current stage
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
  Widget _buildStatusBadge(String status, ThemeData theme, {String? stage, bool isWorkflow = false, String? id, bool isCurrent = false, String? currentStatus}) {
    final double baseSizeFactor = 1.0;
    final double sizeFactor = isCurrent ? 1.4 : baseSizeFactor;
    final List<Color> gradientColors = isCurrent && isWorkflow && stage != null
        ? _getWorkflowStatusGradient(stage, isCurrent)
        : (isCurrent ? _getStatusGradient(status) : [Colors.grey[700]!, Colors.grey[500]!]);

    return Semantics(
      label: 'Status: ${isCurrent ? status : stage ?? status}${isWorkflow && stage != null ? ", Stage: $stage" : ""}${isCurrent ? ", current" : ""}${currentStatus != null ? ", Status: $currentStatus" : ""}',
      child: GestureDetector(
        onTap: isWorkflow && stage != null && isCurrent
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BidDetailsScreen(bidId: id ?? '', stage: stage),
                  ),
                );
              }
            : null,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 6 * sizeFactor, horizontal: 12 * sizeFactor),
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
                color: Colors.black.withOpacity(isCurrent ? 0.3 : 0.15),
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
                    isWorkflow && stage != null ? _getWorkflowStatusIcon(stage) : _getStatusIcon(status),
                    size: 14 * sizeFactor,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isCurrent ? status.toUpperCase() : stage?.toUpperCase() ?? status.toUpperCase(),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // More rounded
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
                  final currentStage = bidFlow.currentStage?.toLowerCase() ?? 'bidding';
                  final currentStatus = bidFlow.currentStageStatus ?? 'N/A';
                  return Column(
                    children: [
                      if (index > 0) const SizedBox(height: 24), // Increased spacing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
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
                          _buildStatusBadge('Bidding', theme, stage: 'Bidding', isWorkflow: true, id: bidFlow.bidId.toString(), isCurrent: currentStage == 'bidding', currentStatus: currentStage == 'bidding' ? currentStatus : null),
                          const SizedBox(width: 24), // Increased spacing
                          CustomPaint(
                            painter: CurvedConnectorPainter(
                              isActive: _isConnectorActive(currentStage, 'bidding'),
                            ),
                            size: const Size(80, 20), // Longer and taller
                          ),
                          const SizedBox(width: 24),
                          _buildStatusBadge('Shipment', theme, stage: 'Shipment', isWorkflow: true, id: bidFlow.bidId.toString(), isCurrent: currentStage == 'shipment', currentStatus: currentStage == 'shipment' ? currentStatus : null),
                          const SizedBox(width: 24),
                          CustomPaint(
                            painter: CurvedConnectorPainter(
                              isActive: _isConnectorActive(currentStage, 'shipment'),
                            ),
                            size: const Size(80, 20),
                          ),
                          const SizedBox(width: 24),
                          _buildStatusBadge('QA', theme, stage: 'QA', isWorkflow: true, id: bidFlow.bidId.toString(), isCurrent: currentStage == 'qa', currentStatus: currentStage == 'qa' ? currentStatus : null),
                          const SizedBox(width: 24),
                          CustomPaint(
                            painter: CurvedConnectorPainter(
                              isActive: _isConnectorActive(currentStage, 'qa'),
                            ),
                            size: const Size(80, 20),
                          ),
                          const SizedBox(width: 24),
                          _buildStatusBadge('Payment', theme, stage: 'Payment', isWorkflow: true, id: bidFlow.bidId.toString(), isCurrent: currentStage == 'payment', currentStatus: currentStage == 'payment' ? currentStatus : null),
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

  Widget _buildDetailRow(String label, String value, TextStyle style, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: style.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withOpacity(0.7)),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.supplier.CompanyName,
                      style: headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusBadge(widget.supplier.Status, theme),
                    const Divider(
                      color: Colors.grey,
                      thickness: 1,
                      height: 10,
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Supplier ID', widget.supplier.SupId.toString(), bodyMedium, theme),
                    _buildDetailRow('Representative', widget.supplier.Representative, bodyMedium, theme),
                    _buildDetailRow('Title', widget.supplier.Title, bodyMedium, theme),
                    _buildDetailRow('Address', widget.supplier.Address, bodyMedium, theme),
                    _buildDetailRow('Telephone', widget.supplier.Tel, bodyMedium, theme),
                    _buildDetailRow('Email', widget.supplier.Email, bodyMedium, theme),
                    _buildDetailRow('Tax Code', widget.supplier.TaxCode, bodyMedium, theme),
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}', style: bodyMedium);
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
                                            builder: (context) => AddCreditCheckScreen(
                                              supId: widget.supplier.SupId,
                                              companyName: widget.supplier.CompanyName,
                                            ),
                                          ),
                                        );
                                        if (mounted) {
                                          _refreshCreditCheck();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: theme.colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Add Credit Check'),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Status', creditCheck.status, bodyMedium, theme),
                                  _buildDetailRow('Established Date', creditCheck.establishedDate, bodyMedium, theme),
                                  _buildDetailRow('Supply Capacity', creditCheck.supplyCapacity.toString(), bodyMedium, theme),
                                  _buildDetailRow('Track Record', creditCheck.trackRecord, bodyMedium, theme),
                                  _buildDetailRow('Raw Material Types', creditCheck.rawMaterialTypes, bodyMedium, theme),
                                  _buildDetailRow('Check Start Date', creditCheck.checkStartDate.isEmpty ? 'Not set' : creditCheck.checkStartDate, bodyMedium, theme),
                                  _buildDetailRow('Check Finish Date', creditCheck.checkFinishDate.isEmpty ? 'Not set' : creditCheck.checkFinishDate, bodyMedium, theme),
                                  _buildDetailRow('Check Company', creditCheck.checkCompany, bodyMedium, theme),
                                  const SizedBox(height: 16),
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.colorScheme.primary,
                                            foregroundColor: theme.colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}', style: bodyMedium);
                              }
                              final contractInfo = snapshot.data;
                              if (contractInfo == null) {
                                return Center(
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: theme.colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Add Contract Information'),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Contract No', contractInfo.ContractNo, bodyMedium, theme),
                                  _buildDetailRow('Signed Date', contractInfo.SignedDate, bodyMedium, theme),
                                  _buildDetailRow('Validity Years', contractInfo.ValidityYrs.toString(), bodyMedium, theme),
                                  _buildDetailRow('Max Auto Validity', contractInfo.MaxAutoValidity.toString(), bodyMedium, theme),
                                  _buildDetailRow('STT1 Price', contractInfo.STT1Price.toString(), bodyMedium, theme),
                                  _buildDetailRow('STT2 Price', contractInfo.STT2Price.toString(), bodyMedium, theme),
                                  const SizedBox(height: 16),
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.colorScheme.primary,
                                            foregroundColor: theme.colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}', style: bodyMedium);
                              }
                              final bankDetails = snapshot.data;
                              if (bankDetails == null) {
                                return Center(
                                  child: AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.colorScheme.primary,
                                        foregroundColor: theme.colorScheme.onPrimary,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      child: const Text('Add Bank Information'),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow('Payment Method ID', bankDetails.PaymentMethodId, bodyMedium, theme),
                                  _buildDetailRow('Bank Name', bankDetails.BankName, bodyMedium, theme),
                                  _buildDetailRow('Branch Name', bankDetails.BranchName, bodyMedium, theme),
                                  _buildDetailRow('Bank ID', bankDetails.BankId, bodyMedium, theme),
                                  _buildDetailRow('Branch ID', bankDetails.BranchId, bodyMedium, theme),
                                  _buildDetailRow('Account Name', bankDetails.AccountName, bodyMedium, theme),
                                  _buildDetailRow('Account Number', bankDetails.AccountNumber, bodyMedium, theme),
                                  _buildDetailRow('Preferred Bank', bankDetails.PreferredBank.toString(), bodyMedium, theme),
                                  const SizedBox(height: 16),
                                  AnimatedOpacity(
                                    opacity: 1.0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.colorScheme.primary,
                                            foregroundColor: theme.colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        size.width * 0.3, size.height / 2,
        size.width * 0.7, size.height / 2,
        size.width, size.height / 2,
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