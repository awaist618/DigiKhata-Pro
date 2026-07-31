import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'detailed_report_screen.dart';
import 'package:khataplus/features/analytics/presentation/screens/analytics_screen.dart';
import 'package:khataplus/core/services/export_service.dart';
import 'package:khataplus/core/providers/settings_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Business Reports',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildReportCard(
              context,
              'Business Analytics',
              'Revenue, Profit and Cash Flow charts',
              Icons.analytics,
              AppColors.primaryBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              'Daily Summary',
              'Detailed view of today\'s activities',
              Icons.today,
              AppColors.headerMiddleBlue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailedReportScreen(reportType: 'Daily Report'))),
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              'Income & Expense',
              'Analysis of Cash In vs Cash Out',
              Icons.account_balance_wallet,
              AppColors.success,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailedReportScreen(reportType: 'Income & Expense Report'))),
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              'Customer Balances',
              'Summary of all outstanding dues',
              Icons.people,
              AppColors.amberGold,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DetailedReportScreen(reportType: 'Customer Report'))),
            ),
            const SizedBox(height: 16),
            _buildReportCard(
              context,
              'PDF Statements',
              'Generate monthly/yearly statements',
              Icons.picture_as_pdf,
              AppColors.danger,
              onDownload: () => _showExportDialog(context, ref, 'Full History'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
    VoidCallback? onDownload,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onDownload != null)
              _buildDownloadButton(onDownload)
            else
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadButton(VoidCallback onDownload) {
    return InkWell(
      onTap: onDownload,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue, size: 20),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref, String reportName) {
    final stats = ref.read(dashboardStatsProvider).value;
    final businessName = ref.read(businessNameProvider);
    final currency = ref.read(settingsProvider).currency;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Export $reportName',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExportOption(context, 'PDF', Icons.picture_as_pdf, Colors.red, () async {
                  if (stats != null) {
                    Navigator.pop(context);
                    await ExportService.exportLedgerToPdf(
                      title: reportName,
                      transactions: stats.recentTransactions,
                      businessName: businessName,
                      currency: currency,
                    );
                  }
                }),
                _buildExportOption(context, 'Excel', Icons.table_chart, Colors.green, () async {
                  if (stats != null) {
                    Navigator.pop(context);
                    await ExportService.exportLedgerToExcel(
                      transactions: stats.recentTransactions,
                      fileName: reportName.replaceAll(' ', '_').toLowerCase(),
                    );
                  }
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
