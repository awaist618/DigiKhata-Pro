import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/analytics/presentation/providers/analytics_provider.dart';

import 'package:easy_localization/easy_localization.dart';

class TransactionChart extends ConsumerWidget {
  const TransactionChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(analyticsDataProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (analytics == null) {
      return const SizedBox.shrink();
    }

    // Use revenue data for the chart spots
    final spots = List.generate(7, (index) => FlSpot(index.toDouble(), analytics.weeklyRevenue[index]));

    // Calculate max Y for better scaling
    double maxY = 0;
    for (var spot in spots) {
      if (spot.y > maxY) maxY = spot.y;
    }
    maxY = maxY == 0 ? 10 : maxY * 1.2;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.black.withValues(alpha: 0.05)),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'revenue_trend'.tr(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'last_7_days'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.skyBlue],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.2),
                          AppColors.primaryBlue.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _getLastSevenDaysLabels()
                .map((day) => Text(
                      day,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  List<String> _getLastSevenDaysLabels() {
    final now = DateTime.now();
    final List<String> labels = [];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      labels.add(days[date.weekday - 1]);
    }
    return labels;
  }
}
