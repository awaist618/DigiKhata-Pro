import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/features/dashboard/data/models/transaction_model.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'package:khataplus/features/qr/presentation/widgets/customer_qr_dialog.dart';
import 'package:khataplus/core/services/export_service.dart';
import 'package:url_launcher/url_launcher.dart';

class PartyLedgerScreen extends ConsumerStatefulWidget {
  final String partyId;
  final String partyName;
  final String? partyPhone;
  final bool isCustomer;

  const PartyLedgerScreen({
    super.key,
    required this.partyId,
    required this.partyName,
    this.partyPhone,
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

  void _handleExport(List<TransactionModel> transactions) {
    final businessName = ref.read(businessNameProvider);
    final currency = ref.read(settingsProvider).currency;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Export ${widget.partyName}\'s Ledger', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExportOption('PDF', Icons.picture_as_pdf, Colors.red, () async {
                  Navigator.pop(context);
                  await ExportService.exportLedgerToPdf(
                    title: '${widget.partyName}\'s Ledger',
                    transactions: transactions,
                    businessName: businessName,
                    currency: currency,
                  );
                }),
                _buildExportOption('Excel', Icons.table_chart, Colors.green, () async {
                  Navigator.pop(context);
                  await ExportService.exportLedgerToExcel(
                    transactions: transactions,
                    fileName: '${widget.partyName.replaceAll(' ', '_')}_ledger'.toLowerCase(),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _sendReminder(double balance) async {
    final settings = ref.read(settingsProvider);
    final businessName = ref.read(businessNameProvider);
    final String message;
    
    if (balance < 0) {
      message = 'Dear ${widget.partyName}, a friendly reminder that you have an outstanding balance of ${settings.currency} ${balance.abs().toStringAsFixed(0)} with $businessName. Please clear it at your earliest convenience.';
    } else {
      message = 'Dear ${widget.partyName}, your account balance with $businessName is ${settings.currency} ${balance.toStringAsFixed(0)}. Thank you for your business!';
    }

    final Uri smsUri = Uri(
      scheme: 'sms',
      path: widget.partyPhone ?? '',
      queryParameters: <String, String>{
        'body': message,
      },
    );

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch SMS app')),
        );
      }
    }
  }

  Widget _buildExportOption(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        ],
      ),
    );
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
        actions: [
          if (widget.isCustomer)
            IconButton(
              icon: const Icon(Icons.qr_code_2, color: AppColors.primaryBlue),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => CustomerQrDialog(
                    customerName: widget.partyName,
                    customerId: widget.partyId,
                    businessName: ref.read(businessNameProvider),
                  ),
                );
              },
              tooltip: 'Customer QR',
            ),
          IconButton(
            icon: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryBlue),
            onPressed: () async {
              final transactions = await _transactionsFuture;
              double currentBalance = 0;
              for (var tx in transactions) {
                final factor = tx.type == TransactionType.credit ? 1 : -1;
                currentBalance += tx.amount * factor;
              }
              _sendReminder(currentBalance);
            },
            tooltip: 'Send Reminder',
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue),
            onPressed: () async {
              final transactions = await _transactionsFuture;
              _handleExport(transactions);
            },
            tooltip: 'Export Ledger',
          ),
          const SizedBox(width: 8),
        ],
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

          final settings = ref.watch(settingsProvider);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reversedItems.length,
            itemBuilder: (context, index) {
              final item = reversedItems[index];
              final tx = item['tx'] as TransactionModel;
              final bal = item['balance'] as double;
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
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('${settings.dateFormat}, hh:mm a').format(tx.date),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? "+" : "-"} ${settings.currency} ${tx.amount.toStringAsFixed(0)}',
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: isCredit ? AppColors.success : AppColors.danger,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'BAL: ${settings.currency} ${bal.toStringAsFixed(0)}',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (tx.imageUrl != null) ...[
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.network(
                                tx.imageUrl!,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.5), shape: BoxShape.circle),
                                  child: const Icon(Icons.fullscreen, color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (tx.notes != null && tx.notes!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notes, size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tx.notes!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
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
