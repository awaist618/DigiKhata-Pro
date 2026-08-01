import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import '../widgets/admin_stat_card.dart';
import '../widgets/admin_revenue_chart.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Admin Control Center', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(adminStatsProvider),
          ),
        ],
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Overview', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  AdminStatCard(title: 'Total Users', value: stats.totalUsers.toString(), icon: Icons.person, color: Colors.blue),
                  AdminStatCard(title: 'Businesses', value: stats.totalBusinesses.toString(), icon: Icons.business, color: Colors.orange),
                  AdminStatCard(title: 'Transactions', value: stats.totalTransactions.toString(), icon: Icons.receipt_long, color: Colors.green),
                  AdminStatCard(title: 'Revenue', value: 'PKR ${stats.totalRevenue.toStringAsFixed(0)}', icon: Icons.payments, color: Colors.purple),
                ],
              ),
              const SizedBox(height: 24),
              const AdminRevenueChart(),
              const SizedBox(height: 24),
              _buildRecentActivity(isDarkMode),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
          Text('Recent Alerts', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
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
