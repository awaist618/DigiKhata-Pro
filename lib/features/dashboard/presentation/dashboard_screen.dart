import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/widgets/app_logo.dart';
import 'providers/dashboard_provider.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_cards.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transaction_chart.dart';
import 'widgets/recent_transactions.dart';
import 'widgets/banner_slider.dart';

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
                      const BannerSlider(),
                      const SizedBox(height: 24),
                      const QuickActions(),
                      const SizedBox(height: 24),
                      const TransactionChart(),
                      const SizedBox(height: 24),
                      RecentTransactions(transactions: stats.recentTransactions),
                      const SizedBox(height: 32),
                      _buildBranding(isDarkMode),
                      const SizedBox(height: 40),
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

  Widget _buildBranding(bool isDarkMode) {
    return Column(
      children: [
        AppLogo(size: 40, animate: false),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: isDarkMode ? Colors.white38 : Colors.black26,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
            children: [
              const TextSpan(text: 'Powered by '),
              const TextSpan(text: 'Zenvyro Labs '),
              TextSpan(
                text: 'X',
                style: TextStyle(
                  color: AppColors.primaryBlue.withValues(alpha: isDarkMode ? 0.3 : 0.2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const TextSpan(text: ' AWAIS'),
            ],
          ),
        ),
      ],
    );
  }
}
