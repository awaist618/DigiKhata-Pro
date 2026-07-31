import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/providers/settings_provider.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final currency = settings.currency;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildNotificationGroup('Today'),
          _buildNotificationItem(
            'Payment Reminder',
            'Ahmed Traders has an outstanding due of $currency 4,500.',
            Icons.notifications_active,
            AppColors.danger,
            '2h ago',
          ),
          _buildNotificationItem(
            'Cash In Recorded',
            '$currency 1,200 received from Zenvyro Labs.',
            Icons.check_circle,
            AppColors.success,
            '5h ago',
          ),
          const SizedBox(height: 24),
          _buildNotificationGroup('Yesterday'),
          _buildNotificationItem(
            'New Feature',
            'You can now export reports in Excel format!',
            Icons.star,
            AppColors.amberGold,
            '1d ago',
          ),
          _buildNotificationItem(
            'System Announcement',
            'Scheduled maintenance on Sunday 2:00 AM.',
            Icons.info,
            AppColors.primaryBlue,
            '1d ago',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationGroup(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildNotificationItem(String title, String body, IconData icon, Color color, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(body, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
