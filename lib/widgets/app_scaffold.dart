// lib/widgets/app_scaffold.dart

import 'package:flutter/material.dart';                                                           // Importing necessary Flutter material design components.

// `AppScaffold` is a `StatelessWidget` that provides a responsive two-panel layout.
// It's designed to be the main structure for screens that have a navigation menu
// on one side and content on the other.

class AppScaffold extends StatelessWidget {
  
  final String title;                                                                             // `title`: The title to be displayed in the app bar.
  final Widget navigationPanel;                                                                   // `navigationPanel`: The widget to be shown on the left-hand side (navigation menu).
  final Widget mainContentPanel;                                                                  // `mainContentPanel`: The widget to be shown on the right-hand side (main content).

  // Constructor for `AppScaffold`. All parameters are required.
  const AppScaffold({
    super.key,
    required this.title,
    required this.navigationPanel,
    required this.mainContentPanel,
  });

  
  @override                                                                                       // We are now explicitly creating a two-panel layout for a laptop/desktop.
  Widget build(BuildContext context) {                                                            // The `build` method describes the UI. 
    return Scaffold(    
      appBar: AppBar(                                                                             // The `appBar` is at the top of the screen, as usual.
        title: Text(title),       
        backgroundColor: Theme.of(context).primaryColor,                                          // `backgroundColor` uses the app's primary theme color.       
        iconTheme: const IconThemeData(color: Colors.white),                                    // The icon color is white for contrast.
      ),
      
      body: Row(                                                                                  // The `body` of the Scaffold is a `Row` to create the two panels side-by-side.
        children: <Widget>[
          
          SizedBox(                                                                               // The left panel for navigation is given a fixed width.
            width: 250,
            child: DecoratedBox(                                                                  // The `decoration` property is used for the background color.                            
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha((255 * 0.1).round()),             // We use a light tint of the primary color for a subtle effect.
              ),
              child: navigationPanel,
            ),
          ),
                    
          const VerticalDivider(width: 1),                                                        // `VerticalDivider` adds a thin vertical line for visual separation.
          
          Expanded(                                                                               // `Expanded` makes the main content panel take up all the remaining space.
            child: mainContentPanel,                                                              // This gives the `mainContentPanel` (which is the AddFarmerScreen) a full-sized area to work with.
          ),
        ],
      ),
    );
  }
}
