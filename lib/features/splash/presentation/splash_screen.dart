import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/business/presentation/selection/business_selection_screen.dart';
import '../../auth/presentation/login/login_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_logo.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:khataplus/core/providers/security_provider.dart';

import 'package:khataplus/features/admin/presentation/screens/admin_main_wrapper.dart';
import 'package:khataplus/features/profile/presentation/providers/profile_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  void _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final session = ref.read(supabaseServiceProvider).currentSession;
    final security = ref.read(securityProvider);

    if (session != null) {
      if (security.isBiometricEnabled) {
        final authenticated = await ref.read(securityProvider.notifier).authenticate();
        if (authenticated && mounted) {
          final profile = await ref.read(profileRepositoryProvider).getProfile(session.user.id);
          if (profile?.role == 'admin') {
            NavigationUtils.pushReplacement(context, const AdminMainWrapper());
          } else {
            NavigationUtils.pushReplacement(context, const BusinessSelectionScreen());
          }
        } else if (mounted) {
          NavigationUtils.pushReplacement(context, const LoginScreen());
        }
      } else {
        final profile = await ref.read(profileRepositoryProvider).getProfile(session.user.id);
        if (profile?.role == 'admin') {
          NavigationUtils.pushReplacement(context, const AdminMainWrapper());
        } else {
          NavigationUtils.pushReplacement(context, const BusinessSelectionScreen());
        }
      }
    } else {
      NavigationUtils.pushReplacement(context, const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set status bar to light for dark gradient background
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.deepNavy, AppColors.electricBlue],
              stops: [0.0, 1.0],
              transform: GradientRotation(135 * 3.14159 / 180),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const AppLogo(size: 240),
                  const SizedBox(height: 24),
                  Text(
                    'DigiKhata Pro',
                    style: GoogleFonts.poppins(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'Smart Digital Ledger',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20, // Adjusted for SafeArea
                child: SafeArea(
                  child: Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.amberGold,
                            letterSpacing: 2.0,
                          ),
                          children: [
                            const TextSpan(text: 'ZENVYRO LABS '),
                            const TextSpan(
                              text: 'X',
                              style: TextStyle(
                                color: AppColors.electricBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(text: ' AWAIS'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Powered by Zenvyro Labs',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
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
