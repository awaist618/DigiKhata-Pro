import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FingerprintButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FingerprintButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryBlue, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, color: AppColors.primaryBlue, size: 28),
            const SizedBox(width: 12),
            Text(
              'Login with Fingerprint',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
