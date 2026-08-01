import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:khataplus/features/dashboard/data/models/transaction_model.dart';
import 'package:khataplus/features/dashboard/presentation/screens/transaction_details_screen.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'package:khataplus/core/services/export_service.dart';

class DetailedReportScreen extends ConsumerStatefulWidget {
  final String reportType;
  const DetailedReportScreen({super.key, required this.reportType});

  @override
  ConsumerState<DetailedReportScreen> createState() => _DetailedReportScreenState();
}

class _DetailedReportScreenState extends ConsumerState<DetailedReportScreen> {
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  void _handleExport() async {
    final stats = ref.read(dashboardStatsProvider).value;
    final businessName = ref.read(businessNameProvider);
    final currency = ref.read(settingsProvider).currency;
    
    if (stats == null) return;

    final filteredTx = _filterTransactions(stats.recentTransactions);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Export Report', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildExportOption('PDF', Icons.picture_as_pdf, Colors.red, () async {
                  Navigator.pop(context);
                  await ExportService.exportLedgerToPdf(
                    title: widget.reportType,
                    transactions: filteredTx,
                    businessName: businessName,
                    currency: currency,
                  );
                }),
                _buildExportOption('Excel', Icons.table_chart, Colors.green, () async {
                  Navigator.pop(context);
                  await ExportService.exportLedgerToExcel(
                    transactions: filteredTx,
                    fileName: widget.reportType.replaceAll(' ', '_').toLowerCase(),
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
    final statsAsync = ref.watch(dashboardStatsProvider);
    final settings = ref.watch(settingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.reportType,
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
            icon: Icon(Icons.file_download_outlined, color: isDarkMode ? AppColors.skyBlue : AppColors.primaryBlue),
            onPressed: _handleExport,
            tooltip: 'Export Report',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(isDarkMode),
          Expanded(
            child: statsAsync.when(
              data: (stats) {
                var filteredTx = _filterTransactions(stats.recentTransactions);
                
                if (filteredTx.isEmpty) {
                  return Center(
                    child: Text(
                      'No data found for the selected filters',
                      style: TextStyle(color: isDarkMode ? Colors.white70 : AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTx.length,
                  itemBuilder: (context, index) {
                    final tx = filteredTx[index];
                    return _buildTransactionItem(tx, settings, isDarkMode);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err', style: TextStyle(color: AppColors.error))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search description...',
                    hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : AppColors.textSecondary),
                    prefixIcon: Icon(Icons.search, size: 20, color: isDarkMode ? AppColors.skyBlue : AppColors.primaryBlue),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: isDarkMode ? AppColors.deepNavy : AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.calendar_today, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: isDarkMode ? AppColors.skyBlue.withValues(alpha: 0.1) : null,
                ),
              ),
            ],
          ),
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Chip(
                    backgroundColor: isDarkMode ? AppColors.primaryBlue.withValues(alpha: 0.2) : null,
                    label: Text(
                      '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
                      style: TextStyle(fontSize: 12, color: isDarkMode ? Colors.white : null),
                    ),
                    onDeleted: () => setState(() => _selectedDateRange = null),
                    deleteIconColor: isDarkMode ? Colors.white70 : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> transactions) {
    return transactions.where((tx) {
      bool matchesSearch = tx.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? true;
      bool matchesDate = true;
      if (_selectedDateRange != null) {
        matchesDate = tx.date.isAfter(_selectedDateRange!.start) && 
                      tx.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)));
      }
      return matchesSearch && matchesDate;
    }).toList();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  Widget _buildTransactionItem(TransactionModel tx, dynamic settings, bool isDarkMode) {
    final isCredit = tx.type == TransactionType.credit;
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionDetailsScreen(transaction: tx))),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isCredit ? Icons.add_circle : Icons.remove_circle,
              color: isCredit ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.description ?? (isCredit ? 'Cash In' : 'Cash Out'), 
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    DateFormat('dd MMM yyyy').format(tx.date), 
                    style: TextStyle(
                      fontSize: 12, 
                      color: isDarkMode ? Colors.white60 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${settings.currency} ${tx.amount.toStringAsFixed(0)}',
              style: GoogleFonts.robotoMono(
                fontWeight: FontWeight.bold,
                color: isCredit ? AppColors.success : AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
