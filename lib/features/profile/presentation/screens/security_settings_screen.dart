import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/providers/security_provider.dart';
import 'trusted_devices_screen.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final security = ref.watch(securityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Security', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildToggleCard(
            'PIN Lock',
            'Protect app with a 4-digit PIN',
            Icons.pin_outlined,
            security.isPinEnabled,
            (val) => _handlePinToggle(context, ref, val),
          ),
          _buildToggleCard(
            'Biometric Login',
            'Use Fingerprint or Face ID',
            Icons.fingerprint,
            security.isBiometricEnabled,
            (val) => ref.read(securityProvider.notifier).toggleBiometric(val),
          ),
          _buildToggleCard(
            'Auto Logout',
            'Logout when app is closed',
            Icons.timer_outlined,
            security.isAutoLogoutEnabled,
            (val) => ref.read(securityProvider.notifier).toggleAutoLogout(val),
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            'Device Verification',
            'Manage trusted devices',
            Icons.devices_outlined,
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrustedDevicesScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleCard(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value,
        activeColor: AppColors.primaryBlue,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primaryBlue),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _handlePinToggle(BuildContext context, WidgetRef ref, bool val) {
    if (val) {
      _showPinSetupDialog(context, ref);
    } else {
      ref.read(securityProvider.notifier).disablePin();
    }
  }

  void _showPinSetupDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set App PIN'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(hintText: 'Enter 4-digit PIN'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.length == 4) {
                ref.read(securityProvider.notifier).setPin(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
