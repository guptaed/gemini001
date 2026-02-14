// Section: Imports
// This section imports necessary packages and files for the Flutter widget, including UI components, database helpers, models, screens, providers, and utilities.

// Imports Flutter's material design widgets.
import 'package:flutter/material.dart';
// Imports a custom common layout widget.
import 'package:gemini001/widgets/common_layout.dart';
// Imports a Firestore helper for database operations.
import 'package:gemini001/database/firestore_helper_new.dart';
// Imports the Supplier model.
import 'package:gemini001/models/supplier.dart';
// Imports the CreditCheck model.
import 'package:gemini001/models/credit_check.dart';
// Imports the Contract model (likely ContractInfo).
import 'package:gemini001/models/contract.dart';
// Imports the supplier details screen.
import 'package:gemini001/screens/supplier_details_screen.dart';
// Imports the list suppliers screen.
import 'package:gemini001/screens/list_suppliers_screen.dart';
// Imports the add supplier screen.
import 'package:gemini001/screens/add_supplier_screen.dart';
// Imports the add announcement screen.
import 'package:gemini001/screens/add_announcement_screen.dart';
// Imports the list announcements screen.
import 'package:gemini001/screens/list_announcements_screen.dart';
// Imports the add bid screen.
import 'package:gemini001/screens/add_bid_screen.dart';
// Imports the list bids screen.
import 'package:gemini001/screens/list_bids_screen.dart';
// Imports the add shipment screen.
import 'package:gemini001/screens/add_shipment_screen.dart';
// Imports the list shipments screen.
import 'package:gemini001/screens/list_shipments_screen.dart';
// Imports the Provider package for state management.
import 'package:provider/provider.dart';
// Imports the authentication provider.
import 'package:gemini001/providers/auth_provider.dart';
// Imports intl for date formatting.
import 'package:intl/intl.dart';
// Imports custom logging utility.
import 'package:gemini001/utils/logging.dart';

// Section: Widget Definition
// This section defines the main stateless widget for the Supplier Onboarding Dashboard.

// Defines the SupplierOnboardingDashboard as a StatefulWidget, which allows it to maintain state.
class SupplierOnboardingDashboard extends StatefulWidget {
  // Constructor for the widget, taking an optional key.
  const SupplierOnboardingDashboard({super.key});

  // Overrides the createState method to return the state object.
  @override
  State<SupplierOnboardingDashboard> createState() =>
      _SupplierOnboardingDashboardState();
}

// Section: State Class
// This section defines the state for the dashboard widget, handling data loading, processing, and UI building.

class _SupplierOnboardingDashboardState
    extends State<SupplierOnboardingDashboard> {
  // Initializes a FirestoreHelper instance for database interactions.
  final FirestoreHelper _firestoreHelper = FirestoreHelper();

  // Section: Data Holders
  // These lists hold TaskItem objects categorized by task type and overdue/normal status.

  // List for overdue initiate credit checks (waiting > 30 days).
  final List<TaskItem> _initiateCreditChecksOverdue = [];
  // List for overdue complete credit checks (waiting > 60 days).
  final List<TaskItem> _completeCreditChecksOverdue = [];
  // List for overdue complete contracts (waiting > 45 days).
  final List<TaskItem> _completeContractsOverdue = [];
  // List for overdue generate passwords (waiting > 5 days).
  final List<TaskItem> _generatePasswordsOverdue = [];

  // List for normal initiate credit checks (waiting <= 30 days).
  final List<TaskItem> _initiateCreditChecksNormal = [];
  // List for normal complete credit checks (waiting <= 60 days).
  final List<TaskItem> _completeCreditChecksNormal = [];
  // List for normal complete contracts (waiting <= 45 days).
  final List<TaskItem> _completeContractsNormal = [];
  // List for normal generate passwords (waiting <= 5 days).
  final List<TaskItem> _generatePasswordsNormal = [];

  // Counters for total overdue, due today, and upcoming tasks.
  int _totalOverdue = 0;
  int _totalDueToday = 0;
  int _totalUpcoming = 0;

  // Flag to indicate if data is loading.
  bool _isLoading = true;

  // Section: Initialization
  // This overrides the initState method to load data when the widget is initialized.

  @override
  void initState() {
    // Calls the superclass initState.
    super.initState();
    // Triggers data loading.
    _loadDashboardData();
  }

  // Section: Data Loading
  // This method asynchronously loads supplier data from Firestore, processes it, and updates the state.

  Future<void> _loadDashboardData() async {
    // Sets loading flag to true and updates UI.
    setState(() => _isLoading = true);

    // Begins try block for error handling.
    try {
      // Fetches all suppliers from Firestore as a stream and takes the first snapshot.
      final suppliers = await _firestoreHelper.streamSuppliers().first;

      // Clears all overdue lists.
      _initiateCreditChecksOverdue.clear();
      _completeCreditChecksOverdue.clear();
      _completeContractsOverdue.clear();
      _generatePasswordsOverdue.clear();
      // Clears all normal lists.
      _initiateCreditChecksNormal.clear();
      _completeCreditChecksNormal.clear();
      _completeContractsNormal.clear();
      _generatePasswordsNormal.clear();

      // Loops through each supplier.
      for (var supplier in suppliers) {
        // Fetches credit check for the supplier.
        final creditCheck =
            await _firestoreHelper.getCreditCheck(supplier.SupId);
        // Fetches contract info for the supplier.
        final contract = await _firestoreHelper.getContractInfo(supplier.SupId);

        // Determines the current stage and waiting days for the supplier.
        final stage = _determineStage(supplier, creditCheck, contract);
        // Extracts waiting days from the stage map.
        final waitingDays = stage['waitingDays'] as int;
        // Extracts stage name from the stage map.
        final stageName = stage['stage'] as String;
        // Extracts date added from the stage map.
        final dateAdded = stage['dateAdded'] as String;

        // Creates a TaskItem with the supplier data.
        final taskItem = TaskItem(
          supplier: supplier,
          stage: stageName,
          dateAdded: dateAdded,
          waitingDays: waitingDays,
        );

        // Categorizes the task based on stage and waiting days.
        switch (stageName) {
          case 'Initiate Credit Check':
            // Adds to overdue if waiting > 30 days.
            if (waitingDays > 30) {
              _initiateCreditChecksOverdue.add(taskItem);
            // Adds to normal if waiting > 0 days.
            } else if (waitingDays > 0) {
              _initiateCreditChecksNormal.add(taskItem);
            }
            break;
          case 'Complete Credit Check':
            // Adds to overdue if waiting > 60 days.
            if (waitingDays > 60) {
              _completeCreditChecksOverdue.add(taskItem);
            // Adds to normal if waiting > 0 days.
            } else if (waitingDays > 0) {
              _completeCreditChecksNormal.add(taskItem);
            }
            break;
          case 'Complete Contract':
            // Adds to overdue if waiting > 45 days.
            if (waitingDays > 45) {
              _completeContractsOverdue.add(taskItem);
            // Adds to normal if waiting > 0 days.
            } else if (waitingDays > 0) {
              _completeContractsNormal.add(taskItem);
            }
            break;
          case 'Generate Password':
            // Adds to overdue if waiting > 5 days.
            if (waitingDays > 5) {
              _generatePasswordsOverdue.add(taskItem);
            // Adds to normal if waiting > 0 days.
            } else if (waitingDays > 0) {
              _generatePasswordsNormal.add(taskItem);
            }
            break;
        }
      }

      // Calculates total overdue tasks.
      _totalOverdue = _initiateCreditChecksOverdue.length +
          _completeCreditChecksOverdue.length +
          _completeContractsOverdue.length +
          _generatePasswordsOverdue.length;

      // Calculates tasks due soon based on specific day ranges.
      _totalDueToday = _initiateCreditChecksNormal
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

      // Calculates total upcoming tasks (normal ones).
      _totalUpcoming = _initiateCreditChecksNormal.length +
          _completeCreditChecksNormal.length +
          _completeContractsNormal.length +
          _generatePasswordsNormal.length;
    // Catches any errors during data loading.
    } catch (e) {
      // Logs the error using the logger.
      logger.e('Error loading supplier onboarding dashboard data', e);
    // Finally block to handle post-execution.
    } finally {
      // Checks if the widget is still mounted before updating state.
      if (mounted) {
        // Sets loading to false and updates UI.
        setState(() => _isLoading = false);
      }
    }
  }

  // Section: Stage Determination
  // This method determines the current onboarding stage for a supplier based on credit check and contract status.

  Map<String, dynamic> _determineStage(
      Supplier supplier, CreditCheck? creditCheck, ContractInfo? contract) {
    // Gets the current date and time.
    final now = DateTime.now();

    // Checks for Stage 4: Generate Password if contract exists.
    if (contract != null) {
      // Parses the contract signed date.
      final contractDate = _parseDate(contract.SignedDate);
      // If date is valid.
      if (contractDate != null) {
        // Calculates days since contract signed.
        final daysSinceContract = now.difference(contractDate).inDays;
        // Checks if supplier status is not 'active' (assuming password not generated).
        if (supplier.Status.toLowerCase() != 'active') {
          // Returns stage data for Generate Password.
          return {
            'stage': 'Generate Password',
            'dateAdded': contract.SignedDate,
            'waitingDays': daysSinceContract,
          };
        }
      }
    }

    // Checks for Stage 3: Complete Contract if credit check is successful but no contract.
    if (creditCheck != null &&
        creditCheck.status.toLowerCase() == 'successful') {
      // If no contract exists.
      if (contract == null) {
        // Parses credit check finish date.
        final creditCheckDate = _parseDate(creditCheck.checkFinishDate);
        // If date is valid.
        if (creditCheckDate != null) {
          // Calculates days since credit check finished.
          final daysSinceCreditCheck = now.difference(creditCheckDate).inDays;
          // Returns stage data for Complete Contract.
          return {
            'stage': 'Complete Contract',
            'dateAdded': creditCheck.checkFinishDate,
            'waitingDays': daysSinceCreditCheck,
          };
        }
      }
    }

    // Checks for Stage 2: Complete Credit Check if in progress.
    if (creditCheck != null &&
        creditCheck.status.toLowerCase() == 'in progress') {
      // Parses credit check start date.
      final creditCheckStartDate = _parseDate(creditCheck.checkStartDate);
      // If date is valid.
      if (creditCheckStartDate != null) {
        // Calculates days since start.
        final daysSinceStart = now.difference(creditCheckStartDate).inDays;
        // Returns stage data for Complete Credit Check.
        return {
          'stage': 'Complete Credit Check',
          'dateAdded': creditCheck.checkStartDate,
          'waitingDays': daysSinceStart,
        };
      }
    }

    // Checks for Stage 1: Initiate Credit Check if no check or 'to start'.
    if (creditCheck == null || creditCheck.status.toLowerCase() == 'to start') {
      // Uses credit check start date or current date if null.
      final dateStr = creditCheck?.checkStartDate ?? _getCurrentDate();
      // Parses the date.
      final dateAdded = _parseDate(dateStr);
      // If date is valid.
      if (dateAdded != null) {
        // Calculates days since added.
        final daysSinceAdded = now.difference(dateAdded).inDays;
        // Returns stage data for Initiate Credit Check.
        return {
          'stage': 'Initiate Credit Check',
          'dateAdded': dateStr,
          'waitingDays': daysSinceAdded,
        };
      }
    }

    // Default return for completed onboarding.
    return {
      'stage': 'Completed',
      'dateAdded': _getCurrentDate(),
      'waitingDays': 0,
    };
  }

  // Section: Date Parsing
  // This method attempts to parse a date string in different formats.

  DateTime? _parseDate(String dateStr) {
    // Returns null if date string is empty.
    if (dateStr.isEmpty) return null;
    // Tries to parse with DateTime.parse.
    try {
      return DateTime.parse(dateStr);
    // Catches error and tries alternative format.
    } catch (e) {
      // Tries parsing with 'yyyy-MM-dd' format.
      try {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      // Returns null on failure.
      } catch (e) {
        return null;
      }
    }
  }

  // Section: Current Date
  // This method returns the current date in 'yyyy-MM-dd' format.

  String _getCurrentDate() {
    // Formats current date using DateFormat.
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  // Section: Menu Handling
  // This method handles navigation based on selected menu item index.

  void _onMenuItemSelected(int index) {
    // Switches based on index.
    switch (index) {
      case 0:
        // Navigates to ListSuppliersScreen.
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListSuppliersScreen()));
        break;
      case 1:
        // Navigates to AddSupplierScreen.
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddSupplierScreen()));
        break;
      case 2:
        // Navigates to AddAnnouncementScreen.
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddAnnouncementScreen()));
        break;
      case 3:
        // Navigates to ListAnnouncementsScreen.
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListAnnouncementsScreen()));
        break;
      case 4:
        // Navigates to AddBidScreen.
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddBidScreen()));
        break;
      case 5:
        // Navigates to ListBidsScreen.
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ListBidsScreen()));
        break;
      case 6:
        // Navigates to AddShipmentScreen.
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const AddShipmentScreen()));
        break;
      case 7:
        // Navigates to ListShipmentsScreen.
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const ListShipmentsScreen()));
        break;
    }
  }

  // Section: Build Method
  // This overrides the build method to construct the UI.

  @override
  Widget build(BuildContext context) {
    // Gets the user's email from AuthProvider or defaults to 'User'.
    final userName = Provider.of<AuthProvider>(context).user?.email ?? 'User';
    // Gets the current theme.
    final theme = Theme.of(context);

    // Returns the CommonLayout widget with title, username, and content.
    return CommonLayout(
      title: 'Supplier Onboarding Dashboard',
      userName: userName,
      selectedPageIndex: 10,
      onMenuItemSelected: _onMenuItemSelected,
      // Sets main content: loading state or refreshable content.
      mainContentPanel: _isLoading
          ? _buildLoadingState(theme)
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Builds welcome section.
                    _buildWelcomeSection(userName, theme),
                    const SizedBox(height: 24),

                    // Builds KPI cards.
                    _buildKPICards(theme),
                    const SizedBox(height: 24),

                    // Conditionally builds critical section if overdue > 0.
                    if (_totalOverdue > 0) ...[
                      _buildCriticalSection(theme),
                      const SizedBox(height: 24),
                    ],

                    // Builds normal tasks section.
                    _buildNormalTasksSection(theme),
                    const SizedBox(height: 24),

                    // Builds pipeline summary.
                    _buildPipelineSummary(theme),
                  ],
                ),
              ),
            ),
    );
  }

  // Section: Loading State UI
  // This method builds the UI for when data is loading, including animations.

  Widget _buildLoadingState(ThemeData theme) {
    // Centers the loading content.
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animates a truck icon moving left to right.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 10),
            builder: (context, value, child) {
              // Translates the icon based on animation value.
              return Transform.translate(
                offset: Offset(
                  (value * 100) - 50, // Move from left to right
                  0,
                ),
                // Icon for shipping truck with varying opacity.
                child: Icon(
                  Icons.local_shipping,
                  size: 50,
                  color:
                      theme.primaryColor.withValues(alpha: 0.3 + (value * 0.7)),
                ),
              );
            },
            // Restarts animation if still loading.
            onEnd: () {
              if (mounted && _isLoading) {
                setState(() {}); // Restart animation
              }
            },
          ),
          const SizedBox(height: 32),

          // Animates opacity of loading text.
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              // Applies opacity to text.
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
            // Restarts animation if still loading.
            onEnd: () {
              if (mounted && _isLoading) {
                setState(() {}); // Restart animation
              }
            },
          ),
          const SizedBox(height: 16),

          // Subtitle text.
          Text(
            'Fetching supplier onboarding information',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Linear progress indicator.
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
            ),
          ),
          const SizedBox(height: 16),

          // Container for loading steps.
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
                // Builds step for fetching suppliers.
                _buildLoadingStep('Fetching suppliers', true, theme),
                // Builds step for processing credit checks.
                _buildLoadingStep('Processing credit checks', true, theme),
                // Builds step for analyzing contracts.
                _buildLoadingStep('Analyzing contracts', true, theme),
                // Builds step for calculating metrics.
                _buildLoadingStep('Calculating metrics', true, theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Section: Loading Step UI
  // This method builds a single loading step row with spinner and text.

  Widget _buildLoadingStep(String text, bool isActive, ThemeData theme) {
    // Pads the row.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Sized box for circular progress indicator.
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
          // Text for the step.
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

  // Section: Welcome Section UI
  // This method builds the welcome card with role and last updated info.

  Widget _buildWelcomeSection(String userName, ThemeData theme) {
    // Returns a card with gradient background.
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row for icon, text, and refresh button.
            Row(
              children: [
                Icon(Icons.dashboard, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role: Supplier Onboarding Specialist',
                        style: theme.textTheme.headlineSmall!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                // Refresh button.
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadDashboardData,
                  tooltip: 'Refresh Dashboard',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Last updated text.
            Text(
              'Last updated: ${DateFormat('MMM dd, yyyy - hh:mm a').format(DateTime.now())}',
              style: theme.textTheme.bodySmall!.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section: KPI Cards UI
  // This method builds a row of KPI cards for overdue, due soon, and upcoming.

  Widget _buildKPICards(ThemeData theme) {
    // Returns a row with expanded KPI cards.
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
            value: _totalDueToday.toString(),
            icon: Icons.warning_amber_outlined,
            color: Colors.orange,
            theme: theme,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildKPICard(
            title: 'UPCOMING',
            value: _totalUpcoming.toString(),
            icon: Icons.schedule,
            color: Colors.green,
            theme: theme,
          ),
        ),
      ],
    );
  }

  // Section: Single KPI Card UI
  // This method builds an individual KPI card with title, value, icon, and color.

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    // Returns a card with gradient and content.
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
            // Row for icon and value.
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
            const SizedBox(height: 8),
            // Title text.
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

  // Section: Critical Section UI
  // This method builds the critical tasks section for overdue items.

  Widget _buildCriticalSection(ThemeData theme) {
    // Returns a card with gradient and task sections.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.red.withValues(alpha: 0.05), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header for critical section.
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
                    ),
                  ),
                ],
              ),
            ),
            // Conditionally adds initiate credit checks overdue section.
            if (_initiateCreditChecksOverdue.isNotEmpty)
              _buildTaskSection(
                title: 'Initiate Credit Checks (Waiting > 30 days)',
                tasks: _initiateCreditChecksOverdue,
                theme: theme,
                color: Colors.red,
              ),
            // Conditionally adds complete credit checks overdue section.
            if (_completeCreditChecksOverdue.isNotEmpty)
              _buildTaskSection(
                title: 'Complete Credit Checks (Waiting > 60 days)',
                tasks: _completeCreditChecksOverdue,
                theme: theme,
                color: Colors.red,
              ),
            // Conditionally adds complete contracts overdue section.
            if (_completeContractsOverdue.isNotEmpty)
              _buildTaskSection(
                title: 'Complete Contract Signups (Waiting > 45 days)',
                tasks: _completeContractsOverdue,
                theme: theme,
                color: Colors.red,
              ),
            // Conditionally adds generate passwords overdue section.
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

  // Section: Normal Tasks Section UI
  // This method builds the section for normal (non-overdue) tasks.

  Widget _buildNormalTasksSection(ThemeData theme) {
    // Returns a card with header and task sections or empty message.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header for tasks section.
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
          // Conditionally adds initiate credit checks normal section.
          if (_initiateCreditChecksNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Initiate Credit Checks',
              tasks: _initiateCreditChecksNormal,
              theme: theme,
              color: Colors.orange,
            ),
          // Conditionally adds complete credit checks normal section.
          if (_completeCreditChecksNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Complete Credit Checks',
              tasks: _completeCreditChecksNormal,
              theme: theme,
              color: Colors.orange,
            ),
          // Conditionally adds complete contracts normal section.
          if (_completeContractsNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Complete Contract Signups',
              tasks: _completeContractsNormal,
              theme: theme,
              color: Colors.orange,
            ),
          // Conditionally adds generate passwords normal section.
          if (_generatePasswordsNormal.isNotEmpty)
            _buildTaskSection(
              title: 'Generate Login Passwords',
              tasks: _generatePasswordsNormal,
              theme: theme,
              color: Colors.orange,
            ),
          // Shows message if no normal tasks.
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

  // Section: Task Section UI
  // This method builds an expansion tile with a data table for tasks.

  Widget _buildTaskSection({
    required String title,
    required List<TaskItem> tasks,
    required ThemeData theme,
    required Color color,
  }) {
    // Returns an ExpansionTile that is initially expanded.
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
        // Horizontal scrollable DataTable.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor:
                WidgetStateProperty.all(color.withValues(alpha: 0.1)),
            // Defines columns for the table.
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
            // Maps tasks to DataRows.
            rows: tasks.map((task) {
              return DataRow(
                cells: [
                  // Cell for Supplier ID.
                  DataCell(Text(task.supplier.SupId.toString())),
                  // Cell for Company Name with width and ellipsis.
                  DataCell(
                    SizedBox(
                      width: 200,
                      child: Text(
                        task.supplier.CompanyName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Cell for Representative.
                  DataCell(Text(task.supplier.Representative)),
                  // Cell for Address with width and ellipsis.
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        task.supplier.Address,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Cell for Date Added.
                  DataCell(Text(task.dateAdded)),
                  // Cell for Days Waiting with styled container.
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
                  // Cell for Action button to view details.
                  DataCell(
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('View'),
                      onPressed: () {
                        // Navigates to SupplierDetailsScreen.
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

  // Section: Pipeline Summary UI
  // This method builds the onboarding pipeline summary card.

  Widget _buildPipelineSummary(ThemeData theme) {
    // Calculates total in pipeline.
    final totalInPipeline = _initiateCreditChecksOverdue.length +
        _initiateCreditChecksNormal.length +
        _completeCreditChecksOverdue.length +
        _completeCreditChecksNormal.length +
        _completeContractsOverdue.length +
        _completeContractsNormal.length +
        _generatePasswordsOverdue.length +
        _generatePasswordsNormal.length;

    // Returns a card with header and pipeline items.
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row.
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
            // Row of pipeline items.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Total in Pipeline item.
                _buildPipelineItem('Total in Pipeline', totalInPipeline,
                    Icons.people, Colors.blue, theme),
                // Credit Checks item.
                _buildPipelineItem(
                    'Credit Checks',
                    _initiateCreditChecksOverdue.length +
                        _initiateCreditChecksNormal.length +
                        _completeCreditChecksOverdue.length +
                        _completeCreditChecksNormal.length,
                    Icons.fact_check,
                    Colors.purple,
                    theme),
                // Contracts item.
                _buildPipelineItem(
                    'Contracts',
                    _completeContractsOverdue.length +
                        _completeContractsNormal.length,
                    Icons.description,
                    Colors.teal,
                    theme),
                // Passwords item.
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

  // Section: Pipeline Item UI
  // This method builds an individual pipeline summary item.

  Widget _buildPipelineItem(
      String label, int value, IconData icon, Color color, ThemeData theme) {
    // Returns a column with icon, value, and label.
    return Column(
      children: [
        // Circular container for icon.
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        const SizedBox(height: 8),
        // Value text.
        Text(
          value.toString(),
          style: theme.textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        // Label text.
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

// Section: TaskItem Model
// This class defines a data model for task items in the dashboard.

class TaskItem {
  // Supplier object.
  final Supplier supplier;
  // Stage name.
  final String stage;
  // Date added string.
  final String dateAdded;
  // Waiting days integer.
  final int waitingDays;

  // Constructor for TaskItem.
  TaskItem({
    required this.supplier,
    required this.stage,
    required this.dateAdded,
    required this.waitingDays,
  });
}