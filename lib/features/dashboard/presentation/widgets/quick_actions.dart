import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';

import 'package:khataplus/core/utils/navigation_utils.dart';
import 'package:khataplus/features/customer/presentation/screens/add_edit_customer_screen.dart';

import 'package:khataplus/features/dashboard/presentation/screens/add_transaction_screen.dart';
import 'package:khataplus/features/supplier/presentation/screens/supplier_list_screen.dart';
import 'package:khataplus/features/reports/presentation/screens/reports_screen.dart';
import '../../data/models/transaction_model.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildActionItem(
            context,
            'Add Customer',
            Icons.person_add_outlined,
            AppColors.primaryBlue,
            () => NavigationUtils.push(context, const AddEditCustomerScreen()),
          ),
          _buildActionItem(
            context,
            'Suppliers',
            Icons.inventory_2_outlined,
            AppColors.amberGold,
            () => NavigationUtils.push(context, const SupplierListScreen()),
          ),
          _buildActionItem(
            context,
            'Cash In',
            Icons.add_circle_outline,
            AppColors.success,
            () => NavigationUtils.push(context, const AddTransactionScreen(type: TransactionType.credit)),
          ),
          _buildActionItem(
            context,
            'Cash Out',
            Icons.remove_circle_outline,
            AppColors.danger,
            () => NavigationUtils.push(context, const AddTransactionScreen(type: TransactionType.debit)),
          ),
          _buildActionItem(
            context,
            'Reports',
            Icons.assessment_outlined,
            AppColors.primaryBlue,
            () => NavigationUtils.push(context, const ReportsScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: color.withValues(alpha: 0.05)),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
