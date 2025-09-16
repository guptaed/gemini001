import 'package:flutter/material.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/bank.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:provider/provider.dart';
import 'package:gemini001/providers/auth_provider.dart';

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
    }
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
                    _buildDetailRow('Latest Status', widget.supplier.Status, bodyMedium, theme),
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
                                    onPressed: () {},
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
                                    onPressed: () {},
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
      userName: userName,
      selectedPageIndex: 0,
      onMenuItemSelected: _onMenuItemSelected,
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
