import 'package:flutter/material.dart';
import 'package:gemini001/widgets/common_layout.dart';
import 'package:gemini001/screens/add_supplier_screen.dart';
import 'package:gemini001/screens/list_suppliers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;
  final List<Widget> _pages = const [
    ListSuppliersScreen(),
    AddSupplierScreen(),
  ];
  final List<String> _appBarTitles = const [
    'List Suppliers',
    'Add New Supplier',
  ];
  final String _userName = 'Ashish Gupta';

  void _onMenuItemSelected(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _logout() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logged out')));
  }

  @override
  Widget build(BuildContext context) {
    return CommonLayout(
      title: _appBarTitles[_selectedPageIndex],
      mainContentPanel: _pages[_selectedPageIndex],
      userName: _userName,
      onLogout: _logout,
      selectedPageIndex: _selectedPageIndex,
      onMenuItemSelected: (index) {
        if (index < _pages.length) {
          setState(() {
            _selectedPageIndex = index;
          });
        }
      },
    );
  }
}
