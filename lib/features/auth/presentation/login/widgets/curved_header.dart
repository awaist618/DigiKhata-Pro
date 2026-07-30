import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

class CurvedHeader extends StatelessWidget {
  final Widget child;
  const CurvedHeader({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ClipPath(
      clipper: HeaderClipper(),
      child: Container(
        height: size.height * 0.48, // Significantly taller to fit the large title
        width: double.infinity,
        decoration: BoxDecoration(
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
          children: [
            // Decorative elements
            Positioned(
              top: -50,
              right: -50,
              child: _CircularDecoration(size: 200),
            ),
            Positioned(
              bottom: 40,
              left: -30,
              child: _CircularDecoration(size: 150),
            ),
            child,
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

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
