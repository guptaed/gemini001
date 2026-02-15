import 'package:flutter/material.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/credit_check.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/smartphoneaccess.dart';
import 'package:gemini001/screens/supplier_details_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
import 'package:gemini001/screens/add_shipment_screen.dart';
import 'package:gemini001/screens/list_shipments_screen.dart';
import 'package:gemini001/screens/list_fuel_types_screen.dart';
import 'package:gemini001/screens/add_fuel_type_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:gemini001/utils/logging.dart';

class SupplierOnboardingDashboard extends StatefulWidget {
  const SupplierOnboardingDashboard({super.key});

  @override
  State<SupplierOnboardingDashboard> createState() =>
      _SupplierOnboardingDashboardState();
}

class _SupplierOnboardingDashboardState
    extends State<SupplierOnboardingDashboard> {
  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  // Data holders
  final List<TaskItem> _initiateCreditChecksOverdue = [];
  final List<TaskItem> _completeCreditChecksOverdue = [];
  final List<TaskItem> _completeContractsOverdue = [];
  final List<TaskItem> _generatePasswordsOverdue = [];

  final List<TaskItem> _initiateCreditChecksNormal = [];
  final List<TaskItem> _completeCreditChecksNormal = [];
  final List<TaskItem> _completeContractsNormal = [];
  final List<TaskItem> _generatePasswordsNormal = [];

  int _totalOverdue = 0;
  int _totalDueSoon = 0;
  int _totalCurrent = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Get all suppliers
      final suppliers = await _firestoreHelper.streamSuppliers().first;

      // Clear existing data
      _initiateCreditChecksOverdue.clear();
      _completeCreditChecksOverdue.clear();
      _completeContractsOverdue.clear();
      _generatePasswordsOverdue.clear();
      _initiateCreditChecksNormal.clear();
      _completeCreditChecksNormal.clear();
      _completeContractsNormal.clear();
      _generatePasswordsNormal.clear();

      // Process each supplier
      for (var supplier in suppliers) {
        final creditCheck = await _firestoreHelper.getCreditCheck(supplier.SupId);
        final contract    = await _firestoreHelper.getContractInfo(supplier.SupId);
        final smartphoneAccess = await _firestoreHelper.getSmartphoneAccess(supplier.SupId);

        // Determine current stage and waiting days
        final stage = _determineStage(supplier, creditCheck, contract, smartphoneAccess);
        final waitingDays = stage['waitingDays'] as int;
        final stageName = stage['stage'] as String;
        final dateAdded = stage['dateAdded'] as String;

        final taskItem = TaskItem(
          supplier: supplier,
          stage: stageName,
          dateAdded: dateAdded,
          waitingDays: waitingDays,
        );

        // Categorize tasks
        switch (stageName) {
          case 'Initiate Credit Check':
            if (waitingDays > 30) {
              _initiateCreditChecksOverdue.add(taskItem);
            } else if (waitingDays > 0) {
              _initiateCreditChecksNormal.add(taskItem);
            }
            break;
          case 'Complete Credit Check':
            if (waitingDays > 60) {
              _completeCreditChecksOverdue.add(taskItem);
            } else if (waitingDays > 0) {
              _completeCreditChecksNormal.add(taskItem);
            }
            break;
          case 'Complete Contract':
            if (waitingDays > 45) {
              _completeContractsOverdue.add(taskItem);
            } else if (waitingDays > 0) {
              _completeContractsNormal.add(taskItem);
            }
            break;
          case 'Generate Password':
            if (waitingDays > 5) {
              _generatePasswordsOverdue.add(taskItem);
            } else if (waitingDays > 0) {
              _generatePasswordsNormal.add(taskItem);
            }
            break;
        }
      }

      // Calculate totals
      _totalOverdue = _initiateCreditChecksOverdue.length +
          _completeCreditChecksOverdue.length +
          _completeContractsOverdue.length +
          _generatePasswordsOverdue.length;

      _totalDueSoon = _initiateCreditChecksNormal
              .where((t) => t.waitingDays >= 25 && t.waitingDays <= 30)
              .length +
          _completeCreditChecksNormal
              .where((t) => t.waitingDays >= 55 && t.waitingDays <= 60)
              .length +
          _completeContractsNormal
              .where((t) => t.waitingDays >= 40 && t.waitingDays <= 45)
              .length +
          _generatePasswordsNormal
              .where((t) => t.waitingDays >= 3 && t.waitingDays <= 5)
              .length;

      _totalCurrent = _initiateCreditChecksNormal.length +
          _completeCreditChecksNormal.length +
          _completeContractsNormal.length +
          _generatePasswordsNormal.length;
    } catch (e) {
      logger.e('Error loading supplier onboarding dashboard data', e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Map<String, dynamic> _determineStage(
      Supplier supplier, CreditCheck? creditCheck, ContractInfo? contract, SmartphoneAccess? smartphoneAccess) {
    final now = DateTime.now();

    // Stage 4: Generate Password (Contract exists, check if password generated)
    if (contract != null) {
      final contractDate = _parseDate(contract.SignedDate);
      if (contractDate != null) {
        final daysSinceContract = now.difference(contractDate).inDays;
        // No record of smartphone access or status not active
        if (smartphoneAccess == null || smartphoneAccess.status.toLowerCase() != 'active') {
          return {
            'stage': 'Generate Password',
            'dateAdded': contract.SignedDate,
            'waitingDays': daysSinceContract,
          };
        }
      }
    }

    // Stage 3: Complete Contract (Credit check complete, no contract)
    if (creditCheck != null &&
        creditCheck.status.toLowerCase() == 'successful') {
      if (contract == null) {
        final creditCheckDate = _parseDate(creditCheck.checkFinishDate);
        if (creditCheckDate != null) {
          final daysSinceCreditCheck = now.difference(creditCheckDate).inDays;
          return {
            'stage': 'Complete Contract',
            'dateAdded': creditCheck.checkFinishDate,
            'waitingDays': daysSinceCreditCheck,
          };
        }
      }
    }

    // Stage 2: Complete Credit Check (Credit check in progress)
    if (creditCheck != null &&
        creditCheck.status.toLowerCase() == 'in progress') {
      final creditCheckStartDate = _parseDate(creditCheck.checkStartDate);
      if (creditCheckStartDate != null) {
        final daysSinceStart = now.difference(creditCheckStartDate).inDays;
        return {
          'stage': 'Complete Credit Check',
          'dateAdded': creditCheck.checkStartDate,
          'waitingDays': daysSinceStart,
        };
      }
    }

    // Stage 1: Initiate Credit Check (No credit check or status is 'To Start')
    if (creditCheck == null || creditCheck.status.toLowerCase() == 'to start') {
      // Use supplier creation date or credit check date
      final dateStr = creditCheck?.checkStartDate ?? _getCurrentDate();
      final dateAdded = _parseDate(dateStr);
      if (dateAdded != null) {
        final daysSinceAdded = now.difference(dateAdded).inDays;
        return {
          'stage': 'Initiate Credit Check',
          'dateAdded': dateStr,
          'waitingDays': daysSinceAdded,
        };
      }
    }

    // Default: Completed onboarding
    return {
      'stage': 'Completed',
      'dateAdded': _getCurrentDate(),
      'waitingDays': 0,
    };
  }

  DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      } catch (e) {
        return null;
      }
    }
  }

  String _getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  void _onMenuItemSelected(int index) {
    switch (index) {
      case 0:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListSuppliersScreen()));
        break;
      case 1:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddSupplierScreen()));
        break;
      case 2:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddAnnouncementScreen()));
        break;
      case 3:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListAnnouncementsScreen()));
        break;
      case 4:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddBidScreen()));
        break;
      case 5:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ListBidsScreen()));
        break;
      case 6:
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddShipmentScreen()));
        break;
      case 7:
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListShipmentsScreen()));
        break;
      case 11:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ListFuelTypesScreen()));
        break;
      case 12:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddFuelTypeScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    final theme = Theme.of(context);

    return CommonLayout(
      title: 'Supplier Onboarding Dashboard',
      userName: userName,
      selectedPageIndex: 10,
      onMenuItemSelected: _onMenuItemSelected,
      mainContentPanel: _isLoading
          ? _buildLoadingState(theme)
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 2.0, top: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section
                    _buildWelcomeSection(userName, theme),
                    // const SizedBox(height: 24),

                    // KPI Cards
                    _buildKPICards(theme),
                    const SizedBox(height: 16),

                    // Critical Section
                    if (_totalOverdue > 0) ...[
                      _buildCriticalSection(theme),
                      const SizedBox(height: 16),
                    ],

                    // Normal Tasks Section
                    _buildNormalTasksSection(theme),
                    const SizedBox(height: 16),

                    // Pipeline Summary
                    _buildPipelineSummary(theme),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated truck icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 10),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(
                  (value * 100) - 50, // Move from left to right
                  0,
                ),
                child: Icon(
                  Icons.local_shipping,
                  size: 50,
                  color:
                      theme.primaryColor.withValues(alpha: 0.3 + (value * 0.7)),
                ),
              );
            },
            onEnd: () {
              if (mounted && _isLoading) {
                setState(() {}); // Restart animation
              }
            },
          ),
          const SizedBox(height: 32),

          // Loading text with animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Opacity(
                opacity: 0.5 + (value * 0.5),
                child: Text(
                  'Loading Dashboard Data...',
                  style: theme.textTheme.headlineSmall!.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
            onEnd: () {
              if (mounted && _isLoading) {
                setState(() {}); // Restart animation
              }
            },
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            'Fetching supplier onboarding information',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Progress indicator
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 16),

          // Loading steps indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoadingStep('Fetching suppliers', true, theme),
                _buildLoadingStep('Processing credit checks', true, theme),
                _buildLoadingStep('Analyzing contracts', true, theme),
                _buildLoadingStep('Calculating metrics', true, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingStep(String text, bool isActive, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isActive ? theme.primaryColor : Colors.grey[400]!,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: isActive ? theme.primaryColor : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildWelcomeSection(String userName, ThemeData theme) {
  return Padding(
    padding: EdgeInsets.zero,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            Icons.refresh,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          onPressed: _loadDashboardData,
          tooltip: 'Refresh Dashboard',
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

  Widget _buildKPICards(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildKPICard(
            title: 'OVERDUE',
            value: _totalOverdue.toString(),
            icon: Icons.error_outline,
            color: Colors.red,
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            title: 'DUE SOON',
            value: _totalDueSoon.toString(),
            icon: Icons.warning_amber_outlined,
            color: Colors.orange,
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            title: 'CURRENT',
            value: _totalCurrent.toString(),
            icon: Icons.schedule,
            color: Colors.green,
            theme: theme,
          ),
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  value,
                  style: theme.textTheme.headlineLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    '🔥 CRITICAL - IMMEDIATE ACTION REQUIRED',
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                      //color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            if (_initiateCreditChecksOverdue.isNotEmpty)
              _buildTaskSection(
                title: 'Initiate Credit Checks (Waiting > 30 days)',
                tasks: _initiateCreditChecksOverdue,
                theme: theme,
                color: Colors.red,
              ),
            if (_completeCreditChecksOverdue.isNotEmpty)
              _buildTaskSection(
                title: 'Complete Credit Checks (Waiting > 60 days)',
                tasks: _completeCreditChecksOverdue,
                theme: theme,
                //color: theme.colorScheme.primary,
                color: Colors.red,
              ),
            if (_completeContractsOverdue.isNotEmpty)
              _buildTaskSection(
                title: 'Complete Contract Signups (Waiting > 45 days)',
                tasks: _completeContractsOverdue,
                theme: theme,
                color: Colors.red,
              ),
            if (_generatePasswordsOverdue.isNotEmpty)
              _buildTaskSection(
                title: 'Generate Login Passwords (Waiting > 5 days)',
                tasks: _generatePasswordsOverdue,
                theme: theme,
                color: Colors.red,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalTasksSection(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.assignment,
                    color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  '📋 TASKS REQUIRING ATTENTION',
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          if (_initiateCreditChecksNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Initiate Credit Checks',
              tasks: _initiateCreditChecksNormal,
              theme: theme,
              color: Colors.orange,
            ),
          if (_completeCreditChecksNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Complete Credit Checks',
              tasks: _completeCreditChecksNormal,
              theme: theme,
              color: Colors.orange,
            ),
          if (_completeContractsNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Complete Contract Signups',
              tasks: _completeContractsNormal,
              theme: theme,
              color: Colors.orange,
            ),
          if (_generatePasswordsNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Generate Login Passwords',
              tasks: _generatePasswordsNormal,
              theme: theme,
              color: Colors.orange,
            ),
          if (_initiateCreditChecksNormal.isEmpty &&
              _completeCreditChecksNormal.isEmpty &&
              _completeContractsNormal.isEmpty &&
              _generatePasswordsNormal.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    Text(
                      'All tasks are up to date!',
                      style: theme.textTheme.titleLarge!
                          .copyWith(color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTaskSection({
    required String title,
    required List<TaskItem> tasks,
    required ThemeData theme,
    required Color color,
  }) {
    return ExpansionTile(
      initiallyExpanded: true,
      leading: Icon(Icons.folder_open, color: color),
      title: Text(
        '$title (${tasks.length})',
        style: theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(color.withValues(alpha: 0.1)),
            columns: const [
              DataColumn(
                  label: Text('Supplier ID',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Company Name',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Representative',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Address',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Date Added',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Days Waiting',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('Action',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: tasks.map((task) {
              return DataRow(
                cells: [
                  DataCell(Text(task.supplier.SupId.toString())),
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        task.supplier.CompanyName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(task.supplier.Representative)),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        task.supplier.Address,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(task.dateAdded)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${task.waitingDays} days',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View'),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SupplierDetailsScreen(supplier: task.supplier),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineSummary(ThemeData theme) {
    final totalInPipeline = _initiateCreditChecksOverdue.length +
        _initiateCreditChecksNormal.length +
        _completeCreditChecksOverdue.length +
        _completeCreditChecksNormal.length +
        _completeContractsOverdue.length +
        _completeContractsNormal.length +
        _generatePasswordsOverdue.length +
        _generatePasswordsNormal.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart,
                    color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Text(
                  '📊 ONBOARDING PIPELINE SUMMARY',
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPipelineItem('Total in Pipeline', totalInPipeline,
                    Icons.people, Colors.blue, theme),
                _buildPipelineItem(
                    'Credit Checks',
                    _initiateCreditChecksOverdue.length +
                        _initiateCreditChecksNormal.length +
                        _completeCreditChecksOverdue.length +
                        _completeCreditChecksNormal.length,
                    Icons.fact_check,
                    Colors.purple,
                    theme),
                _buildPipelineItem(
                    'Contracts',
                    _completeContractsOverdue.length +
                        _completeContractsNormal.length,
                    Icons.description,
                    Colors.teal,
                    theme),
                _buildPipelineItem(
                    'Passwords',
                    _generatePasswordsOverdue.length +
                        _generatePasswordsNormal.length,
                    Icons.vpn_key,
                    Colors.indigo,
                    theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPipelineItem(
      String label, int value, IconData icon, Color color, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: theme.textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// Data model for task items
class TaskItem {
  final Supplier supplier;
  final String stage;
  final String dateAdded;
  final int waitingDays;

  TaskItem({
    required this.supplier,
    required this.stage,
    required this.dateAdded,
    required this.waitingDays,
  });
}
