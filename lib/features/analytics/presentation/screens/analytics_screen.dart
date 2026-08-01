import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:khataplus/features/customer/presentation/providers/customer_provider.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import '../providers/analytics_provider.dart';

import 'package:easy_localization/easy_localization.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final customersAsync = ref.watch(customersProvider);
    final analytics = ref.watch(analyticsDataProvider);
    final settings = ref.watch(settingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'analytics'.tr(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppColors.textPrimary),
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (analytics != null) _buildCashFlowChart(analytics, isDarkMode),
              const SizedBox(height: 24),
              if (analytics != null) _buildStatGrid(analytics, settings, isDarkMode),
              const SizedBox(height: 24),
              _buildTopCustomers(customersAsync, settings, isDarkMode),
              const SizedBox(height: 24),
              _buildOutstandingDues(customersAsync, settings, isDarkMode),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCashFlowChart(AnalyticsData data, bool isDarkMode) {
    double maxVal = 0;
    for(var v in data.weeklyRevenue) if(v > maxVal) maxVal = v;
    for(var v in data.weeklyExpense) if(v > maxVal) maxVal = v;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'revenue_vs_expense'.tr(),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, 
              fontSize: 16,
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxVal + 1000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (i) => BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(toY: data.weeklyRevenue[i], color: AppColors.primaryBlue, width: 12),
                    BarChartRodData(toY: data.weeklyExpense[i], color: AppColors.danger, width: 12),
                  ],
                )),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('revenue'.tr(), AppColors.primaryBlue),
              const SizedBox(width: 24),
              _buildLegendItem('expense'.tr(), AppColors.danger),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStatGrid(AnalyticsData data, AppSettings settings, bool isDarkMode) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildSmallStatCard('net_profit'.tr(), '${settings.currency} ${data.netProfit.toStringAsFixed(0)}', Icons.trending_up, Colors.green, isDarkMode),
        _buildSmallStatCard('total_volume'.tr(), '${settings.currency} ${data.cashFlow.toStringAsFixed(0)}', Icons.sync_alt, Colors.blue, isDarkMode),
      ],
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(AsyncValue<List<dynamic>> customersAsync, AppSettings settings, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'top_customers'.tr(), 
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        customersAsync.when(
          data: (customers) => Column(
            children: customers.take(3).map((c) => _buildMiniListTile(c.name, '${settings.currency} ${c.balance.toStringAsFixed(0)}', Icons.person, isDarkMode)).toList(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Container(),
        ),
      ],
    );
  }

  Widget _buildOutstandingDues(AsyncValue<List<dynamic>> customersAsync, AppSettings settings, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'outstanding_dues'.tr(), 
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold, 
            fontSize: 18,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        customersAsync.when(
          data: (customers) => Column(
            children: customers
                .where((c) => c.balance < 0)
                .take(3)
                .map((c) => _buildMiniListTile(c.name, '${settings.currency} ${c.balance.abs().toStringAsFixed(0)}', Icons.warning, isDarkMode, color: Colors.red))
                .toList(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Container(),
        ),
      ],
    );
  }

  Widget _buildMiniListTile(String title, String value, IconData icon, bool isDarkMode, {Color color = AppColors.primaryBlue}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.logoNavyBottom : Colors.white, 
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title, 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
          Text(value, style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
