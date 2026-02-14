import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supplier_app/providers/auth_provider.dart';
import 'package:supplier_app/screens/announcements_screen.dart';
import 'package:supplier_app/screens/my_bids_screen.dart';
import 'package:supplier_app/screens/shipments_screen.dart';
import 'package:supplier_app/screens/qa_results_screen.dart';
import 'package:supplier_app/screens/payments_screen.dart';
import 'package:supplier_app/screens/account_screen.dart';
import 'package:supplier_app/screens/login_screen.dart';
import 'package:supplier_app/widgets/home_tile.dart';
import 'package:supplier_app/widgets/status_badge.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final companyName = auth.supplierProfile?.CompanyName ?? 'Supplier';
    final creditStatus = auth.supplierProfile?.Status ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('VietFuel Supplier'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 28),
            tooltip: 'Logout',
            onPressed: () async {
              await auth.signOut(context);
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, $companyName!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  'Status: ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                StatusBadge(status: creditStatus),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.agriculture,
                        size: 48,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // 2x3 grid
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    HomeTile(
                      icon: Icons.campaign,
                      label: 'Announcements',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AnnouncementsScreen()),
                      ),
                    ),
                    HomeTile(
                      icon: Icons.gavel,
                      label: 'My Bids',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyBidsScreen()),
                      ),
                    ),
                    HomeTile(
                      icon: Icons.local_shipping,
                      label: 'Shipments',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ShipmentsScreen()),
                      ),
                    ),
                    HomeTile(
                      icon: Icons.verified,
                      label: 'QA Results',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const QAResultsScreen()),
                      ),
                    ),
                    HomeTile(
                      icon: Icons.payments,
                      label: 'Payments',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PaymentsScreen()),
                      ),
                    ),
                    HomeTile(
                      icon: Icons.person,
                      label: 'My Account',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AccountScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
