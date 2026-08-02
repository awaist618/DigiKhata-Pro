import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'security_settings_screen.dart';
import 'backup_management_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle('General'),
          _buildSettingTile(
            context,
            'Currency',
            settings.currency,
            Icons.payments_outlined,
            () => _showCurrencyPicker(context, ref),
          ),
          _buildSettingTile(
            context,
            'Date Format',
            settings.dateFormat,
            Icons.calendar_today_outlined,
            () => _showDateFormatPicker(context, ref),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Security'),
          _buildSettingTile(
            context,
            'App Security',
            'PIN, Biometrics',
            Icons.security_outlined,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecuritySettingsScreen())),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Data & Backup'),
          _buildSettingTile(
            context,
            'Manage Backups',
            'Local JSON backups',
            Icons.backup_outlined,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BackupManagementScreen())),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('About'),
          _buildSettingTile(
            context,
            'Privacy Policy',
            null,
            Icons.privacy_tip_outlined,
            () => _showPrivacyPolicy(context),
          ),
          _buildSettingTile(
            context,
            'About App',
            'v1.0.0',
            Icons.info_outline,
            () => _showAboutApp(context),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.privacy_tip_outlined, color: AppColors.primaryBlue),
            const SizedBox(width: 12),
            Text('Privacy Policy', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Data Security',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Your business data is stored securely using industry-standard encryption. We use Supabase and Row-Level Security (RLS) to ensure that only you can access your data.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Text(
                'Third-Party Sharing',
                style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'We do not sell or share your personal or business information with third-party advertisers or data brokers.',
                style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
          ),
        ],
      ),
    );
  }

  void _showAboutApp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'DigiKhata Pro',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppColors.primaryBlue, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
        ),
        applicationLegalese: '© 2026 Zenvyro Labs. All rights reserved.',
        children: [
          const SizedBox(height: 16),
          Text(
            'The ultimate bookkeeping solution for small and medium businesses. Manage your customers, suppliers, and daily ledger with ease and security.',
            style: GoogleFonts.inter(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, String? value, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null)
              Text(value, style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: ['PKR', 'INR', 'USD', 'AED'].map((c) => ListTile(
          title: Text(c),
          onTap: () {
            ref.read(settingsProvider.notifier).setCurrency(c);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }

  void _showDateFormatPicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: ['dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'].map((f) => ListTile(
          title: Text(f),
          onTap: () {
            ref.read(settingsProvider.notifier).setDateFormat(f);
            Navigator.pop(context);
          },
        )).toList(),
      ),
    );
  }
}
