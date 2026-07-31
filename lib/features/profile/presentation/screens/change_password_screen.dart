import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/profile/presentation/providers/profile_provider.dart';

import 'package:khataplus/core/providers/settings_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await ref.read(profileRepositoryProvider).changePassword(_newPasswordController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password changed successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(settingsProvider).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.deepNavy : AppColors.background,
      appBar: AppBar(
        title: Text(
          'change_password'.tr(),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                hintText: 'new_password'.tr(),
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _newPasswordController,
                validator: (val) {
                  if (val == null || val.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'confirm_password'.tr(),
                prefixIcon: Icons.lock_reset_outlined,
                isPassword: true,
                controller: _confirmPasswordController,
                validator: (val) {
                  if (val != _newPasswordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                  : PrimaryButton(
                      text: 'change_password'.tr(),
                      onPressed: _handleChangePassword,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
