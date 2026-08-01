import 'dart:io';
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

import 'package:khataplus/features/dashboard/presentation/providers/transaction_provider.dart';

import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:khataplus/features/dashboard/presentation/screens/add_transaction_screen.dart';
import 'package:khataplus/features/dashboard/presentation/screens/transaction_details_screen.dart';

import 'package:khataplus/features/dashboard/presentation/providers/tag_provider.dart';

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
  final _searchController = TextEditingController();
  bool _isSearching = false;
  TransactionType? _filterType;
  DateTimeRange? _dateRange;
  String? _filterTag;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet() {
    final tagsAsync = ref.watch(tagsProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Transactions', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 20),
              Text('Transaction Type', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFilterChip('All', null, _filterType == null, (val) => setModalState(() => _filterType = null)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cash In', TransactionType.credit, _filterType == TransactionType.credit, (val) => setModalState(() => _filterType = val)),
                  const SizedBox(width: 8),
                  _buildFilterChip('Cash Out', TransactionType.debit, _filterType == TransactionType.debit, (val) => setModalState(() => _filterType = val)),
                ],
              ),
              const SizedBox(height: 20),
              Text('Tags', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              tagsAsync.when(
                data: (tags) => Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _filterTag == null,
                      onSelected: (val) => setModalState(() => _filterTag = null),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    ...tags.map((tagObj) {
                      final tag = tagObj as dynamic;
                      return FilterChip(
                        label: Text(tag.name),
                        selected: _filterTag == tag.name,
                        onSelected: (val) => setModalState(() => _filterTag = val ? tag.name : null),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      );
                    }),
                  ],
                ),
                loading: () => const CircularProgressIndicator(),
                error: (err, _) => const SizedBox(),
              ),
              const SizedBox(height: 20),
              Text('Date Range', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today, color: AppColors.primaryBlue),
                title: Text(_dateRange == null ? 'Select Date Range' : '${DateFormat('dd MMM').format(_dateRange!.start)} - ${DateFormat('dd MMM').format(_dateRange!.end)}'),
                trailing: _dateRange != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setModalState(() => _dateRange = null)) : null,
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    initialDateRange: _dateRange,
                  );
                  if (picked != null) setModalState(() => _dateRange = picked);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {});
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, TransactionType? type, bool isSelected, Function(TransactionType?) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => onSelected(type),
      selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primaryBlue,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final transactionsAsync = ref.watch(partyTransactionsProvider((id: widget.partyId, isCustomer: widget.isCustomer)));
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Search ledger...', border: InputBorder.none),
              onChanged: (val) => setState(() {}),
            )
          : Text(
              '${widget.partyName}\'s Ledger',
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
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) _searchController.clear();
            }),
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: (_filterType != null || _dateRange != null || _filterTag != null) ? AppColors.primaryBlue : (isDarkMode ? Colors.white : AppColors.textPrimary)),
            onPressed: _showFilterSheet,
          ),
          if (widget.isCustomer)
            IconButton(
              icon: Icon(Icons.qr_code_2, color: isDarkMode ? AppColors.skyBlue : AppColors.primaryBlue),
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
            icon: Icon(Icons.notifications_active_outlined, color: isDarkMode ? AppColors.skyBlue : AppColors.primaryBlue),
            onPressed: () {
              transactionsAsync.whenData((transactions) {
                double currentBalance = 0;
                for (var tx in transactions) {
                  final factor = tx.type == TransactionType.credit ? 1 : -1;
                  currentBalance += tx.amount * factor;
                }
                _sendReminder(currentBalance);
              });
            },
            tooltip: 'Send Reminder',
          ),
          IconButton(
            icon: Icon(Icons.file_download_outlined, color: isDarkMode ? AppColors.skyBlue : AppColors.primaryBlue),
            onPressed: () {
              transactionsAsync.whenData((transactions) => _handleExport(transactions));
            },
            tooltip: 'Export Ledger',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: transactionsAsync.when(
        data: (allTransactions) {
          final query = _searchController.text.toLowerCase();
          
          final transactions = allTransactions.where((tx) {
            final matchesSearch = query.isEmpty || (tx.description?.toLowerCase().contains(query) ?? false) || (tx.notes?.toLowerCase().contains(query) ?? false);
            final matchesType = _filterType == null || tx.type == _filterType;
            final matchesDate = _dateRange == null || (tx.date.isAfter(_dateRange!.start) && tx.date.isBefore(_dateRange!.end.add(const Duration(days: 1))));
            final matchesTag = _filterTag == null || tx.tag == _filterTag;
            return matchesSearch && matchesType && matchesDate && matchesTag;
          }).toList();

          if (transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: isDarkMode ? Colors.white24 : Colors.black12),
                  const SizedBox(height: 16),
                  Text(
                    allTransactions.isEmpty ? 'No transactions yet' : 'No matching transactions',
                    style: TextStyle(color: isDarkMode ? Colors.white70 : AppColors.textSecondary),
                  ),
                ],
              ),
            );
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

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                      ),
                    ],
                  ),
                  endActionPane: ActionPane(
                    motion: DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _confirmDelete(tx),
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_rounded,
                        label: 'Delete',
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(24)),
                      ),
                    ],
                  ),
                  child: Container(
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
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TransactionDetailsScreen(transaction: tx),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(24),
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
                                            color: isDarkMode ? Colors.white : AppColors.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                  if (tx.tag != null) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        tx.tag!,
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                  ],
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
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
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isDarkMode ? AppColors.deepNavy : AppColors.background,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          'BAL: ${settings.currency} ${bal.toStringAsFixed(0)}',
                                          style: GoogleFonts.inter(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (tx.imageUrl != null || tx.localImagePath != null) ...[
                                const SizedBox(height: 16),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Stack(
                                    children: [
                                      tx.localImagePath != null 
                                        ? Image.file(
                                            File(tx.localImagePath!),
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            tx.imageUrl!,
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              height: 160,
                                              color: isDarkMode ? Colors.white10 : Colors.black12,
                                              child: const Icon(Icons.broken_image, color: AppColors.textSecondary),
                                            ),
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
                                    color: isDarkMode ? AppColors.deepNavy : AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.notes, size: 14, color: isDarkMode ? Colors.white70 : AppColors.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          tx.notes!,
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            fontStyle: FontStyle.italic,
                                            color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
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
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
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

  Widget _buildCircularAction({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _confirmDelete(TransactionModel tx) {
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
}
