import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../providers/admin_provider.dart';

class PolicyEditScreen extends ConsumerStatefulWidget {
  final String title;
  final String settingKey;
  final String initialValue;

  const PolicyEditScreen({
    super.key,
    required this.title,
    required this.settingKey,
    required this.initialValue,
  });

  @override
  ConsumerState<PolicyEditScreen> createState() => _PolicyEditScreenState();
}

class _PolicyEditScreenState extends ConsumerState<PolicyEditScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() async {
    await ref.read(adminActionsProvider.notifier).updateSystemSetting(
      widget.settingKey,
      _controller.text,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Policy updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isLoading = ref.watch(adminActionsProvider).isLoading;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(widget.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.adminPrimary)),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  style: GoogleFonts.inter(color: isDarkMode ? Colors.white : AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter policy content here...',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
