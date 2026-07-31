import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/auth/presentation/register/widgets/otp_input_field.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'update_password_screen.dart';

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
        // Once verified, the user is technically logged in via Supabase OTP path
        // Navigate to update password screen
        NavigationUtils.pushReplacement(context, const UpdatePasswordScreen());
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification Failed: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Phone')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Verification Code',
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'A code has been sent to ${widget.phoneNumber}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 40),
            OTPInputField(
              length: 6,
              onCompleted: _handleVerify,
            ),
            const SizedBox(height: 40),
            if (_isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
