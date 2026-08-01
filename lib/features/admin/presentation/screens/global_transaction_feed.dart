import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/data/models/transaction_model.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';

class GlobalTransactionFeed extends ConsumerStatefulWidget {
  const GlobalTransactionFeed({super.key});

  @override
  ConsumerState<GlobalTransactionFeed> createState() => _GlobalTransactionFeedState();
}

class _GlobalTransactionFeedState extends ConsumerState<GlobalTransactionFeed> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchGlobalTransactions();
  }

  Future<void> _fetchGlobalTransactions() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      // Fetch all transactions with business and profile info
      final response = await supabase
          .from('transactions')
          .select('*, businesses(name), customers(name), suppliers(name)')
          .order('created_at', ascending: false)
          .limit(50);

      setState(() {
        _transactions = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Global Feed',
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
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                onPressed: _fetchGlobalTransactions,
              ),
            ],
          ),
        ],
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.adminPrimary))
            : _transactions.isEmpty
                ? const Center(child: Text('No transactions found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      final tx = _transactions[index];
                      final businessName = tx['businesses']?['name'] ?? 'Unknown Business';
                      final partyName = tx['customers']?['name'] ?? tx['suppliers']?['name'] ?? 'Direct';
                      final isCredit = tx['type'] == 'credit';
                      final amount = (tx['amount'] as num).toDouble();
                      final date = DateTime.parse(tx['created_at']);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isCredit ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isCredit ? Icons.add_rounded : Icons.remove_rounded,
                                color: isCredit ? AppColors.success : AppColors.danger,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    businessName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    partyName,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd MMM, hh:mm a').format(date),
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isCredit ? '+' : '-'} PKR ${amount.toStringAsFixed(0)}',
                              style: GoogleFonts.robotoMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isCredit ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
