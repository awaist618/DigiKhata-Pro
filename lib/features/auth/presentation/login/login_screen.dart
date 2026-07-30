import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/theme/app_text_styles.dart';
import 'package:khataplus/core/widgets/app_logo.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/curved_header.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/fingerprint_button.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/divider_or.dart';
import 'package:khataplus/features/auth/presentation/register/register_screen.dart';
import 'package:khataplus/features/auth/presentation/forgot_password/forgot_password_screen.dart';
import 'package:khataplus/features/business/presentation/selection/business_selection_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
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

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email == 'admin@gmail.com' && password == 'password123') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BusinessSelectionScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid email or password. Try admin@gmail.com / password123'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
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
                            Text('Welcome Back', style: AppTextStyles.welcomeTitle),
                            const SizedBox(height: 10),
                            Text('Login to manage your business', style: AppTextStyles.welcomeSubtitle),
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
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                                ),
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
                            PrimaryButton(
                              text: 'Login',
                              onPressed: _handleLogin,
                            ),
                            const SizedBox(height: 28),
                            const DividerOr(),
                            const SizedBox(height: 28),
                            FingerprintButton(onPressed: () {}),
                            const SizedBox(height: 36),
                            Center(
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const RegisterScreen()),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: AppColors.textSecondary,
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
