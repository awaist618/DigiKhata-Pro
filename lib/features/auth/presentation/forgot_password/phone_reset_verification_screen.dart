import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/auth/presentation/register/widgets/otp_input_field.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/auth/presentation/reset_password/reset_password_screen.dart';

class PhoneResetVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  const PhoneResetVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<PhoneResetVerificationScreen> createState() => _PhoneResetVerificationScreenState();
}

class _PhoneResetVerificationScreenState extends ConsumerState<PhoneResetVerificationScreen> {
  bool _isLoading = false;

  void _handleVerify(String otp) async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      await supabase.verifyPhoneOTP(
        phone: widget.phoneNumber,
        token: otp,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        NavigationUtils.pushReplacement(context, const ResetPasswordScreen());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification Failed: ${e.toString()}'), 
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Verify Phone', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Icon(Icons.vibration_rounded, size: 100, color: AppColors.primaryBlue),
            const SizedBox(height: 32),
            Text(
              'Verification Code',
              style: GoogleFonts.poppins(
                fontSize: 28, 
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'A 6-digit code has been sent to ${widget.phoneNumber}. Enter it below to proceed.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 48),
            OTPInputField(
              length: 6,
              onCompleted: _handleVerify,
            ),
            const SizedBox(height: 48),
            if (_isLoading) 
              const CircularProgressIndicator(color: AppColors.primaryBlue)
            else
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Change Phone Number',
                  style: GoogleFonts.inter(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
