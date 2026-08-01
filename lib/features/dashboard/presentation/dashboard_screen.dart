import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_cards.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transaction_chart.dart';
import 'widgets/recent_transactions.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardStatsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const DashboardHeader(),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: statsAsync.when(
                  data: (stats) => Column(
                    children: [
                      BalanceCard(stats: stats),
                      const SizedBox(height: 16),
                      SummaryCards(stats: stats),
                      const SizedBox(height: 24),
                      const QuickActions(),
                      const SizedBox(height: 24),
                      const TransactionChart(),
                      const SizedBox(height: 24),
                      RecentTransactions(transactions: stats.recentTransactions),
                      const SizedBox(height: 24),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
