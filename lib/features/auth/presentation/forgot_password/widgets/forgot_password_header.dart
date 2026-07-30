import 'package:flutter/material.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/widgets/app_logo.dart';
import 'dart:ui';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        height: size.height * 0.32, // Increased height to prevent clipping branding
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.deepNavy,
              AppColors.headerMiddleBlue,
              AppColors.primaryBlue,
            ],
          ),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Decorative elements
            Positioned(
              top: -30,
              right: -20,
              child: _CircularDecoration(size: 150),
            ),
            Positioned(
              top: 40,
              left: 20,
              child: _DottedDecoration(),
            ),
            
            // Content
            SafeArea(
              bottom: false,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Custom Back Button
                    Align(
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                          tooltip: 'Back',
                        ),
                      ),
                    ),
                    const AppLogo(size: 64, animate: false),
                    const SizedBox(height: 12),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1.5,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularDecoration extends StatelessWidget {
  final double size;
  const _CircularDecoration({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _DottedDecoration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.1,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(
          12,
          (index) => Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 40);
    
    // Create a smooth wave
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 80,
      size.width * 0.5,
      size.height - 40,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height,
      size.width,
      size.height - 40,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
