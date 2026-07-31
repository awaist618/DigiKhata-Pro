import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import '../providers/customer_provider.dart';
import 'add_edit_customer_screen.dart';

class CustomerListScreen extends ConsumerWidget {
  const CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Customers',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
        ],
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No customers yet',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => NavigationUtils.push(context, const AddEditCustomerScreen()),
                    child: const Text('Add Your First Customer'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                    backgroundImage: customer.photoUrl != null ? NetworkImage(customer.photoUrl!) : null,
                    child: customer.photoUrl == null
                        ? Text(
                            customer.name[0].toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                          )
                        : null,
                  ),
                  title: Text(
                    customer.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    customer.phone,
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹ ${customer.balance.abs().toStringAsFixed(0)}',
                        style: GoogleFonts.robotoMono(
                          fontWeight: FontWeight.bold,
                          color: customer.balance >= 0 ? AppColors.success : AppColors.danger,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        customer.balance >= 0 ? 'You Get' : 'You Give',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          color: customer.balance >= 0 ? AppColors.success : AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to Customer Details
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => NavigationUtils.push(context, const AddEditCustomerScreen()),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
