import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../../data/repositories/dashboard_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/providers/settings_provider.dart';

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
            'TOTAL RECEIVABLE',
            '${settings.currency} ${stats.totalReceivable.toStringAsFixed(0)}',
            Icons.arrow_downward_rounded,
            AppColors.success,
            'You Get',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            'TOTAL PAYABLE',
            '${settings.currency} ${stats.totalPayable.toStringAsFixed(0)}',
            Icons.arrow_upward_rounded,
            AppColors.danger,
            'You Give',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String amount, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: GoogleFonts.robotoMono(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
