import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../../data/repositories/dashboard_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/providers/settings_provider.dart';

import 'package:easy_localization/easy_localization.dart';

class SummaryCards extends ConsumerWidget {
  final DashboardStats stats;
  const SummaryCards({super.key, required this.stats});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            context,
            'total_receivable'.tr(),
            '${settings.currency} ${stats.totalReceivable.toStringAsFixed(0)}',
            Icons.arrow_downward_rounded,
            AppColors.success,
            'you_get'.tr(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            context,
            'total_payable'.tr(),
            '${settings.currency} ${stats.totalPayable.toStringAsFixed(0)}',
            Icons.arrow_upward_rounded,
            AppColors.danger,
            'you_give'.tr(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount, IconData icon, Color color, String subtitle) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Expanded(
                child: Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              style: GoogleFonts.robotoMono(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
