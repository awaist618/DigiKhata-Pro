import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import '../providers/customer_provider.dart';
import 'add_edit_customer_screen.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/features/ledger/presentation/screens/party_ledger_screen.dart';

import 'package:easy_localization/easy_localization.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final settings = ref.watch(settingsProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Search customers...',
                  hintStyle: TextStyle(color: isDarkMode ? Colors.white60 : AppColors.textSecondary),
                  border: InputBorder.none,
                ),
                onChanged: (val) => ref.read(customersProvider.notifier).searchCustomers(val),
              )
            : Text(
                'Customers',
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
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(customersProvider.notifier).loadCustomers();
                }
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (val) => ref.read(customersProvider.notifier).sortCustomers(val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'balance', child: Text('Sort by Balance')),
              const PopupMenuItem(value: 'recent', child: Text('Sort by Recent')),
            ],
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
                  Icon(Icons.people_outline, size: 80, color: (isDarkMode ? Colors.white : AppColors.textSecondary).withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No customers yet',
                    style: GoogleFonts.inter(color: isDarkMode ? Colors.white70 : AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => NavigationUtils.push(context, const AddEditCustomerScreen()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
              return Dismissible(
                key: Key(customer.id),
                direction: DismissDirection.horizontal,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.star, color: Colors.white),
                ),
                secondaryBackground: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    ref.read(customersProvider.notifier).toggleFavorite(customer.id, !customer.isFavorite);
                    return false;
                  } else {
                    return await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
                        title: Text('Delete Customer', style: TextStyle(color: isDarkMode ? Colors.white : AppColors.textPrimary)),
                        content: Text('Are you sure you want to delete this customer?', style: TextStyle(color: isDarkMode ? Colors.white70 : AppColors.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    );
                  }
                },
                onDismissed: (direction) {
                  if (direction == DismissDirection.endToStart) {
                    ref.read(customersProvider.notifier).deleteCustomer(customer.id);
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      leading: Stack(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: customer.photoUrl == null
                                ? Center(
                                    child: Text(
                                      customer.name[0].toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.network(
                                      customer.photoUrl!, 
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Center(
                                        child: Text(
                                          customer.name[0].toUpperCase(),
                                          style: GoogleFonts.poppins(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          if (customer.isFavorite)
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? AppColors.logoNavyBottom : Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                                ),
                                child: const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        customer.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.phone_outlined, size: 12, color: isDarkMode ? Colors.white70 : AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                customer.phone,
                                style: GoogleFonts.inter(
                                  color: isDarkMode ? Colors.white70 : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${settings.currency} ${customer.balance.abs().toStringAsFixed(0)}',
                                style: GoogleFonts.robotoMono(
                                  fontWeight: FontWeight.w800,
                                  color: customer.balance >= 0 ? AppColors.success : AppColors.danger,
                                  fontSize: 18,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (customer.balance >= 0 ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              customer.balance >= 0 ? 'you_get'.tr() : 'you_give'.tr(),
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: customer.balance >= 0 ? AppColors.success : AppColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        NavigationUtils.push(
                          context,
                          PartyLedgerScreen(
                            partyId: customer.id,
                            partyName: customer.name,
                            partyPhone: customer.phone,
                            isCustomer: true,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_customer_fab',
        onPressed: () => NavigationUtils.push(context, const AddEditCustomerScreen()),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
