import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/curved_header.dart';

class CreateBusinessScreen extends StatelessWidget {
  const CreateBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            CurvedHeader(
              height: MediaQuery.of(context).size.height * 0.3,
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Add New Business',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Spacer for centering
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Logo Upload Placeholder
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryBlue, style: BorderStyle.none), // Custom dashed border needed
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Stack(
                        children: [
                          // Dashed Border Simulation
                          CustomPaint(
                            size: const Size(100, 100),
                            painter: _DashedCirclePainter(color: AppColors.primaryBlue),
                          ),
                          const Center(
                            child: Icon(Icons.camera_alt_outlined, color: AppColors.primaryBlue, size: 32),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CustomTextField(
                    hintText: 'Business Name',
                    prefixIcon: Icons.business_center_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    'Business Type',
                    Icons.category_outlined,
                    ['Retail Shop', 'Wholesale', 'Service Provider', 'Others'],
                  ),
                  const SizedBox(height: 20),
                  const CustomTextField(
                    hintText: 'Phone Number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 20),
                  const CustomTextField(
                    hintText: 'Address',
                    prefixIcon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildDropdownField(
                    'Currency',
                    Icons.monetization_on_outlined,
                    ['INR (₹)', 'USD (\$)', 'EUR (€)', 'GBP (£)'],
                  ),
                  const SizedBox(height: 40),
                  PrimaryButton(
                    text: 'Save Business',
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(String hint, IconData icon, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text(
                  hint,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                isExpanded: true,
                items: items.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (_) {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double startAngle = 0;

    final double circumference = 2 * 3.14159 * (size.width / 2);
    final int dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        dashWidth / (size.width / 2),
        false,
        paint,
      );
      startAngle += (dashWidth + dashSpace) / (size.width / 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
