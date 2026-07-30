import 'package:flutter/material.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/balance_card.dart';
import 'widgets/summary_cards.dart';
import 'widgets/quick_actions.dart';
import 'widgets/transaction_chart.dart';
import 'widgets/recent_transactions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const DashboardHeader(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const BalanceCard(),
                  const SizedBox(height: 16),
                  const SummaryCards(),
                  const SizedBox(height: 24),
                  const QuickActions(),
                  const SizedBox(height: 24),
                  const TransactionChart(),
                  const SizedBox(height: 24),
                  const RecentTransactions(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
