import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/auth/presentation/login/login_screen.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';

import 'announcement_management_screen.dart';
import 'push_notification_screen.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('System Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsSection('Communication', [
            _buildSettingsItem(Icons.campaign_outlined, 'Announcements', 'Manage system alerts', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AnnouncementManagementScreen()))),
            _buildSettingsItem(Icons.send_outlined, 'Broadcaster', 'Send push notifications', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PushNotificationScreen()))),
            _buildSettingsItem(Icons.view_carousel_outlined, 'Marketing Banners', 'Manage app sliders', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BannerManagementScreen()))),
          ], isDarkMode),
          const SizedBox(height: 24),
          _buildSettingsSection('App Configuration', [
            _buildSettingsItem(Icons.info_outline, 'App Version', 'v1.0.0 Stable'),
            _buildSettingsItem(Icons.build_circle_outlined, 'Maintenance Mode', 'Disabled', showSwitch: true),
          ], isDarkMode),
          const SizedBox(height: 24),
          _buildSettingsSection('Policy Management', [
            _buildSettingsItem(Icons.description_outlined, 'Terms & Conditions', 'Last updated: 01 Aug 2026'),
            _buildSettingsItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'Last updated: 01 Aug 2026'),
          ], isDarkMode),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () async {
              await ref.read(supabaseServiceProvider).signOut();
              if (context.mounted) {
                NavigationUtils.pushReplacement(context, const LoginScreen());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Logout Admin Session', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String value, {bool showSwitch = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      trailing: showSwitch ? Switch.adaptive(value: false, onChanged: (v) {}) : const Icon(Icons.chevron_right, size: 18),
    );
  }
}
