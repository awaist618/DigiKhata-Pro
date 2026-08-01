import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class PushNotificationScreen extends ConsumerStatefulWidget {
  const PushNotificationScreen({super.key});

  @override
  ConsumerState<PushNotificationScreen> createState() => _PushNotificationScreenState();
}

class _PushNotificationScreenState extends ConsumerState<PushNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  int _targetIndex = 0; // 0: All, 1: Active
  bool _isBroadcasting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _handleBroadcast() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isBroadcasting = true);
    try {
      final target = _targetIndex == 0 ? 'all' : 'active_businesses';
      await ref.read(adminRepositoryProvider).broadcastNotification(title, body, target);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast sent successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isBroadcasting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('broadcaster'.tr(), style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('compose_notification'.tr(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInputField('title_hint'.tr(), 'title_hint'.tr(), Icons.title, _titleController, isDarkMode),
            const SizedBox(height: 16),
            _buildInputField('body_hint'.tr(), 'body_hint'.tr(), Icons.message, _bodyController, isDarkMode, maxLines: 4),
            const SizedBox(height: 32),
            Text('target_audience'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: isDarkMode ? AppColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  RadioListTile(
                    value: 0, 
                    groupValue: _targetIndex, 
                    onChanged: (v) => setState(() => _targetIndex = v as int), 
                    title: Text('all_users'.tr(), style: const TextStyle(fontSize: 14)),
                    activeColor: AppColors.primaryBlue,
                  ),
                  RadioListTile(
                    value: 1, 
                    groupValue: _targetIndex, 
                    onChanged: (v) => setState(() => _targetIndex = v as int), 
                    title: Text('active_businesses'.tr(), style: const TextStyle(fontSize: 14)),
                    activeColor: AppColors.primaryBlue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _isBroadcasting 
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton.icon(
                  onPressed: _handleBroadcast,
                  icon: const Icon(Icons.send),
                  label: Text('broadcast_now'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, bool isDarkMode, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
            filled: true,
            fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.inputBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
