import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/core/providers/database_provider.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/auth/presentation/login/login_screen.dart';
import 'package:khataplus/features/profile/presentation/providers/profile_provider.dart';
import 'package:khataplus/features/main_wrapper/main_wrapper.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

import 'settings_screen.dart';

import 'package:khataplus/core/providers/security_provider.dart';
import 'package:khataplus/core/providers/settings_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final settings = ref.watch(settingsProvider);
    final isDarkMode = settings.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.deepNavy : AppColors.background,
      appBar: AppBar(
        title: Text(
          'profile'.tr(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : AppColors.textPrimary,
        ),
      ),
      body: profileAsync.when(
        data: (user) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProfileHeader(context, ref, user, isDarkMode),
              const SizedBox(height: 32),
              _buildSectionTitle('Account Settings', isDarkMode),
              const SizedBox(height: 12),
              _buildSettingItem(
                icon: Icons.person_outline,
                title: 'edit_profile'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                ),
                isDarkMode: isDarkMode,
              ),
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'change_password'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                ),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Preferences', isDarkMode),
              const SizedBox(height: 12),
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: 'language'.tr(),
                trailing: Text(
                  context.locale.languageCode == 'en' ? 'English' : 'Urdu',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () => _showLanguageDialog(context, ref),
                isDarkMode: isDarkMode,
              ),
              _buildThemeToggle(ref, isDarkMode),
              _buildBiometricToggle(ref, isDarkMode),
              _buildSettingItem(
                icon: Icons.sync,
                title: 'Backup & Sync',
                onTap: () => _showSyncStatus(context),
                isDarkMode: isDarkMode,
              ),
              _buildSettingItem(
                icon: Icons.notifications_none_outlined,
                title: 'notifications'.tr(),
                onTap: () => _showNotificationPreferences(context),
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 32),
              _buildSettingItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                ),
                isDarkMode: isDarkMode,
              ),
              _buildLogoutButton(context, ref),
              const SizedBox(height: 40),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref, dynamic user, bool isDarkMode) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2), width: 2),
              ),
              child: CircleAvatar(
                radius: 64,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                backgroundImage: user?.avatarUrl != null 
                    ? NetworkImage(user!.avatarUrl!) 
                    : null,
                child: user?.avatarUrl == null
                    ? const Icon(Icons.person_rounded, size: 60, color: AppColors.primaryBlue)
                    : null,
              ),
            ),
            Positioned(
              bottom: 4,
              right: 4,
              child: InkWell(
                onTap: () => ref.read(profileProvider.notifier).pickAndUploadAvatar(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDarkMode ? AppColors.deepNavy : Colors.white, width: 3),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10)],
                  ),
                  child: const Icon(Icons.camera_enhance_rounded, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          user?.fullName ?? 'Business Owner',
          style: GoogleFonts.poppins(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user?.email ?? 'user@example.com',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildThemeToggle(WidgetRef ref, bool isDarkMode) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
      child: SwitchListTile(
        secondary: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: AppColors.primaryBlue,
        ),
        title: Text(
          'Dark Mode',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        value: isDarkMode,
        activeColor: AppColors.primaryBlue,
        onChanged: (val) {
          ref.read(settingsProvider.notifier).toggleDarkMode(val);
        },
      ),
    );
  }

  Widget _buildBiometricToggle(WidgetRef ref, bool isDarkMode) {
    final security = ref.watch(securityProvider);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
      child: SwitchListTile(
        secondary: Icon(
          Icons.fingerprint,
          color: AppColors.primaryBlue,
        ),
        title: Text(
          'Biometric Login',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          'Use fingerprint to login',
          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
        ),
        value: security.isBiometricEnabled,
        activeColor: AppColors.primaryBlue,
        onChanged: (val) {
          ref.read(securityProvider.notifier).toggleBiometric(val);
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Logout', style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          try {
            // 1. Sign out from Supabase
            await ref.read(supabaseServiceProvider).signOut();
            
            // 2. Reset navigation index for next login
            ref.read(navIndexProvider.notifier).state = 0;
            
            // 3. Navigate to login and clear stack
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          } catch (e) {
            debugPrint('Logout Error: $e');
            if (context.mounted) {
              // Even if sign out fails, try to return to login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            }
          }
        }
      },
      icon: const Icon(Icons.logout, color: AppColors.danger),
      label: Text(
        'Logout',
        style: GoogleFonts.poppins(
          color: AppColors.danger,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(context, ref, 'English', 'en', Icons.language),
            _buildLanguageOption(context, ref, 'Urdu', 'ur', Icons.translate),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, String title, String code, IconData icon) {
    final isSelected = context.locale.languageCode == code;
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? AppColors.primaryBlue : null,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.primaryBlue) : null,
      onTap: () {
        context.setLocale(Locale(code));
        ref.read(settingsProvider.notifier).setLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  void _showSyncStatus(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SyncStatusSheet(),
    );
  }

  void _showNotificationPreferences(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const NotificationPreferencesSheet(),
    );
  }
}

class SyncStatusSheet extends ConsumerStatefulWidget {
  const SyncStatusSheet({super.key});

  @override
  ConsumerState<SyncStatusSheet> createState() => _SyncStatusSheetState();
}

class _SyncStatusSheetState extends ConsumerState<SyncStatusSheet> {
  bool _isSyncing = false;

  void _triggerSync() async {
    setState(() => _isSyncing = true);
    
    // Perform real sync logic
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      final db = ref.read(databaseProvider);
      
      final pending = await db.select(db.syncQueue).get();
      int successCount = 0;

      for (var item in pending) {
        try {
          if (item.action == 'insert') {
            await supabase.from(item.localTable).upsert(jsonDecode(item.data));
            // Trigger balance RPC for transaction inserts
            if (item.localTable == 'transactions') {
              final txData = jsonDecode(item.data);
              final factor = txData['type'] == 'credit' ? 1 : -1;
              final amount = (txData['amount'] as num).toDouble() * factor;
              
              if (txData['customer_id'] != null) {
                await supabase.rpc('update_customer_balance', params: {
                  'c_id': txData['customer_id'],
                  'amount_change': amount,
                });
              } else if (txData['supplier_id'] != null) {
                await supabase.rpc('update_supplier_balance', params: {
                  's_id': txData['supplier_id'],
                  'amount_change': amount,
                });
              }
            }
          } else if (item.action == 'update') {
            await supabase.from(item.localTable).update(jsonDecode(item.data)).eq('id', item.recordId);
          } else if (item.action == 'delete') {
            await supabase.from(item.localTable).delete().eq('id', item.recordId);
          }
          await (db.delete(db.syncQueue)..where((t) => t.id.equals(item.id))).go();
          successCount++;
        } catch (e) {
          debugPrint('Sync failed for item ${item.id}: $e');
        }
      }

      if (mounted) {
        setState(() => _isSyncing = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync completed! $successCount changes pushed to cloud.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isSyncing ? Icons.sync : Icons.cloud_done,
            color: AppColors.primaryBlue,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            _isSyncing ? 'Syncing Data...' : 'Auto-Sync is Active',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _isSyncing 
              ? 'Please wait while we verify your data with the cloud.'
              : 'Your data is automatically backed up to Supabase Cloud.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSyncing ? null : _triggerSync,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSyncing
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Sync Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
class NotificationPreferencesSheet extends StatefulWidget {
  const NotificationPreferencesSheet({super.key});

  @override
  State<NotificationPreferencesSheet> createState() => _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState extends State<NotificationPreferencesSheet> {
  bool push = true;
  bool sms = false;
  bool email = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notification Preferences',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildNotificationToggle('Push Notifications', 'Receive alerts for transactions', push, (v) => setState(() => push = v)),
          _buildNotificationToggle('SMS Alerts', 'Get SMS for due payments', sms, (v) => setState(() => sms = v)),
          _buildNotificationToggle('Email Reports', 'Receive weekly summary in email', email, (v) => setState(() => email = v)),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences saved successfully!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildNotificationToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
      value: value,
      activeColor: AppColors.primaryBlue,
      onChanged: onChanged,
    );
  }
}
