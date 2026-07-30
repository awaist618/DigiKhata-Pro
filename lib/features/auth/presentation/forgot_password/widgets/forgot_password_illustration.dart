import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:khataplus/core/theme/app_colors.dart';

class ForgotPasswordIllustration extends StatelessWidget {
  final double size;
  const ForgotPasswordIllustration({super.key, this.size = 160});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LockPainter(),
      ),
    );
  }
}

class _LockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final lockWidth = size.width * 0.45;
    final lockHeight = size.height * 0.35;
    
    // Draw background circles/decorations
    final circlePaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(center.translate(-20, -10), size.width * 0.3, circlePaint);
    canvas.drawCircle(center.translate(30, 20), size.width * 0.2, circlePaint);

    // Lock Body
    final lockBodyRect = Rect.fromCenter(
      center: center.translate(0, 15),
      width: lockWidth,
      height: lockHeight,
    );
    final lockBodyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primaryBlue, Color(0xFF1E63FF)],
      ).createShader(lockBodyRect);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(lockBodyRect, const Radius.circular(12)),
      lockBodyPaint,
    );

    // Keyhole
    final keyholePaint = Paint()..color = const Color(0xFF0A2540).withValues(alpha: 0.8);
    canvas.drawCircle(center.translate(0, 12), 6, keyholePaint);
    final keyholePath = Path();
    keyholePath.moveTo(center.dx - 3, center.dy + 12);
    keyholePath.lineTo(center.dx + 3, center.dy + 12);
    keyholePath.lineTo(center.dx + 5, center.dy + 22);
    keyholePath.lineTo(center.dx - 5, center.dy + 22);
    keyholePath.close();
    canvas.drawPath(keyholePath, keyholePaint);

    // Lock Shackle (Handle)
    final shacklePath = Path();
    final shackleRect = Rect.fromCenter(
      center: center.translate(0, -5),
      width: lockWidth * 0.65,
      height: lockHeight * 0.85,
    );
    shacklePath.addRRect(RRect.fromRectAndCorners(
      shackleRect,
      topLeft: const Radius.circular(40),
      topRight: const Radius.circular(40),
    ));
    
    final shacklePaint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    
    canvas.drawPath(shacklePath, shacklePaint);

    // Golden Key
    final keyCenter = center.translate(45, 30);
    final keyPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.amberGold, Color(0xFFFF9800)],
      ).createShader(Rect.fromLTWH(keyCenter.dx - 20, keyCenter.dy - 10, 60, 30));
    
    final keyPath = Path();
    // Key Head
    keyPath.addOval(Rect.fromCircle(center: keyCenter.translate(35, 0), radius: 10));
    // Key Shaft
    keyPath.addRRect(RRect.fromRectAndRadius(
      Rect.fromLTWH(keyCenter.dx - 5, keyCenter.dy - 3, 40, 6),
      const Radius.circular(3),
    ));
    // Key Teeth
    keyPath.addRect(Rect.fromLTWH(keyCenter.dx + 5, keyCenter.dy + 3, 4, 6));
    keyPath.addRect(Rect.fromLTWH(keyCenter.dx + 13, keyCenter.dy + 3, 4, 4));

    canvas.save();
    canvas.translate(keyCenter.dx, keyCenter.dy);
    canvas.rotate(-0.3);
    canvas.translate(-keyCenter.dx, -keyCenter.dy);
    canvas.drawPath(keyPath, keyPaint);
    canvas.restore();
    
    // Decorative Stars
    final starPaint = Paint()..color = AppColors.amberGold.withValues(alpha: 0.8);
    _drawStar(canvas, center.translate(-55, -45), 5, starPaint);
    _drawStar(canvas, center.translate(65, -15), 4, starPaint);
    _drawStar(canvas, center.translate(-70, 20), 3, starPaint);
  }

  void _drawStar(Canvas canvas, Offset position, double radius, Paint paint) {
    final path = Path();
    const int points = 5;
    const double angle = math.pi / points;
    
    for (int i = 0; i < 2 * points; i++) {
      double r = (i % 2 == 0) ? radius : radius * 0.4;
      double currAngle = i * angle - math.pi / 2;
      double x = position.dx + r * math.cos(currAngle);
      double y = position.dy + r * math.sin(currAngle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
