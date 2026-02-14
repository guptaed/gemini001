import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_app/database/firestore_helper.dart';
import 'package:supplier_app/providers/auth_provider.dart';
import 'package:supplier_app/widgets/status_badge.dart';
import 'package:vietfuel_shared/vietfuel_shared.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  CreditCheck? _creditCheck;
  ContractInfo? _contract;
  List<BankDetails> _banks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final supId = auth.supId;
    if (supId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final results = await Future.wait([
        FirestoreHelper().getCreditCheckForSupplier(supId),
        FirestoreHelper().getContractForSupplier(supId),
        FirestoreHelper().getBankDetailsForSupplier(supId),
      ]);

      setState(() {
        _creditCheck = results[0] as CreditCheck?;
        _contract = results[1] as ContractInfo?;
        _banks = results[2] as List<BankDetails>;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('Error loading account data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final supplier = auth.supplierProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : supplier == null
              ? const Center(
                  child: Text('Unable to load account details.',
                      style: TextStyle(fontSize: 16)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Info
                      _SectionCard(
                        title: 'Company Information',
                        icon: Icons.business,
                        children: [
                          _InfoRow(
                              label: 'Company',
                              value: supplier.CompanyName),
                          _InfoRow(
                              label: 'Address', value: supplier.Address),
                          _InfoRow(label: 'Phone', value: supplier.Tel),
                          _InfoRow(label: 'Email', value: supplier.Email),
                          _InfoRow(
                              label: 'Tax Code', value: supplier.TaxCode),
                          _InfoRow(
                              label: 'Representative',
                              value: supplier.Representative),
                          _InfoRow(label: 'Title', value: supplier.Title),
                          Row(
                            children: [
                              const SizedBox(
                                width: 130,
                                child: Text('Status',
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xFF616161))),
                              ),
                              StatusBadge(status: supplier.Status),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Credit Check
                      _SectionCard(
                        title: 'Credit Check',
                        icon: Icons.fact_check,
                        children: _creditCheck == null
                            ? [
                                const Text('No credit check on record.',
                                    style: TextStyle(fontSize: 15))
                              ]
                            : [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 130,
                                      child: Text('Status',
                                          style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xFF616161))),
                                    ),
                                    StatusBadge(
                                        status: _creditCheck!.status),
                                  ],
                                ),
                                _InfoRow(
                                    label: 'Check Company',
                                    value: _creditCheck!.checkCompany),
                                _InfoRow(
                                    label: 'Start Date',
                                    value: _creditCheck!.checkStartDate),
                                _InfoRow(
                                    label: 'Finish Date',
                                    value: _creditCheck!.checkFinishDate),
                                _InfoRow(
                                    label: 'Supply Capacity',
                                    value:
                                        '${_creditCheck!.supplyCapacity}'),
                              ],
                      ),
                      const SizedBox(height: 16),

                      // Contract
                      _SectionCard(
                        title: 'Contract',
                        icon: Icons.description,
                        children: _contract == null
                            ? [
                                const Text('No contract on record.',
                                    style: TextStyle(fontSize: 15))
                              ]
                            : [
                                _InfoRow(
                                    label: 'Contract No',
                                    value: _contract!.ContractNo),
                                _InfoRow(
                                    label: 'Signed Date',
                                    value: _contract!.SignedDate),
                                _InfoRow(
                                    label: 'Validity',
                                    value:
                                        '${_contract!.ValidityYrs} years'),
                              ],
                      ),
                      const SizedBox(height: 16),

                      // Bank Details
                      _SectionCard(
                        title: 'Bank Details',
                        icon: Icons.account_balance,
                        children: _banks.isEmpty
                            ? [
                                const Text('No bank details on record.',
                                    style: TextStyle(fontSize: 15))
                              ]
                            : _banks
                                .map((bank) => Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _InfoRow(
                                              label: 'Bank',
                                              value: bank.BankName),
                                          _InfoRow(
                                              label: 'Branch',
                                              value: bank.BranchName),
                                          _InfoRow(
                                              label: 'Account',
                                              value: bank.AccountNumber),
                                          _InfoRow(
                                              label: 'Account Name',
                                              value: bank.AccountName),
                                          if (bank.PreferredBank)
                                            const Padding(
                                              padding: EdgeInsets.only(
                                                  top: 4),
                                              child: Text(
                                                'Preferred Bank',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF2E7D32),
                                                  fontWeight:
                                                      FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF616161)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
