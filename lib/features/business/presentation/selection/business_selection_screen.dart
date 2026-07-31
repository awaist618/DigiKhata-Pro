import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/main_wrapper/main_wrapper.dart';
import '../create/create_business_screen.dart';
import '../providers/business_provider.dart';

class BusinessSelectionScreen extends ConsumerStatefulWidget {
  const BusinessSelectionScreen({super.key});

  @override
  ConsumerState<BusinessSelectionScreen> createState() => _BusinessSelectionScreenState();
}

class _BusinessSelectionScreenState extends ConsumerState<BusinessSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    final businessListAsync = ref.watch(businessListProvider);
    final selectedBusinessId = ref.watch(selectedBusinessIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Business',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose a business to continue managing your accounts.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: businessListAsync.when(
              data: (businesses) {
                if (businesses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.business_center_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text('No businesses found', style: GoogleFonts.inter(color: AppColors.textSecondary)),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => NavigationUtils.push(context, const CreateBusinessScreen()),
                          child: const Text('Create Your First Business'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: businesses.length,
                  itemBuilder: (context, index) {
                    final business = businesses[index];
                    final isSelected = selectedBusinessId == business.id;

                    return GestureDetector(
                      onTap: () {
                        ref.read(selectedBusinessIdProvider.notifier).state = business.id;
                        ref.read(selectedBusinessProvider.notifier).state = business;
                        
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              NavigationUtils.createRoute(const MainWrapper()),
                              (route) => false,
                            );
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? AppColors.primaryBlue.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.business_rounded, color: AppColors.primaryBlue, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    business.name,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    business.type ?? 'General Business',
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                              color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_business_fab',
        onPressed: () => NavigationUtils.push(context, const CreateBusinessScreen()),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
