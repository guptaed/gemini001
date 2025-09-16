import 'package:flutter/material.dart';

class LeftPaneMenu extends StatelessWidget {
  final int selectedPageIndex;
  final ValueChanged<int> onMenuItemSelected;

  const LeftPaneMenu({
    super.key,
    required this.selectedPageIndex,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Menu',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.list, color: Theme.of(context).primaryColor),
                  title: const Text('List Suppliers'),
                  selected: selectedPageIndex == 0,
                  onTap: () => onMenuItemSelected(0),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                ListTile(
                  leading: Icon(Icons.add_business, color: Theme.of(context).primaryColor),
                  title: const Text('Add New Supplier'),
                  selected: selectedPageIndex == 1,
                  onTap: () => onMenuItemSelected(1),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                ListTile(
                  leading: Icon(Icons.campaign, color: Theme.of(context).primaryColor),
                  title: const Text('Add Announcement'),
                  selected: selectedPageIndex == 2,
                  onTap: () => onMenuItemSelected(2),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                ListTile(
                  leading: Icon(Icons.feed, color: Theme.of(context).primaryColor),
                  title: const Text('List Announcements'),
                  selected: selectedPageIndex == 3,
                  onTap: () => onMenuItemSelected(3),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                
                
                ListTile(
                  leading: Icon(Icons.add_box, color: Theme.of(context).primaryColor),
                  title: const Text('Add Bids'),
                  selected: selectedPageIndex == 4,
                  onTap: () => onMenuItemSelected(4),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                ListTile(
                  leading: Icon(Icons.receipt_long, color: Theme.of(context).primaryColor),
                  title: const Text('List Bids'),
                  selected: selectedPageIndex == 5,
                  onTap: () => onMenuItemSelected(5),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                ListTile(
                  leading: Icon(Icons.local_shipping, color: Theme.of(context).primaryColor),
                  title: const Text('List Shipments'),
                  selected: selectedPageIndex == 6,
                  onTap: () => onMenuItemSelected(6),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                ListTile(
                  leading: Icon(Icons.assessment, color: Theme.of(context).primaryColor),
                  title: const Text('List QA Results'),
                  selected: selectedPageIndex == 7,
                  onTap: () => onMenuItemSelected(7),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),
                ListTile(
                  leading: Icon(Icons.payments_sharp, color: Theme.of(context).primaryColor),
                  title: const Text('List Payments'),
                  selected: selectedPageIndex == 8,
                  onTap: () => onMenuItemSelected(8),
                  selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}