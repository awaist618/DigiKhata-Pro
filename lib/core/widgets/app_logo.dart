import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool animate;
  final double? borderRadius;

  const AppLogo({
    super.key,
    this.size = 320,
    this.animate = true,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? (size * 0.2); // Default to 20% of size
    if (animate) {
      return _AnimatedLogo(size: size, borderRadius: effectiveRadius);
    }
    return _LogoImage(size: size, borderRadius: effectiveRadius);
  }
}

class _LogoImage extends StatelessWidget {
  final double size;
  final double borderRadius;
  const _LogoImage({required this.size, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A2540),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Transform.scale(
          scale: 1.3, // Significant zoom
          alignment: const Alignment(0, -0.6), // Shift focus point upwards to hide bottom text
          child: Image.asset(
            'assets/images/logo.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.account_balance_wallet, size: size * 0.6, color: Colors.white);
            },
          ),
        ),
      ),
    );
  }
}

class _AnimatedLogo extends StatefulWidget {
  final double size;
  final double borderRadius;
  const _AnimatedLogo({required this.size, required this.borderRadius});

  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: _LogoImage(size: widget.size, borderRadius: widget.borderRadius),
    );
  }
}
