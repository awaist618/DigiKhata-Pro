import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import '../../data/models/transaction_model.dart';
import 'package:intl/intl.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/features/dashboard/presentation/screens/transaction_details_screen.dart';

import 'package:easy_localization/easy_localization.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:khataplus/features/dashboard/presentation/screens/add_transaction_screen.dart';
import 'package:khataplus/features/dashboard/presentation/providers/transaction_provider.dart';

class RecentTransactions extends ConsumerWidget {
  final List<TransactionModel> transactions;
  const RecentTransactions({super.key, required this.transactions});

  void _confirmDelete(BuildContext context, WidgetRef ref, TransactionModel tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.logoNavyBottom : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Delete Entry?', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to permanently delete this transaction?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(transactionActionProvider).deleteTransaction(tx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'recent_transactions'.tr(),
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {}, // Handled by View All logic usually
              child: Text(
                'view_all'.tr(),
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
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text('no_transactions'.tr()),
          ))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length > 5 ? 5 : transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final isCredit = tx.type == TransactionType.credit;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Slidable(
                  key: Key(tx.id),
                  startActionPane: ActionPane(
                    motion: DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(
                                type: tx.type,
                                transaction: tx,
                              ),
                            ),
                          );
                        },
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _confirmDelete(context, ref, tx),
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_rounded,
                        label: 'Delete',
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode ? Colors.black.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.02),
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
                                        color: isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      DateFormat(settings.dateFormat).format(tx.date),
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: isDarkMode ? AppColors.textSecondaryDark : AppColors.textSecondary,
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
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
