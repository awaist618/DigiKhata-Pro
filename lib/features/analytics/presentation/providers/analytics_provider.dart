import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:khataplus/features/dashboard/data/models/transaction_model.dart';

class AnalyticsData {
  final List<double> weeklyRevenue;
  final List<double> weeklyExpense;
  final double netProfit;
  final double cashFlow;

  AnalyticsData({
    required this.weeklyRevenue,
    required this.weeklyExpense,
    required this.netProfit,
    required this.cashFlow,
  });
}

final analyticsDataProvider = Provider<AnalyticsData?>((ref) {
  final stats = ref.watch(dashboardStatsProvider).value;
  if (stats == null) return null;

  // Real calculation logic based on last 7 days
  final now = DateTime.now();
  List<double> revenue = List.filled(7, 0.0);
  List<double> expense = List.filled(7, 0.0);

  for (var tx in stats.recentTransactions) {
    final difference = now.difference(tx.date).inDays;
    if (difference < 7) {
      int index = 6 - difference;
      if (index >= 0 && index < 7) {
        if (tx.type == TransactionType.credit) {
          revenue[index] += tx.amount;
        } else {
          expense[index] += tx.amount;
        }
      }
    }
  }

  double totalRev = revenue.reduce((a, b) => a + b);
  double totalExp = expense.reduce((a, b) => a + b);

  return AnalyticsData(
    weeklyRevenue: revenue,
    weeklyExpense: expense,
    netProfit: totalRev - totalExp,
    cashFlow: totalRev + totalExp,
  );
});
