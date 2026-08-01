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
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => ref.read(adminNavIndexProvider.notifier).state = index,
        backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.1),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard, color: AppColors.primaryBlue), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people_outline), selectedIcon: Icon(Icons.people, color: AppColors.primaryBlue), label: 'Users'),
          NavigationDestination(icon: Icon(Icons.business_outlined), selectedIcon: Icon(Icons.business, color: AppColors.primaryBlue), label: 'Businesses'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined), selectedIcon: Icon(Icons.assessment, color: AppColors.primaryBlue), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings, color: AppColors.primaryBlue), label: 'Settings'),
        ],
      ),
    );
  }
}
