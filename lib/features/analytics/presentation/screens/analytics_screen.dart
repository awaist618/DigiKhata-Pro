import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:khataplus/features/customer/presentation/providers/customer_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Analytics',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCashFlowChart(stats),
              const SizedBox(height: 24),
              _buildStatGrid(stats),
              const SizedBox(height: 24),
              _buildTopCustomers(customersAsync),
              const SizedBox(height: 24),
              _buildOutstandingDues(customersAsync),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildCashFlowChart(dynamic stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Revenue vs Expense',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 20,
                barTouchData: BarTouchData(enabled: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [
                    BarChartRodData(toY: 8, color: AppColors.primaryBlue, width: 16),
                    BarChartRodData(toY: 5, color: AppColors.danger, width: 16),
                  ]),
                  BarChartGroupData(x: 1, barRods: [
                    BarChartRodData(toY: 12, color: AppColors.primaryBlue, width: 16),
                    BarChartRodData(toY: 8, color: AppColors.danger, width: 16),
                  ]),
                  BarChartGroupData(x: 2, barRods: [
                    BarChartRodData(toY: 15, color: AppColors.primaryBlue, width: 16),
                    BarChartRodData(toY: 10, color: AppColors.danger, width: 16),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Revenue', AppColors.primaryBlue),
              const SizedBox(width: 24),
              _buildLegendItem('Expense', AppColors.danger),
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

  Widget _buildStatGrid(dynamic stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildSmallStatCard('Net Profit', '₹ 15,200', Icons.trending_up, Colors.green),
        _buildSmallStatCard('Cash Flow', '₹ 45,000', Icons.sync_alt, Colors.blue),
      ],
    );
  }

  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTopCustomers(AsyncValue<List<dynamic>> customersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Customers', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        customersAsync.when(
          data: (customers) => Column(
            children: customers.take(3).map((c) => _buildMiniListTile(c.name, '₹ ${c.balance.toStringAsFixed(0)}', Icons.person)).toList(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Container(),
        ),
      ],
    );
  }

  Widget _buildOutstandingDues(AsyncValue<List<dynamic>> customersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Outstanding Dues', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        customersAsync.when(
          data: (customers) => Column(
            children: customers
                .where((c) => c.balance < 0)
                .take(3)
                .map((c) => _buildMiniListTile(c.name, '₹ ${c.balance.abs().toStringAsFixed(0)}', Icons.warning, color: Colors.red))
                .toList(),
          ),
          loading: () => const CircularProgressIndicator(),
          error: (e, s) => Container(),
        ),
      ],
    );
  }

  Widget _buildMiniListTile(String title, String value, IconData icon, {Color color = AppColors.primaryBlue}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          Text(value, style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
