import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/report_generator.dart';
import '../providers/admin_provider.dart';

import 'package:easy_localization/easy_localization.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  Future<void> _generateReport(BuildContext context, WidgetRef ref, String type) async {
    final repo = ref.read(adminRepositoryProvider);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('generating_report'.tr())));

      if (type == 'user_growth') {
        final data = await repo.getUserGrowthData();
        await ReportGenerator.generateExcelReport(
          fileName: 'User_Growth_Report',
          sheetName: 'Growth',
          columns: ['Month', 'New Users'],
          data: data.map((e) => [e['month'], e['count']]).toList(),
        );
      } else if (type == 'business_activity') {
        final data = await repo.getBusinesses();
        await ReportGenerator.generateExcelReport(
          fileName: 'Business_Activity_Report',
          sheetName: 'Businesses',
          columns: ['Name', 'Type', 'Created At'],
          data: data.map((e) => [e['name'], e['type'], e['created_at']]).toList(),
        );
      } else if (type == 'transaction_volume') {
        final data = await repo.getTransactionVolumeData();
        await ReportGenerator.generateExcelReport(
          fileName: 'Transaction_Volume_Report',
          sheetName: 'Transactions',
          columns: ['Amount', 'Type', 'Date'],
          data: data.map((e) => [e['amount'], e['type'], e['created_at']]).toList(),
        );
      } else if (type == 'compliance') {
        final data = await repo.getUsers();
        await ReportGenerator.generateExcelReport(
          fileName: 'Compliance_Audit_Report',
          sheetName: 'Users',
          columns: ['Email', 'Full Name', 'Joined Date', 'Status'],
          data: data.map((e) => [e.email, e.fullName, e.createdAt?.toIso8601String() ?? 'N/A', e.isBlocked ? 'Blocked' : 'Active']).toList(),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'reports'.tr(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: -0.5,
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
          ),
        ],
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildReportItem(
              Icons.group_rounded, 
              'user_growth_report'.tr(), 
              'user_growth_desc'.tr(), 
              Colors.blue, 
              isDarkMode,
              onTap: () => _generateReport(context, ref, 'user_growth'),
            ),
            _buildReportItem(
              Icons.storefront_rounded, 
              'business_activity'.tr(), 
              'business_activity_desc'.tr(), 
              Colors.orange, 
              isDarkMode,
              onTap: () => _generateReport(context, ref, 'business_activity'),
            ),
            _buildReportItem(
              Icons.receipt_long_rounded, 
              'transaction_volume'.tr(), 
              'transaction_volume_desc'.tr(), 
              Colors.green, 
              isDarkMode,
              onTap: () => _generateReport(context, ref, 'transaction_volume'),
            ),
            _buildReportItem(
              Icons.shield_rounded, 
              'compliance_audit'.tr(), 
              'compliance_audit_desc'.tr(), 
              Colors.red, 
              isDarkMode,
              onTap: () => _generateReport(context, ref, 'compliance'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportItem(IconData icon, String title, String subtitle, Color color, bool isDarkMode, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(32),
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.border.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDarkMode ? 0.08 : 0.04),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withValues(alpha: 0.2), color.withValues(alpha: 0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800, 
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle, 
                    style: GoogleFonts.inter(
                      fontSize: 12, 
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.adminPrimary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.download_rounded, color: AppColors.adminPrimary, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
