import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/validators.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'widgets/forgot_password_header.dart';
import 'widgets/forgot_password_illustration.dart';
import 'phone_reset_verification_screen.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  late AnimationController _mainController;
  late Animation<double> _headerFade;
  late Animation<double> _illustrationScale;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );

    _illustrationScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack)),
    );

    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic)),
    );

    _mainController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _mainController.dispose();
    super.dispose();
  }

  void _handleReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final contact = _emailController.text.trim();
        final supabaseService = ref.read(supabaseServiceProvider);
        
        final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(contact);
        
        if (isEmail) {
          await supabaseService.resetPassword(contact);
          if (mounted) {
            setState(() => _isLoading = false);
            _showSuccessDialog();
          }
        } else {
          // Send OTP for Phone
          await supabaseService.resetPasswordViaPhone(contact);
          if (mounted) {
            setState(() => _isLoading = false);
            NavigationUtils.push(
              context, 
              PhoneResetVerificationScreen(phoneNumber: contact),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.success, size: 64),
            const SizedBox(height: 16),
            Text(
              'Success!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Password reset instructions have been sent to your email.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to Login
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
      backgroundColor: isDarkMode ? AppColors.deepNavy : AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              FadeTransition(
                opacity: _headerFade,
                child: const ForgotPasswordHeader(),
              ),

              // Main Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: SlideTransition(
                  position: _contentSlide,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Illustration
                        ScaleTransition(
                          scale: _illustrationScale,
                          child: const ForgotPasswordIllustration(size: 180),
                        ),
                        const SizedBox(height: 20),
                        // Title
                        Text(
                          'Forgot Password?',
                          style: GoogleFonts.poppins(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: isDarkMode ? Colors.white : AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'Enter your registered email or phone number to reset your password.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Input
                        CustomTextField(
                          hintText: 'Email or Phone Number',
                          prefixIcon: Icons.mail_outline,
                          controller: _emailController,
                          validator: (val) {
                            if (val == null || val.isEmpty) return 'Field required';
                            // Logic for either email or phone
                            final isEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val);
                            final isPhone = RegExp(r'^\+?[0-9]{10,12}$').hasMatch(val);
                            if (!isEmail && !isPhone) return 'Invalid email or phone number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),
                        // Button
                        _isLoading 
                          ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                          : PrimaryButton(
                              text: 'Send Reset Link',
                              onPressed: _handleReset,
                            ),
                        const SizedBox(height: 36),
                        // Bottom Text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Remember your password? ',
                              style: GoogleFonts.inter(color: isDarkMode ? Colors.white70 : AppColors.textSecondary),
                            ),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Text(
                                'Login',
                                style: GoogleFonts.inter(
                                  color: AppColors.primaryBlue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
