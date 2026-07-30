import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/theme/app_text_styles.dart';
import 'package:khataplus/core/utils/validators.dart';
import 'package:khataplus/core/widgets/app_logo.dart';
import 'package:khataplus/features/auth/presentation/login/login_screen.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/curved_header.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/divider_or.dart';
import 'widgets/google_button.dart';
import 'widgets/glass_info_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _businessController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;

  late AnimationController _fadeController;
  late Animation<double> _headerFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _formFade;

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

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic)),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the Terms & Conditions')),
        );
        return;
      }
      // TODO: Implement actual registration logic
      print('Registration Successful');
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _headerFade,
                    child: CurvedHeader(
                      height: MediaQuery.of(context).size.height * 0.58,
                      child: SafeArea(
                        bottom: false,
                        child: SizedBox(
                          width: double.infinity, // Force full width for centering
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 30),
                              const AppLogo(size: 70, animate: false),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    letterSpacing: 2.0,
                                  ),
                                  children: [
                                    const TextSpan(text: 'ZENVYRO LABS '),
                                    TextSpan(
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
                              const SizedBox(height: 24),
                              const GlassInfoCard(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
  
                  // Content Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SlideTransition(
                          position: _titleSlide,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Create Account',
                                style: AppTextStyles.welcomeTitle.copyWith(fontSize: 36),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start managing your business smarter',
                                style: AppTextStyles.welcomeSubtitle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        FadeTransition(
                          opacity: _formFade,
                          child: Column(
                            children: [
                              CustomTextField(
                                hintText: 'Full Name',
                                prefixIcon: Icons.person_outline,
                                controller: _nameController,
                                validator: (val) => AppValidators.validateRequired(val, 'Full Name'),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                hintText: 'Business Name',
                                prefixIcon: Icons.business_center_outlined,
                                controller: _businessController,
                                validator: (val) => AppValidators.validateRequired(val, 'Business Name'),
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                hintText: 'Email or Phone Number',
                                prefixIcon: Icons.email_outlined,
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: AppValidators.validateEmail,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                hintText: 'Password',
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                controller: _passwordController,
                                validator: AppValidators.validatePassword,
                              ),
                              const SizedBox(height: 16),
                              CustomTextField(
                                hintText: 'Confirm Password',
                                prefixIcon: Icons.lock_reset_outlined,
                                isPassword: true,
                                controller: _confirmPasswordController,
                                validator: (val) => AppValidators.validateConfirmPassword(val, _passwordController.text),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (val) => setState(() => _agreeToTerms = val ?? false),
                                    activeColor: AppColors.primaryBlue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        text: 'I agree to ',
                                        style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 14),
                                        children: [
                                          TextSpan(
                                            text: 'Terms & Conditions',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.primaryBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                text: 'Register',
                                onPressed: _handleRegister,
                              ),
                              const SizedBox(height: 24),
                              const DividerOr(),
                              const SizedBox(height: 24),
                              GoogleButton(onPressed: () {}),
                              const SizedBox(height: 32),
                              Center(
                                child: InkWell(
                                  onTap: () => Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) => LoginScreen()),
                                  ),
                                  child: RichText(
                                    text: TextSpan(
                                      text: 'Already have an account? ',
                                      style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary),
                                      children: [
                                        TextSpan(
                                          text: 'Login',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
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
      ),
    );
  }
}
