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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'broadcaster'.tr(),
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'compose_notification'.tr(), 
                style: GoogleFonts.poppins(
                  fontSize: 18, 
                  fontWeight: FontWeight.w800,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              _buildInputField('title_hint'.tr(), 'title_hint'.tr(), Icons.title_rounded, _titleController, isDarkMode),
              const SizedBox(height: 16),
              _buildInputField('body_hint'.tr(), 'body_hint'.tr(), Icons.message_rounded, _bodyController, isDarkMode, maxLines: 4),
              const SizedBox(height: 32),
              Text(
                'target_audience'.tr().toUpperCase(), 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w800, 
                  fontSize: 12, 
                  color: AppColors.adminPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
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
                child: Column(
                  children: [
                    RadioListTile(
                      value: 0, 
                      groupValue: _targetIndex, 
                      onChanged: (v) => setState(() => _targetIndex = v as int), 
                      title: Text(
                        'all_users'.tr(), 
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: isDarkMode ? Colors.white : AppColors.textPrimary),
                      ),
                      activeColor: AppColors.adminPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    RadioListTile(
                      value: 1, 
                      groupValue: _targetIndex, 
                      onChanged: (v) => setState(() => _targetIndex = v as int), 
                      title: Text(
                        'active_businesses'.tr(), 
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: isDarkMode ? Colors.white : AppColors.textPrimary),
                      ),
                      activeColor: AppColors.adminPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              _isBroadcasting 
                ? const Center(child: CircularProgressIndicator(color: AppColors.adminPrimary))
                : ElevatedButton.icon(
                    onPressed: _handleBroadcast,
                    icon: const Icon(Icons.send_rounded),
                    label: Text('broadcast_now'.tr(), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adminPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 0,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData icon, TextEditingController controller, bool isDarkMode, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(), 
            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.0),
          ),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            prefixIcon: Icon(icon, color: AppColors.adminPrimary, size: 20),
            filled: true,
            fillColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }
}
