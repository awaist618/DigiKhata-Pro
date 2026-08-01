import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import '../../data/models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import 'add_transaction_screen.dart';

class TransactionDetailsScreen extends ConsumerWidget {
  final TransactionModel transaction;
  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCredit = transaction.type == TransactionType.credit;
    final settings = ref.watch(settingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Transaction Details', 
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
            icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            onPressed: () => _showDeleteDialog(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05), 
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (isCredit ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCredit ? Icons.add_rounded : Icons.remove_rounded,
                      color: isCredit ? AppColors.success : AppColors.danger,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${isCredit ? "+" : "-"} ${settings.currency} ${transaction.amount.toStringAsFixed(2)}',
                      style: GoogleFonts.robotoMono(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    transaction.description ?? (isCredit ? 'Cash In' : 'Cash Out'),
                    style: GoogleFonts.poppins(
                      fontSize: 18, 
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow('Date', DateFormat('dd MMMM yyyy, hh:mm a').format(transaction.date), isDarkMode),
                  _buildDetailRow('Type', isCredit ? 'Credit (Cash In)' : 'Debit (Cash Out)', isDarkMode),
                  if (transaction.notes != null && transaction.notes!.isNotEmpty)
                    _buildDetailRow('Notes', transaction.notes!, isDarkMode),
                ],
              ),
            ),
            if (transaction.imageUrl != null) ...[
              const SizedBox(height: 24),
              Text(
                'Attachment', 
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(transaction.imageUrl!, fit: BoxFit.cover),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label, 
            style: GoogleFonts.inter(
              color: isDarkMode ? Colors.white70 : AppColors.textSecondary, 
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value, 
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
        title: Text('Delete Entry?', style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary)),
        content: Text('This will permanently remove the transaction and update the party balance.', style: TextStyle(color: isDarkMode ? Colors.white70 : AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await ref.read(transactionActionProvider).deleteTransaction(transaction);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back from details
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
