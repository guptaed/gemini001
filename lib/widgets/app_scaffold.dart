import 'package:flutter/material.dart';

// `AppScaffold` is a `StatelessWidget` that provides a responsive two-panel layout.
// It's designed to be the main structure for screens that have a navigation menu
// on one side and content on the other.

class AppScaffold extends StatelessWidget {
  final String
      title; // `title`: The title to be displayed (optional, can be empty).
  final Widget
      navigationPanel; // `navigationPanel`: The widget to be shown on the left-hand side (navigation menu).
  final Widget
      mainContentPanel; // `mainContentPanel`: The widget to be shown on the right-hand side (main content).

  // Constructor for `AppScaffold`. All parameters are required.
  const AppScaffold({
    super.key,
    required this.title,
    required this.navigationPanel,
    required this.mainContentPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Remove AppBar if title is empty to avoid duplication with Header
      appBar: title.isNotEmpty
          ? AppBar(
              title: Text(title),
              backgroundColor: Theme.of(context).primaryColor,
              iconTheme: const IconThemeData(color: Colors.white),
            )
          : null,
      body: Row(
        children: <Widget>[
          SizedBox(
            width: 250,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .primaryColor
                    .withAlpha((255 * 0.1).round()),
              ),
              child: navigationPanel,
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: mainContentPanel,
          ),
        ],
      ),
    );
  }
}
