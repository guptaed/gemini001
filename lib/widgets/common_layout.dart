import 'package:flutter/material.dart';
import 'package:gemini001/widgets/app_scaffold.dart';
import 'package:gemini001/widgets/footer.dart';
import 'package:gemini001/widgets/header.dart';
import 'package:gemini001/widgets/left_pane_menu.dart';

class CommonLayout extends StatelessWidget {
  final String title;
  final Widget mainContentPanel;
  final String userName;
  final VoidCallback onLogout;
  final int selectedPageIndex;
  final Function(int) onMenuItemSelected;

  const CommonLayout({
    super.key,
    required this.title,
    required this.mainContentPanel,
    required this.userName,
    required this.onLogout,
    required this.selectedPageIndex,
    required this.onMenuItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(
          title: title,
          userName: userName,
          onLogout: onLogout,
        ),
        Expanded(
          child: AppScaffold(
            title: '',
            navigationPanel: LeftPaneMenu(
              selectedPageIndex: selectedPageIndex,
              onMenuItemSelected: onMenuItemSelected,
            ),
            mainContentPanel: mainContentPanel,
          ),
        ),
        const Footer(),
      ],
    );
  }
}
