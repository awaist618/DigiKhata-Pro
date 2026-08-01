import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:khataplus/features/dashboard/data/models/transaction_model.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/features/dashboard/presentation/screens/transaction_details_screen.dart';
import 'package:khataplus/features/profile/presentation/screens/tag_management_screen.dart';

import 'package:easy_localization/easy_localization.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'daily_ledger'.tr(),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.style_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TagManagementScreen())),
            tooltip: 'Manage Tags',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats.recentTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: (isDarkMode ? Colors.white : AppColors.textSecondary).withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'ledger_empty'.tr(),
                    style: GoogleFonts.poppins(color: isDarkMode ? Colors.white70 : AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'record_first_entry'.tr(),
                    style: GoogleFonts.inter(color: isDarkMode ? Colors.white60 : AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stats.recentTransactions.length,
            itemBuilder: (context, index) {
              final tx = stats.recentTransactions[index];
              final isCredit = tx.type == TransactionType.credit;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: tx))),
                    borderRadius: BorderRadius.circular(24),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: (isCredit ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isCredit ? Icons.add_rounded : Icons.remove_rounded,
                              color: isCredit ? AppColors.success : AppColors.danger,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.description ?? (isCredit ? 'Cash In' : 'Cash Out'),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold, 
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('${settings.dateFormat}, hh:mm a').format(tx.date),
                                  style: GoogleFonts.inter(
                                    fontSize: 12, 
                                    color: isDarkMode ? Colors.white60 : AppColors.textSecondary, 
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${isCredit ? "+" : "-"} ${settings.currency} ${tx.amount.toStringAsFixed(0)}',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: isCredit ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
