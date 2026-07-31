import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/custom_text_field.dart';
import 'package:khataplus/features/auth/presentation/login/widgets/primary_button.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'package:khataplus/features/customer/presentation/providers/customer_provider.dart';
import '../../data/models/transaction_model.dart';
import '../providers/dashboard_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final TransactionType type;
  const AddTransactionScreen({super.key, required this.type});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedCustomerId;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() async {
    if (_formKey.currentState!.validate() && _selectedCustomerId != null) {
      setState(() => _isLoading = true);
      
      try {
        final businessId = ref.read(selectedBusinessIdProvider);
        if (businessId == null) return;

        // Implementation for adding transaction to Supabase
        // In a real app, you'd have a TransactionRepository
        final supabase = ref.read(supabaseServiceProvider).client;
        
        await supabase.from('transactions').insert({
          'business_id': businessId,
          'customer_id': _selectedCustomerId,
          'amount': double.parse(_amountController.text),
          'description': _descriptionController.text,
          'type': widget.type.name,
          'created_at': DateTime.now().toIso8601String(),
        });

        // Update customer balance (simplified logic)
        final factor = widget.type == TransactionType.credit ? 1 : -1;
        final amount = double.parse(_amountController.text) * factor;
        
        await supabase.rpc('update_customer_balance', params: {
          'c_id': _selectedCustomerId,
          'amount_change': amount,
        });

        ref.refresh(dashboardStatsProvider);
        ref.read(customersProvider.notifier).loadCustomers();

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(customersProvider).value ?? [];
    final isCredit = widget.type == TransactionType.credit;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isCredit ? 'Add Credit (Cash In)' : 'Add Debit (Cash Out)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Customer',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCustomerId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.inputBackground,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
                items: customers.map((c) => DropdownMenuItem(
                  value: c.id,
                  child: Text(c.name),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCustomerId = val),
                validator: (val) => val == null ? 'Please select a customer' : null,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                hintText: 'Amount',
                prefixIcon: Icons.attach_money,
                controller: _amountController,
                keyboardType: TextInputType.number,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                hintText: 'Description (Optional)',
                prefixIcon: Icons.description_outlined,
                controller: _descriptionController,
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Save Transaction',
                      onPressed: _handleSave,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
