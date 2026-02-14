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
    final theme = Theme.of(context);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[100]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu Header with Icon
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal[700]!, Colors.teal[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal[700]!.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Navigation',
                  style: theme.textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Dashboard Section
                _buildSectionHeader('DASHBOARD', theme),
                _buildMenuItem(
                  context: context,
                  icon: Icons.dashboard,
                  title: 'Onboarding Dashboard',
                  index: 10,
                  theme: theme,
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 8),

                // Suppliers Section
                _buildSectionHeader('SUPPLIERS', theme),
                _buildMenuItem(
                  context: context,
                  icon: Icons.people,
                  title: 'List Suppliers',
                  index: 0,
                  theme: theme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.group_add,
                  title: 'Add New Supplier',
                  index: 1,
                  theme: theme,
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 8),

                // Announcements Section
                _buildSectionHeader('ANNOUNCEMENTS', theme),
                _buildMenuItem(
                  context: context,
                  icon: Icons.feed,
                  title: 'List Announcements',
                  index: 3,
                  theme: theme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.campaign,
                  title: 'Add Announcement',
                  index: 2,
                  theme: theme,
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 8),

                // Bids Section
                _buildSectionHeader('BIDS', theme),
                _buildMenuItem(
                  context: context,
                  icon: Icons.receipt_long,
                  title: 'List Bids',
                  index: 5,
                  theme: theme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.add_box,
                  title: 'Add Bid',
                  index: 4,
                  theme: theme,
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 8),

                // Shipments Section
                _buildSectionHeader('SHIPMENTS', theme),
                _buildMenuItem(
                  context: context,
                  icon: Icons.local_shipping,
                  title: 'List Shipments',
                  index: 7,
                  theme: theme,
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.add_circle_outline,
                  title: 'Add Shipment',
                  index: 6,
                  theme: theme,
                ),

                const SizedBox(height: 8),
                const Divider(height: 1, thickness: 1),
                const SizedBox(height: 8),

                // Operations Section
                _buildSectionHeader('OPERATIONS', theme),
                _buildMenuItem(
                  context: context,
                  icon: Icons.assessment,
                  title: 'QA Results',
                  index: 8,
                  theme: theme,
                  badge: 'Coming Soon',
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.payments_sharp,
                  title: 'Payments',
                  index: 9,
                  theme: theme,
                  badge: 'Coming Soon',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: theme.textTheme.labelSmall!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.teal[800],
          letterSpacing: 1.2,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required int index,
    required ThemeData theme,
    String? badge,
  }) {
    final isSelected = selectedPageIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onMenuItemSelected(index),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.teal[700]!.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.teal[700]!.withValues(alpha: 0.4)
                    : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.teal[700]!.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.teal[700]
                        : Colors.teal[700]!.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.teal[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.teal[900] : Colors.grey[850],
                      fontSize: 14.5,
                      height: 1.2,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      badge,
                      style: theme.textTheme.labelSmall!.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(left: 4),
                    decoration: BoxDecoration(
                      color: Colors.teal[700],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
