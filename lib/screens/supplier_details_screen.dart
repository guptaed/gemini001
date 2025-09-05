import 'package:flutter/material.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/bank.dart';
import 'package:gemini001/widgets/app_scaffold.dart';
import 'package:gemini001/widgets/left_pane_menu.dart';
import 'package:gemini001/widgets/header.dart';
import 'package:gemini001/widgets/footer.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/screens/add_supplier_screen.dart'; // Import AddSupplierScreen

class SupplierDetailsScreen extends StatefulWidget {
  final Supplier supplier;

  const SupplierDetailsScreen({super.key, required this.supplier});

  @override
  State<SupplierDetailsScreen> createState() => _SupplierDetailsScreenState();
}

class _SupplierDetailsScreenState extends State<SupplierDetailsScreen> {
  late Future<ContractInfo?> _contractInfoFuture;
  late Future<BankDetails?> _bankDetailsFuture;

  @override
  void initState() {
    super.initState();
    _contractInfoFuture = FirestoreHelper().getContractInfo(widget.supplier.SupId);
    _bankDetailsFuture = FirestoreHelper().getBankDetails(widget.supplier.SupId);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle headlineSmall = theme.textTheme.headlineSmall!;
    final TextStyle bodyMedium = theme.textTheme.bodyMedium!;
    final String userName = 'Ashish Gupta'; // Match with home_screen.dart for consistency

    return Column(
      children: [
        Header(
          title: 'Supplier Details',
          userName: userName,
          onLogout: () {
            // Add logout logic (e.g., clear session, navigate to login screen)
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
          },
        ),
        Expanded(
          child: AppScaffold(
            title: '', // Disable AppScaffold's app bar
            navigationPanel: LeftPaneMenu(
              selectedPageIndex: -1, // No specific selection for this screen
              onMenuItemSelected: (index) {
                // Handle navigation based on selected index
                if (index == 0) {
                  Navigator.popUntil(context, (route) => route.isFirst); // Back to List Suppliers
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddSupplierScreen(isPushed: true)),
                  ); // Navigate to Add New Supplier
                }
                // Other indices (2-8) can be ignored or handled as needed later
              },
            ),
            mainContentPanel: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card 1: Supplier Details
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
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            height: 10,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Supplier ID', widget.supplier.SupId.toString(), bodyMedium, theme),
                          _buildDetailRow('Representative', widget.supplier.Representative, bodyMedium, theme),
                          _buildDetailRow('Title', widget.supplier.Title, bodyMedium, theme),
                          // _buildDetailRow('Company Name', widget.supplier.CompanyName, bodyMedium, theme),
                          _buildDetailRow('Address', widget.supplier.Address, bodyMedium, theme),
                          _buildDetailRow('Telephone', widget.supplier.Tel, bodyMedium, theme),
                          _buildDetailRow('Email', widget.supplier.Email, bodyMedium, theme),
                          _buildDetailRow('Tax Code', widget.supplier.TaxCode, bodyMedium, theme),
                          _buildDetailRow('Latest Status', widget.supplier.Status, bodyMedium, theme),
                          const SizedBox(height: 16),
                          AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    // Navigate to edit screen (to be implemented)
                                    // final result = await Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => EditSupplierScreen(supplier: widget.supplier),
                                    //   ),
                                    // );
                                    // if (result == true) {
                                    //   // Refresh logic if needed
                                    // }
                                  },
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
                  // Row with Card 2: Contract Information and Card 3: Bank Details
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
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigate to AddContractInfoScreen (to be implemented)
                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => AddContractInfoScreen(supId: widget.supplier.SupId)));
                                          },
                                          child: const Text('Add Contract Information'),
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
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigate to AddBankInfoScreen (to be implemented)
                                            // Navigator.push(context, MaterialPageRoute(builder: (context) => AddBankInfoScreen(supId: widget.supplier.SupId)));
                                          },
                                          child: const Text('Add Bank Information'),
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
          ),
        ),
        const Footer(),
      ],
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
}
