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
  bool _isLoading = false;

  void _handleUpdate() async {
    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      await supabase.auth.updateUser(
        UserAttributes(password: _passwordController.text),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        _showSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Password Updated'),
        content: const Text('Your password has been changed successfully. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              NavigationUtils.pushReplacement(context, const LoginScreen());
            },
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Password')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CustomTextField(
              hintText: 'New Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
              controller: _passwordController,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              hintText: 'Confirm Password',
              prefixIcon: Icons.lock_reset,
              isPassword: true,
              controller: _confirmController,
            ),
            const SizedBox(height: 32),
            _isLoading 
              ? const CircularProgressIndicator()
              : PrimaryButton(text: 'Update Password', onPressed: _handleUpdate),
          ],
        ),
      ),
    );
  }
}
