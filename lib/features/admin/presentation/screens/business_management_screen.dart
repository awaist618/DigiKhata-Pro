import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../providers/admin_provider.dart';

import 'package:easy_localization/easy_localization.dart';

class BusinessManagementScreen extends ConsumerWidget {
  const BusinessManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(adminBusinessesProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                'business_directory'.tr(),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.adminGradientStart, AppColors.adminGradientEnd],
                  ),
                ),
              ),
            ),
          ),
        ],
        body: businessesAsync.when(
          data: (businesses) => ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final biz = businesses[index];
              final owner = biz['profiles']['full_name'] ?? 'Unknown';
              
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDarkMode ? Colors.white.withValues(alpha: 0.05) : AppColors.border.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.adminPrimary.withValues(alpha: 0.2), AppColors.adminPrimary.withValues(alpha: 0.05)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.storefront_rounded, color: AppColors.adminPrimary, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                biz['name'] ?? 'Untitled Business', 
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w800, 
                                  fontSize: 18,
                                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.person_rounded, size: 12, color: AppColors.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    owner, 
                                    style: GoogleFonts.inter(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'VERIFIED', 
                            style: GoogleFonts.inter(
                              fontSize: 9, 
                              color: AppColors.success, 
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.backgroundDark.withValues(alpha: 0.5) : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              Icons.location_on_rounded, 
                              biz['address'] ?? 'No Address',
                              isDarkMode,
                            ),
                          ),
                          Container(width: 1, height: 20, color: AppColors.border.withValues(alpha: 0.3)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoItem(
                              Icons.phone_rounded, 
                              biz['phone'] ?? 'No Phone',
                              isDarkMode,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.adminPrimary)),
          error: (err, _) => Center(child: Text('Error: $err')),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, bool isDarkMode) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.adminPrimary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value, 
            style: GoogleFonts.inter(
              fontSize: 11, 
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
