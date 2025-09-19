import 'package:flutter/material.dart';
import 'package:gemini001/models/supplier.dart';
import 'package:gemini001/models/contract.dart';
import 'package:gemini001/models/bank.dart';
import 'package:gemini001/models/credit_check.dart';
import 'package:gemini001/models/bid.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/database/firestore_helper_new.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/add_announcement_screen.dart';
import 'package:gemini001/screens/list_announcements_screen.dart';
import 'package:gemini001/screens/add_bid_screen.dart';
import 'package:gemini001/screens/list_bids_screen.dart';
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
  late Future<CreditCheck?> _creditCheckFuture;
  late Future<List<Bid>> _bidsFuture;

  @override
  void initState() {
    super.initState();
    _contractInfoFuture = FirestoreHelper().getContractInfo(widget.supplier.SupId);
    _bankDetailsFuture = FirestoreHelper().getBankDetails(widget.supplier.SupId);
    _creditCheckFuture = FirestoreHelper().getCreditCheck(widget.supplier.SupId);
    _bidsFuture = FirestoreHelper().getBidsBySupplier(widget.supplier.SupId);
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
                                      onPressed: () {},
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
                                  _buildDetailRow('Check Start Date', creditCheck.checkStartDate, bodyMedium, theme),
                                  _buildDetailRow('Check Finish Date', creditCheck.checkFinishDate, bodyMedium, theme),
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
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bids',
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
                    FutureBuilder<List<Bid>>(
                      future: _bidsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}', style: bodyMedium);
                        }
                        final bids = snapshot.data ?? [];
                        if (bids.isEmpty) {
                          return const Center(child: Text('No bids found for this supplier'));
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bids.length,
                          separatorBuilder: (context, index) => const Divider(height: 8),
                          itemBuilder: (context, index) {
                            final bid = bids[index];
                            return ExpansionTile(
                              title: Text(
                                'Bid ID: ${bid.bidId}',
                                style: bodyMedium.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Announcement ID: ${bid.announceId} | Quantity: ${bid.quantity} | Status: ${bid.status}',
                                style: bodyMedium,
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDetailRow('Submitted Date', bid.submittedDate, bodyMedium, theme),
                                      _buildDetailRow('Quantity Accepted', bid.quantityAccepted.toString(), bodyMedium, theme),
                                      _buildDetailRow('Accept/Reject Date', bid.acceptRejectDate.isEmpty ? 'Not set' : bid.acceptRejectDate, bodyMedium, theme),
                                      _buildDetailRow('Notes', bid.notes.isEmpty ? 'None' : bid.notes, bodyMedium, theme),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Placeholder for BidDetailsScreen navigation
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: theme.colorScheme.primary,
                                            foregroundColor: theme.colorScheme.onPrimary,
                                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text('View Bid'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
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

