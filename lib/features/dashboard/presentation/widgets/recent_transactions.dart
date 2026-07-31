import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/features/dashboard/presentation/screens/transaction_details_screen.dart';

class RecentTransactions extends ConsumerWidget {
  final List<TransactionModel> transactions;
  const RecentTransactions({super.key, required this.transactions});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {}, // Handled by View All logic usually
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('No transactions yet'),
          ))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isCredit = tx.type == TransactionType.credit;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: tx))),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
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
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat(settings.dateFormat).format(tx.date),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${isCredit ? "+" : "-"} ${settings.currency} ${tx.amount.toStringAsFixed(0)}',
                            style: GoogleFonts.robotoMono(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
          ),
      ],
    );
  }
}
