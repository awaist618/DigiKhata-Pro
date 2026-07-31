import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:khataplus/features/dashboard/data/models/transaction_model.dart';

class DetailedReportScreen extends ConsumerStatefulWidget {
  final String reportType;
  const DetailedReportScreen({super.key, required this.reportType});

  @override
  ConsumerState<DetailedReportScreen> createState() => _DetailedReportScreenState();
}

class _DetailedReportScreenState extends ConsumerState<DetailedReportScreen> {
  DateTimeRange? _selectedDateRange;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.reportType,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: statsAsync.when(
              data: (stats) {
                var filteredTx = _filterTransactions(stats.recentTransactions);
                
                if (filteredTx.isEmpty) {
                  return const Center(child: Text('No data found for the selected filters'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredTx.length,
                  itemBuilder: (context, index) {
                    final tx = filteredTx[index];
                    return _buildTransactionItem(tx);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search description...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.calendar_today, size: 20),
              ),
            ],
          ),
          if (_selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Chip(
                    label: Text(
                      '${DateFormat('dd MMM').format(_selectedDateRange!.start)} - ${DateFormat('dd MMM').format(_selectedDateRange!.end)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                    onDeleted: () => setState(() => _selectedDateRange = null),
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

  Widget _buildTransactionItem(TransactionModel tx) {
    final isCredit = tx.type == TransactionType.credit;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                Text(tx.description ?? (isCredit ? 'Cash In' : 'Cash Out'), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                Text(DateFormat('dd MMM yyyy').format(tx.date), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            '₹ ${tx.amount.toStringAsFixed(0)}',
            style: GoogleFonts.robotoMono(
              fontWeight: FontWeight.bold,
              color: isCredit ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}
