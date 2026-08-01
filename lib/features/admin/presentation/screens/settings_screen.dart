import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/auth/presentation/login/login_screen.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';

import 'announcement_management_screen.dart';
import 'push_notification_screen.dart';
import 'banner_management_screen.dart';

import 'package:easy_localization/easy_localization.dart';

class AdminSettingsScreen extends ConsumerWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('system_settings'.tr(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSettingsSection(
            'communication'.tr(),
            [
              _buildSettingsItem(
                Icons.campaign_outlined,
                'system_announcements'.tr(),
                'system_alerts_desc'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnnouncementManagementScreen()),
                ),
              ),
              _buildSettingsItem(
                Icons.send_outlined,
                'broadcaster'.tr(),
                'broadcast_desc'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PushNotificationScreen()),
                ),
              ),
              _buildSettingsItem(
                Icons.view_carousel_outlined,
                'marketing_banners'.tr(),
                'manage_sliders_desc'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BannerManagementScreen()),
                ),
              ),
            ],
            isDarkMode,
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'app_config'.tr(),
            [
              _buildSettingsItem(Icons.info_outline, 'app_version'.tr(), 'v1.0.0 Stable'),
              _buildSettingsItem(Icons.build_circle_outlined, 'maintenance_mode'.tr(), 'maintenance_desc'.tr(), showSwitch: true),
            ],
            isDarkMode,
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'policy_mgmt'.tr(),
            [
              _buildSettingsItem(Icons.description_outlined, 'Terms & Conditions', 'last_updated'.tr()),
              _buildSettingsItem(Icons.privacy_tip_outlined, 'Privacy Policy', 'last_updated'.tr()),
            ],
            isDarkMode,
          ),
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
            child: Text('logout_admin'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(value, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        trailing: showSwitch ? Switch.adaptive(value: false, onChanged: (v) {}) : const Icon(Icons.chevron_right, size: 18),
      ),
    );
  }
}
