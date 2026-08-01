import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';

class PushNotificationScreen extends StatelessWidget {
  const PushNotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Broadcaster', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compose Notification', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildInputField('Notification Title', 'Enter title...', Icons.title),
            const SizedBox(height: 16),
            _buildInputField('Message Body', 'Enter message detail...', Icons.message, maxLines: 4),
            const SizedBox(height: 32),
            Text('Target Audience', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: isDarkMode ? AppColors.surfaceDark : Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  RadioListTile(value: 0, groupValue: 0, onChanged: (v) {}, title: const Text('All Registered Users', style: TextStyle(fontSize: 14))),
                  RadioListTile(value: 1, groupValue: 0, onChanged: (v) {}, title: const Text('Only Active Businesses', style: TextStyle(fontSize: 14))),
                ],
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.send),
              label: const Text('Broadcast Now', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, String hint, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        TextField(
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20),
            filled: true,
            fillColor: Colors.white, // Needs theme logic
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }
}
