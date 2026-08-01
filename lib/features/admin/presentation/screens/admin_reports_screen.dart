import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('System Reports', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildReportItem(Icons.group_outlined, 'User Growth Report', 'Analysis of new registrations', Colors.blue, isDarkMode),
          _buildReportItem(Icons.storefront_outlined, 'Business Activity', 'Active vs Inactive businesses', Colors.orange, isDarkMode),
          _buildReportItem(Icons.receipt_long_outlined, 'Transaction Volume', 'Total cash flow across system', Colors.green, isDarkMode),
          _buildReportItem(Icons.warning_amber_rounded, 'Compliance Audit', 'Flagged activities and blocked users', Colors.red, isDarkMode),
        ],
      ),
    );
  }

  Widget _buildReportItem(IconData icon, String title, String subtitle, Color color, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.download_outlined, color: AppColors.primaryBlue),
        ],
      ),
    );
  }
}
