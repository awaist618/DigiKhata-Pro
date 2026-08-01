import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'admin_dashboard.dart';
import 'user_management_screen.dart';
import 'business_management_screen.dart';
import 'banner_management_screen.dart';
import 'settings_screen.dart'; // Admin specific settings

import 'admin_reports_screen.dart';

final adminNavIndexProvider = StateProvider<int>((ref) => 0);

class AdminMainWrapper extends ConsumerWidget {
  const AdminMainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(adminNavIndexProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      const AdminDashboard(),
      const UserManagementScreen(),
      const BusinessManagementScreen(),
      const AdminReportsScreen(),
      const AdminSettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.08),
              blurRadius: 30,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => ref.read(adminNavIndexProvider.notifier).state = index,
          backgroundColor: isDarkMode ? AppColors.adminSurface : Colors.white,
          indicatorColor: AppColors.adminPrimary.withValues(alpha: 0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _buildNavDest(Icons.grid_view_rounded, 'Dashboard', 0, selectedIndex, isDarkMode),
            _buildNavDest(Icons.group_rounded, 'Users', 1, selectedIndex, isDarkMode),
            _buildNavDest(Icons.storefront_rounded, 'Directory', 2, selectedIndex, isDarkMode),
            _buildNavDest(Icons.bar_chart_rounded, 'Reports', 3, selectedIndex, isDarkMode),
            _buildNavDest(Icons.settings_suggest_rounded, 'Settings', 4, selectedIndex, isDarkMode),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavDest(IconData icon, String label, int index, int selectedIndex, bool isDarkMode) {
    final isSelected = index == selectedIndex;
    return NavigationDestination(
      icon: Icon(
        icon,
        color: isSelected ? AppColors.adminPrimary : (isDarkMode ? Colors.white54 : Colors.grey[600]),
        size: isSelected ? 28 : 24,
      ),
      label: label,
    );
  }
}
