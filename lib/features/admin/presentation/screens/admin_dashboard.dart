import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_revenue_chart.dart';

import 'package:easy_localization/easy_localization.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: statsAsync.when(
        data: (stats) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.adminPrimary,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                title: Text(
                  'admin_control_center'.tr(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.adminGradientStart, AppColors.adminGradientEnd],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                  onPressed: () => ref.invalidate(adminStatsProvider),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'system_overview'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: AppColors.adminPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        AdminStatCard(
                          title: 'total_users'.tr(),
                          value: stats.totalUsers.toString(),
                          icon: Icons.group_add_rounded,
                          color: Colors.blue,
                        ),
                        AdminStatCard(
                          title: 'total_businesses'.tr(),
                          value: stats.totalBusinesses.toString(),
                          icon: Icons.store_mall_directory_rounded,
                          color: Colors.orange,
                        ),
                        AdminStatCard(
                          title: 'total_transactions'.tr(),
                          value: stats.totalTransactions.toString(),
                          icon: Icons.swap_horizontal_circle_rounded,
                          color: Colors.emerald,
                        ),
                        AdminStatCard(
                          title: 'total_revenue'.tr(),
                          value: 'PKR ${stats.totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet_rounded,
                          color: Colors.violet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const AdminRevenueChart(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(isDarkMode),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.adminPrimary)),
        error: (err, _) => Center(child: Text('Error loading stats: $err')),
      ),
    );
  }

  Widget _buildRecentActivity(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('recent_alerts'.tr(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          // Placeholder for real activity log
          _buildActivityItem('New user registration: Muhammad Ali', '2 mins ago', Icons.person_add, Colors.blue),
          _buildActivityItem('High volume transaction detected', '1 hour ago', Icons.warning_amber, Colors.amber),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 13))),
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
