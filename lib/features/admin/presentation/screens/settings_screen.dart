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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'system_settings'.tr(),
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
            _buildSettingsSection(
              'communication'.tr(),
              [
                _buildSettingsItem(
                  Icons.campaign_rounded,
                  'system_announcements'.tr(),
                  'system_alerts_desc'.tr(),
                  isDarkMode,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementManagementScreen()),
                  ),
                ),
                _buildSettingsItem(
                  Icons.send_rounded,
                  'broadcaster'.tr(),
                  'broadcast_desc'.tr(),
                  isDarkMode,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PushNotificationScreen()),
                  ),
                ),
                _buildSettingsItem(
                  Icons.view_carousel_rounded,
                  'marketing_banners'.tr(),
                  'manage_sliders_desc'.tr(),
                  isDarkMode,
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
                _buildSettingsItem(Icons.info_rounded, 'app_version'.tr(), 'v1.0.0 Stable', isDarkMode),
                _buildSettingsItem(Icons.build_circle_rounded, 'maintenance_mode'.tr(), 'maintenance_desc'.tr(), isDarkMode, showSwitch: true),
              ],
              isDarkMode,
            ),
            const SizedBox(height: 24),
            _buildSettingsSection(
              'policy_mgmt'.tr(),
              [
                _buildSettingsItem(Icons.description_rounded, 'Terms & Conditions', 'last_updated'.tr(), isDarkMode),
                _buildSettingsItem(Icons.privacy_tip_rounded, 'Privacy Policy', 'last_updated'.tr(), isDarkMode),
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
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 0,
              ),
              child: Text('logout_admin'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title.toUpperCase(), 
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800, 
              color: AppColors.adminPrimary, 
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, String value, bool isDarkMode, {bool showSwitch = false, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.adminPrimary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.adminPrimary, size: 22),
        ),
        title: Text(
          title, 
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700, 
            fontSize: 14,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          value, 
          style: GoogleFonts.inter(
            fontSize: 11, 
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: showSwitch 
          ? Switch.adaptive(value: false, onChanged: (v) {}, activeColor: AppColors.adminPrimary) 
          : Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textSecondary.withValues(alpha: 0.5)),
      ),
    );
  }
}
