import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:intl/intl.dart';

class TrustedDevicesScreen extends ConsumerStatefulWidget {
  const TrustedDevicesScreen({super.key});

  @override
  ConsumerState<TrustedDevicesScreen> createState() => _TrustedDevicesScreenState();
}

class _TrustedDevicesScreenState extends ConsumerState<TrustedDevicesScreen> {
  bool _isLoading = true;
  List<dynamic> _sessions = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() => _isLoading = true);
    try {
      // In a real production app with Supabase Auth, you'd ideally have a table 
      // tracking sessions or use the Management API. 
      // For this demo, we'll simulate current active session info.
      final currentSession = ref.read(supabaseServiceProvider).currentSession;
      if (currentSession != null) {
        _sessions = [
          {
            'id': currentSession.user.id,
            'device_name': 'Current Device (Android)',
            'last_active': DateTime.now().toIso8601String(),
            'is_current': true,
          }
        ];
      }
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text('Trusted Devices', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildHeader(isDarkMode),
                const SizedBox(height: 32),
                Text(
                  'Current Active Sessions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ..._sessions.map((session) => _buildDeviceCard(session, isDarkMode)),
                const SizedBox(height: 40),
                _buildSecurityNote(isDarkMode),
              ],
            ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.deepNavy, AppColors.primaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.security_rounded, color: Colors.white, size: 48),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device Security',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Manage devices that have access to your account.',
                  style: GoogleFonts.inter(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceCard(dynamic session, bool isDarkMode) {
    final isCurrent = session['is_current'] == true;
    final lastActive = DateTime.parse(session['last_active']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isCurrent ? AppColors.success : AppColors.primaryBlue).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            session['device_name'].contains('Android') ? Icons.android : Icons.computer,
            color: isCurrent ? AppColors.success : AppColors.primaryBlue,
          ),
        ),
        title: Row(
          children: [
            Text(session['device_name'], style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14)),
            if (isCurrent) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: const Text('THIS DEVICE', style: TextStyle(color: AppColors.success, fontSize: 8, fontWeight: FontWeight.w900)),
              ),
            ],
          ],
        ),
        subtitle: Text(
          'Last active: ${DateFormat('dd MMM, hh:mm a').format(lastActive)}',
          style: const TextStyle(fontSize: 11),
        ),
        trailing: isCurrent 
          ? null 
          : IconButton(
              icon: const Icon(Icons.logout, color: AppColors.danger, size: 20),
              onPressed: () {},
            ),
      ),
    );
  }

  Widget _buildSecurityNote(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberGold.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.amberGold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'If you notice any suspicious activity, logout from all other devices and change your password immediately.',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.amberGold, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
