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

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Daily Ledger',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: statsAsync.when(
        data: (stats) {
          if (stats.recentTransactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Your ledger is empty',
                    style: GoogleFonts.poppins(color: AppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Record your first entry from the Dashboard',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('${settings.dateFormat}, hh:mm a').format(tx.date),
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isCredit ? "+" : "-"} ${settings.currency} ${tx.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.robotoMono(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: isCredit ? AppColors.success : AppColors.danger,
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
