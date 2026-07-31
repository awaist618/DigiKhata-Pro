import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/dashboard/presentation/dashboard_screen.dart';
import 'package:khataplus/features/profile/presentation/screens/profile_screen.dart';
import 'package:khataplus/features/customer/presentation/screens/customer_list_screen.dart';
import 'package:khataplus/features/profile/presentation/providers/profile_provider.dart';
import 'package:khataplus/features/supplier/presentation/screens/supplier_list_screen.dart';
import 'package:khataplus/features/ledger/presentation/screens/ledger_screen.dart';
import 'package:khataplus/features/reports/presentation/screens/reports_screen.dart';
import 'package:khataplus/core/widgets/offline_indicator.dart';
import 'package:khataplus/core/providers/settings_provider.dart';

// Simple index provider for navigation
final navIndexProvider = StateProvider<int>((ref) => 0);

class MainWrapper extends ConsumerWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);

    final List<Widget> screens = [
      const DashboardScreen(),
      const CustomerListScreen(),
      const LedgerScreen(),
      const ReportsScreen(),
      const ProfileScreen(),
    ];

    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.isDarkMode;

    return Scaffold(
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 75,
          elevation: 0,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => ref.read(navIndexProvider.notifier).state = index,
          backgroundColor: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
          indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            _buildNavDestination(Icons.dashboard_rounded, 'Dashboard', isDarkMode),
            _buildNavDestination(Icons.people_alt_rounded, 'Customers', isDarkMode),
            _buildNavDestination(Icons.account_balance_wallet_rounded, 'Ledger', isDarkMode),
            _buildNavDestination(Icons.assessment_rounded, 'Reports', isDarkMode),
            _buildNavDestination(Icons.person_rounded, 'Profile', isDarkMode),
          ],
        ),
      ),
    );
  }

  NavigationDestination _buildNavDestination(IconData icon, String label, bool isDarkMode) {
    return NavigationDestination(
      icon: Icon(icon, color: isDarkMode ? Colors.white60 : Colors.grey[600], size: 24),
      selectedIcon: Icon(icon, color: AppColors.primaryBlue, size: 26),
      label: label,
    );
  }
}
