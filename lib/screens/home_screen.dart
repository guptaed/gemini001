import 'package:flutter/material.dart';
import 'package:gemini001/widgets/app_scaffold.dart';
import 'package:gemini001/screens/add_farmer_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';
import 'package:gemini001/widgets/header.dart';
import 'package:gemini001/widgets/footer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;
  final List<Widget> _pages = const [
    ListSuppliersScreen(),
    AddFarmerScreen(isPushed: false),
  ];

  final List<String> _appBarTitles = const [
    'List Suppliers',
    'Add New Supplier',
  ];

  final String _userName = 'Ashish Gupta'; // Replace with actual logged-in user logic

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _logout() {
    // Add logout logic (e.g., clear session, navigate to login screen)
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(
          title: _appBarTitles[_selectedPageIndex],
          userName: _userName,
          onLogout: _logout,
        ),
        Expanded(
          child: AppScaffold(
            title: '', // Set to empty string to disable AppScaffold's app bar
            navigationPanel: _buildNavigationPanel(),
            mainContentPanel: _pages[_selectedPageIndex],
          ),
        ),
        const Footer(),
      ],
    );
  }

  Widget _buildNavigationPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Menu',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor),
          ),
        ),
        const Divider(),
        ListTile(
          leading: Icon(Icons.people, color: Theme.of(context).primaryColor),
          title: const Text('List Suppliers'),
          selected: _selectedPageIndex == 0,
          onTap: () => _onMenuItemSelected(0),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.group_add, color: Theme.of(context).primaryColor),
          title: const Text('Add New Supplier'),
          selected: _selectedPageIndex == 1,
          onTap: () => _onMenuItemSelected(1),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.campaign, color: Theme.of(context).primaryColor),
          title: const Text('Add Announcement'),
          selected: _selectedPageIndex == 2,
          onTap: () => _onMenuItemSelected(2),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.feed, color: Theme.of(context).primaryColor),
          title: const Text('List Announcements'),
          selected: _selectedPageIndex == 3,
          onTap: () => _onMenuItemSelected(3),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.add_box, color: Theme.of(context).primaryColor),
          title: const Text('Add Bids'),
          selected: _selectedPageIndex == 4,
          onTap: () => _onMenuItemSelected(4),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
          title: const Text('List Bids'),
          selected: _selectedPageIndex == 5,
          onTap: () => _onMenuItemSelected(5),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
          title: const Text('List Shipments'),
          selected: _selectedPageIndex == 6,
          onTap: () => _onMenuItemSelected(6),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.assessment, color: Theme.of(context).primaryColor),
          title: const Text('List QA Results'),
          selected: _selectedPageIndex == 7,
          onTap: () => _onMenuItemSelected(7),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
        ListTile(
          leading: Icon(Icons.payments_sharp, color: Theme.of(context).primaryColor),
          title: const Text('List Payments'),
          selected: _selectedPageIndex == 8,
          onTap: () => _onMenuItemSelected(8),
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
        ),
      ],
    );
  }
}