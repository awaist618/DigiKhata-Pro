import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/auth/presentation/login/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdatePasswordScreen extends ConsumerStatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  ConsumerState<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends ConsumerState<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _handleUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final supabase = ref.read(supabaseServiceProvider).client;
        await supabase.auth.updateUser(
          UserAttributes(password: _passwordController.text.trim()),
        );

        if (mounted) {
          setState(() => _isLoading = false);
          _showSuccess();
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Update Failed: ${e.toString()}'), 
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text('Success!', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Your password has been changed successfully. Please login again with your new password.',
          textAlign: TextAlign.center,
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                NavigationUtils.pushReplacement(context, const LoginScreen());
              },
              child: Text(
                'Back to Login',
                style: GoogleFonts.inter(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('New Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              Icon(Icons.lock_reset_rounded, size: 100, color: AppColors.primaryBlue),
              const SizedBox(height: 32),
              Text(
                'Reset Your Password',
                style: GoogleFonts.poppins(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 40),
              CustomTextField(
                hintText: 'New Password',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                controller: _passwordController,
                validator: (val) => (val == null || val.length < 6) ? 'Minimum 6 characters' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Confirm Password',
                prefixIcon: Icons.lock_reset,
                isPassword: true,
                controller: _confirmController,
                validator: (val) {
                  if (val != _passwordController.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 48),
              _isLoading 
                ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                : PrimaryButton(text: 'Update Password', onPressed: _handleUpdate),
            ],
          ),
        ),
      ),
    );
  }
}
