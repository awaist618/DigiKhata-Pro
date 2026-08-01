import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/admin/data/models/admin_stats.dart';
import 'package:khataplus/features/admin/presentation/providers/admin_provider.dart';
import 'package:khataplus/features/admin/presentation/widgets/admin_stat_card.dart';
import 'package:khataplus/features/admin/presentation/widgets/admin_revenue_chart.dart';
import 'package:khataplus/features/admin/presentation/screens/global_transaction_feed.dart';
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
              expandedHeight: 180,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.adminPrimary,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'admin_control_center'.tr(),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'System Overview & Management',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                background: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.adminGradientStart, AppColors.adminGradientEnd],
                        ),
                      ),
                    ),
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                    onPressed: () => ref.invalidate(adminStatsProvider),
                  ),
                ),
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
                      childAspectRatio: 1.1,
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
                          color: Colors.teal,
                        ),
                        AdminStatCard(
                          title: 'total_revenue'.tr(),
                          value: 'PKR ${stats.totalRevenue.toStringAsFixed(0)}',
                          icon: Icons.account_balance_wallet_rounded,
                          color: Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalTransactionFeed())),
                      icon: const Icon(Icons.history_rounded),
                      label: const Text('View Global Transaction Feed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.adminPrimary.withValues(alpha: 0.1),
                        foregroundColor: AppColors.adminPrimary,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const AdminRevenueChart(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(stats, isDarkMode),
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

  Widget _buildRecentActivity(AdminStats stats, bool isDarkMode) {
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
          if (stats.recentAlerts.isEmpty)
            Center(child: Text('No recent activity', style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12))),
          ...stats.recentAlerts.map((alert) {
            IconData icon = Icons.notifications_active;
            Color color = Colors.blue;
            if (alert.type == 'user') {
              icon = Icons.person_add_rounded;
              color = Colors.blue;
            } else if (alert.type == 'transaction') {
              icon = Icons.warning_amber_rounded;
              color = Colors.amber;
            }
            
            final timeAgo = _getTimeAgo(alert.timestamp);

            return _buildActivityItem(alert.title, timeAgo, icon, color);
          }),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 13, color: color == Colors.blue ? null : null))), // Just to keep logic simple
          Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
