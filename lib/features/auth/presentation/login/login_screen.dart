import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/theme/app_text_styles.dart';
import 'package:khataplus/core/widgets/app_logo.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/curved_header.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/fingerprint_button.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/divider_or.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/auth/presentation/register/register_screen.dart';
import 'package:khataplus/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:khataplus/features/business/presentation/selection/business_selection_screen.dart';
import 'package:khataplus/core/providers/security_provider.dart';
import '../register/widgets/google_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  late AnimationController _fadeController;
  late Animation<double> _headerFade;
  late Animation<Offset> _welcomeSlide;
  late Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _headerFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0, 0.4, curve: Curves.easeOut)),
    );

    _welcomeSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
    );

    _contentFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.signIn(email: email, password: password);
      
      if (mounted) {
        // Successful manual login: Handle Biometric Enrollment
        final security = ref.read(securityProvider);
        if (security.isBiometricEnabled) {
          // Update stored credentials if they changed
          await ref.read(securityProvider.notifier).saveCredentials(email, password);
        } else {
          _promptBiometricEnrollment(email, password);
        }

        NavigationUtils.pushReplacement(context, const BusinessSelectionScreen());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final supabaseService = ref.read(supabaseServiceProvider);
      await supabaseService.signInWithGoogle();
      if (mounted) {
        NavigationUtils.pushReplacement(context, const BusinessSelectionScreen());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleBiometricLogin() async {
    final securityNotifier = ref.read(securityProvider.notifier);
    final credentials = await securityNotifier.getStoredCredentials();

    if (credentials == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login with password once to enable Fingerprint')),
      );
      return;
    }

    final authenticated = await securityNotifier.authenticate();
    if (authenticated) {
      setState(() => _isLoading = true);
      try {
        final supabaseService = ref.read(supabaseServiceProvider);
        await supabaseService.signIn(
          email: credentials['email']!,
          password: credentials['password']!,
        );
        if (mounted) {
          NavigationUtils.pushReplacement(context, const BusinessSelectionScreen());
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Biometric Login Failed: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _promptBiometricEnrollment(String email, String password) async {
    // Small delay to let business selection screen show or just show dialog before navigation
    // Better to show it after navigation or in settings, but for UX we can show it here
    Future.delayed(const Duration(milliseconds: 500), () async {
      if (!mounted) return;
      
      final enroll = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Enable Fingerprint?'),
          content: const Text('Would you like to use your fingerprint for future logins?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No Thanks')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Enable', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );

      if (enroll == true) {
        final success = await ref.read(securityProvider.notifier).toggleBiometric(true);
        if (success) {
          await ref.read(securityProvider.notifier).saveCredentials(email, password);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.deepNavy : AppColors.background,
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header Section
                FadeTransition(
                  opacity: _headerFade,
                  child: CurvedHeader(
                    child: SafeArea(
                      bottom: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            const AppLogo(size: 80, animate: false),
                            const SizedBox(height: 16),
                            RichText(
                              text: TextSpan(
                                style: AppTextStyles.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  letterSpacing: 2.0,
                                ),
                                children: [
                                  const TextSpan(text: 'ZENVYRO LABS '),
                                  const TextSpan(
                                    text: 'X',
                                    style: TextStyle(
                                      color: AppColors.skyBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' AWAIS'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'DigiKhata Pro',
                              style: AppTextStyles.loginHeaderTitle.copyWith(
                                fontSize: 48,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 30, height: 1.5, color: AppColors.amberGold),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'Smart Digital Ledger',
                                    style: AppTextStyles.loginHeaderTagline.copyWith(
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                Container(width: 30, height: 1.5, color: AppColors.amberGold),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      SlideTransition(
                        position: _welcomeSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome Back', 
                              style: AppTextStyles.welcomeTitle.copyWith(
                                color: isDarkMode ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Login to manage your business', 
                              style: AppTextStyles.welcomeSubtitle.copyWith(
                                color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      FadeTransition(
                        opacity: _contentFade,
                        child: Column(
                          children: [
                            CustomTextField(
                              hintText: 'Email or Phone Number',
                              prefixIcon: Icons.person_outline,
                              controller: _emailController,
                            ),
                            const SizedBox(height: 18),
                            CustomTextField(
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: InkWell(
                                onTap: () => NavigationUtils.push(context, const ForgotPasswordScreen()),
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 28),
                            _isLoading 
                              ? const CircularProgressIndicator(color: AppColors.primaryBlue)
                              : PrimaryButton(
                                  text: 'Login',
                                  onPressed: _handleLogin,
                                ),
                            const SizedBox(height: 24),
                            const DividerOr(),
                            const SizedBox(height: 24),
                            GoogleButton(onPressed: _handleGoogleSignIn),
                            if (ref.watch(securityProvider).isBiometricEnabled) ...[
                              const SizedBox(height: 24),
                              FingerprintButton(onPressed: _handleBiometricLogin),
                            ],
                            const SizedBox(height: 36),
                            Center(
                              child: InkWell(
                                onTap: () => NavigationUtils.push(context, const RegisterScreen()),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Register',
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
