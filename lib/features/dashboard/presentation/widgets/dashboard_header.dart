import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'package:khataplus/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:khataplus/features/profile/presentation/providers/profile_provider.dart';
import 'package:khataplus/features/qr/presentation/screens/qr_manager_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:khataplus/features/business/presentation/selection/business_selection_screen.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/core/widgets/app_logo.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  void _showBusinessSwitcher(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.adminSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Switch Business',
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    NavigationUtils.push(context, const BusinessSelectionScreen());
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Manage'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Flexible(child: BusinessListSwitcher()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessName = ref.watch(businessNameProvider);
    final profileAsync = ref.watch(profileProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String greetingName = '';
    final user = profileAsync.value;

    if (user?.fullName != null && user!.fullName!.trim().isNotEmpty) {
      final parts = user.fullName!.trim().split(' ');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        greetingName = parts.first[0].toUpperCase() + parts.first.substring(1).toLowerCase();
      }
    }

    if (greetingName.isEmpty) {
      final parts = businessName.trim().split(' ');
      if (parts.isNotEmpty && parts.first.isNotEmpty) {
        greetingName = parts.first[0].toUpperCase() + parts.first.substring(1).toLowerCase();
      }
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.deepNavy, AppColors.primaryBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Column(
            children: [
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      const AppLogo(size: 28, animate: false, borderRadius: 6),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ZENVYRO LABS',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white.withValues(alpha: 0.9),
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'Powered by DigiKhata Pro',
                            style: GoogleFonts.inter(
                              fontSize: 8,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showBusinessSwitcher(context, ref),
                        borderRadius: BorderRadius.circular(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${'hello'.tr()}, $greetingName 👋',
                                    style: GoogleFonts.poppins(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    '${'welcome_to'.tr()} ${businessName.trim()}',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      color: Colors.white.withValues(alpha: 0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 18),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeaderAction(
                          icon: Icons.qr_code_2,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrManagerScreen())),
                        ),
                        const SizedBox(width: 12),
                        _buildHeaderAction(
                          icon: Icons.notifications_outlined,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                          hasBadge: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderAction({required IconData icon, required VoidCallback onTap, bool hasBadge = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          if (hasBadge)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.amberGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.deepNavy, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class BusinessListSwitcher extends ConsumerWidget {
  const BusinessListSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Corrected provider name to businessListProvider
    final businessesAsync = ref.watch(businessListProvider);
    final selectedId = ref.watch(selectedBusinessIdProvider);

    return businessesAsync.when(
      data: (businesses) => ListView.builder(
        shrinkWrap: true,
        itemCount: businesses.length,
        itemBuilder: (context, index) {
          final biz = businesses[index];
          final isSelected = biz.id == selectedId;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primaryBlue : Colors.grey.withValues(alpha: 0.2),
              ),
            ),
            child: ListTile(
              onTap: () {
                ref.read(selectedBusinessIdProvider.notifier).state = biz.id;
                Navigator.pop(context);
              },
              leading: CircleAvatar(
                backgroundColor: isSelected ? AppColors.primaryBlue : Colors.grey[200],
                child: Text(
                  biz.name[0].toUpperCase(),
                  style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                ),
              ),
              title: Text(
                biz.name,
                style: GoogleFonts.inter(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(biz.type ?? 'Business'),
              trailing: isSelected 
                ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                : null,
            ),
          );
        },
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Text('Error: $err'),
    );
  }
}
