import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class DashboardStats {
  final double totalReceivable;
  final double totalPayable;
  final double todayCashIn;
  final double todayCashOut;
  final List<TransactionModel> recentTransactions;

  DashboardStats({
    required this.totalReceivable,
    required this.totalPayable,
    required this.todayCashIn,
    required this.todayCashOut,
    required this.recentTransactions,
  });
}

class DashboardRepository {
  final SupabaseClient _client;

  DashboardRepository(this._client);

  Future<DashboardStats> getDashboardStats(String businessId) async {
    try {
      // Total Receivable/Payable from Customers
      final customers = await _client
          .from('customers')
          .select('balance')
          .eq('business_id', businessId);
      
      double receivable = 0;
      double payable = 0;
      for (var c in (customers as List)) {
        double bal = (c['balance'] as num).toDouble();
        if (bal > 0) receivable += bal;
        else if (bal < 0) payable += bal.abs();
      }

      // Today's Transactions
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day).toIso8601String();
      
      final todayTx = await _client
          .from('transactions')
          .select()
          .eq('business_id', businessId)
          .gte('created_at', startOfDay);

      double cashIn = 0;
      double cashOut = 0;
      for (var t in (todayTx as List)) {
        double amount = (t['amount'] as num).toDouble();
        if (t['type'] == 'credit') cashIn += amount;
        else cashOut += amount;
      }

      // Recent Transactions (Fetch last 30 days for better analytics)
      final thirtyDaysAgo = now.subtract(const Duration(days: 30)).toIso8601String();
      
      final recentTxResponse = await _client
          .from('transactions')
          .select()
          .eq('business_id', businessId)
          .gte('created_at', thirtyDaysAgo)
          .order('created_at', ascending: false);
      
      final recentTransactions = (recentTxResponse as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      return DashboardStats(
        totalReceivable: receivable,
        totalPayable: payable,
        todayCashIn: cashIn,
        todayCashOut: cashOut,
        recentTransactions: recentTransactions,
      );
    } catch (e) {
      debugPrint('Error fetching dashboard stats: $e');
      // Re-throw if it's not a "table not found" or "empty" error to allow UI to handle it
      if (e.toString().contains('does not exist')) {
        return DashboardStats(
          totalReceivable: 0,
          totalPayable: 0,
          todayCashIn: 0,
          todayCashOut: 0,
          recentTransactions: [],
        );
      }
      rethrow;
    }
  }
}
