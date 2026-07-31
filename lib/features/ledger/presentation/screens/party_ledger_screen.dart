import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/data/models/transaction_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/core/services/supabase_service.dart';

class PartyLedgerScreen extends ConsumerStatefulWidget {
  final String partyId;
  final String partyName;
  final bool isCustomer;

  const PartyLedgerScreen({
    super.key,
    required this.partyId,
    required this.partyName,
    required this.isCustomer,
  });

  @override
  ConsumerState<PartyLedgerScreen> createState() => _PartyLedgerScreenState();
}

class _PartyLedgerScreenState extends ConsumerState<PartyLedgerScreen> {
  late Future<List<TransactionModel>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactionsFuture = _fetchTransactions();
    });
  }

  Future<List<TransactionModel>> _fetchTransactions() async {
    final supabase = ref.read(supabaseServiceProvider).client;
    final column = widget.isCustomer ? 'customer_id' : 'supplier_id';
    
    final response = await supabase
        .from('transactions')
        .select()
        .eq(column, widget.partyId)
        .order('created_at', ascending: true); // Ascending for running balance calculation

    return (response as List).map((json) => TransactionModel.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${widget.partyName}\'s Ledger',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<TransactionModel>>(
        future: _transactionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions yet'));
          }

          double runningBalance = 0;
          final List<Map<String, dynamic>> ledgerItems = [];

          for (var tx in transactions) {
            final factor = tx.type == TransactionType.credit ? 1 : -1;
            runningBalance += tx.amount * factor;
            ledgerItems.add({
              'tx': tx,
              'balance': runningBalance,
            });
          }

          // Reverse for display (latest first)
          final reversedItems = ledgerItems.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reversedItems.length,
            itemBuilder: (context, index) {
              final item = reversedItems[index];
              final tx = item['tx'] as TransactionModel;
              final bal = item['balance'] as double;
              final isCredit = tx.type == TransactionType.credit;

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: (isCredit ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isCredit ? Icons.add : Icons.remove,
                              color: isCredit ? AppColors.success : AppColors.danger,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tx.description ?? (isCredit ? 'Cash In' : 'Cash Out'),
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy, hh:mm a').format(tx.date),
                                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? "+" : "-"}₹ ${tx.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.bold,
                                  color: isCredit ? AppColors.success : AppColors.danger,
                                ),
                              ),
                              Text(
                                'Bal: ₹ ${bal.toStringAsFixed(0)}',
                                style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (tx.imageUrl != null) ...[
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            tx.imageUrl!,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                      if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            tx.notes!,
                            style: GoogleFonts.inter(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
