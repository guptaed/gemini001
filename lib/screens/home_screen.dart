// lib/screens/home_screen.dart

import 'package:flutter/material.dart';                                             // Importing necessary Flutter material design components.
import 'package:gemini001/widgets/app_scaffold.dart';                               // Importing our custom `AppScaffold` widget for the two-panel layout.
import 'package:gemini001/screens/add_farmer_screen.dart';                          // Importing the screen for adding new farmer information.
import 'package:gemini001/screens/list_farmers_screen.dart';                        // Importing the screen for listing existing farmer information.


class HomeScreen extends StatefulWidget {                                           // `HomeScreen` is a `StatefulWidget`.
                                                                                    // A `StatefulWidget` is used when the widget's state (data that affects the UI)
                                                                                    // can change over time. In this case, the `_selectedPageIndex` changes when
                                                                                    // a different menu option is selected in the left panel, which in turn changes the content displayed in the main panel.  
  const HomeScreen({super.key});                                                    // Constructor for HomeScreen. `const` keyword indicates that this widget
                                                                                    // and its properties are immutable and can be created at compile time.
  @override                                                                         
  State<HomeScreen> createState() => _HomeScreenState();                            // `createState` is overridden to create the mutable state for this widget.
}                                                                                   // It returns an instance of `_HomeScreenState`.

class _HomeScreenState extends State<HomeScreen> {                                  // `_HomeScreenState` is the mutable state for `HomeScreen`. It holds data that can change and rebuild the UI.
  
  int _selectedPageIndex = 0;                                                       // `_selectedPageIndex` keeps track of which menu option is currently selected.
                                                                                    // It starts at 0, meaning "Add New Farmer Information" will be the default view.
  final List<Widget> _pages = const [                                               // `_pages` is a list of widgets that represent the different screens
                                                                                    // that can be displayed in the main content area. This allows us to easily switch between screens by index.
    AddFarmerScreen(isPushed: false),                                               // Index 0: Add New Farmer Information screen.
    ListFarmersScreen(),                                                            // Index 1: List Farmer Information screen.                                                           // Index 2: Delete Farmer Information screen.
  ];

  final List<String> _appBarTitles = const [                                        // `_appBarTitles` is a list of titles for the app bar, corresponding to each page.
    'Add New Supplier',
    'List Suppliers',
  ];

  void _onMenuItemSelected(int index) {                                             // `_onMenuItemSelected` is a callback function that will be executed when
                                                                                    // a menu item in the left navigation panel is tapped.
                                                                                    // It updates `_selectedPageIndex` and triggers a UI rebuild.
    setState(() {                                                                   // `setState` is a crucial method for `StatefulWidget`s.
                                                                                    // It tells Flutter that the internal state of this `State` object has changed,
                                                                                    // and that the widget should be rebuilt to reflect the updated state.
      _selectedPageIndex = index;                                                   // Update the selected page index.
    });
  }

  @override
  Widget build(BuildContext context) {                                              // The `build` method describes the part of the user interface represented by this widget.
    return AppScaffold(                                                             // We use our custom `AppScaffold` (app_scaffold.dart) to provide the consistent two-panel layout.
      title: _appBarTitles[_selectedPageIndex],                                     // The `title` of the app bar will change dynamically based on the selected page.
      navigationPanel: _buildNavigationPanel(),                                     // The `navigationPanel` is the widget displayed on the left side.
      mainContentPanel: _pages[_selectedPageIndex],                                 // The `mainContentPanel` is the widget displayed on the right, which changes based on `_selectedPageIndex`.
    );
  }

  
  Widget _buildNavigationPanel() {                                                  // `_buildNavigationPanel` is a private helper method to construct the left navigation panel.
    return Column(
      
      crossAxisAlignment: CrossAxisAlignment.start,                                 // `crossAxisAlignment.start` aligns children to the start of the cross axis (left in a Column).
      children: <Widget>[        
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(                                                              // A simple text label for the navigation section.
            'Menu',            
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor),    // Using `Theme.of(context).primaryColor` to get the current app's primary color.
          ),
        ),
        
        
        const Divider(),                                                            // `Divider` adds a thin horizontal line for visual separation.
        
        // It's commonly used in lists and navigation drawers.
        
        ListTile(                                                                   // `ListTile` is a convenient widget for displaying a single row with title, subtitle, icon etc.
          leading: Icon(Icons.person_add, color: Theme.of(context).primaryColor),   // `leading` usually takes an `Icon`. Using `Theme.of(context).primaryColor` for the icon color.
          title: const Text('Add New Supplier'),                                    // `title` takes a `Text` widget.          
          selected: _selectedPageIndex == 0,                                        // `selected` highlights the tile if it's the currently selected page.
          onTap: () => _onMenuItemSelected(0),                                      // `onTap` is the callback func when the tile is tapped. Calls `_onMenuItemSelected` with the index of this option (0).
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()), // `selectedTileColor` changes the background color when selected. Using a tinted version of the primary theme color.
        ),
        
        ListTile(
          leading: Icon(Icons.list_alt, color: Theme.of(context).primaryColor),
          title: const Text('List Suppliers'),
          selected: _selectedPageIndex == 1,
          onTap: () => _onMenuItemSelected(1),         
          selectedTileColor: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()), // Using a tinted version of the primary theme color.
        ),

        
      ],
    );
  }
}
