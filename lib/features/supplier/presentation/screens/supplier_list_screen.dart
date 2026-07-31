import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import '../providers/supplier_provider.dart';
import 'add_edit_supplier_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/providers/settings_provider.dart';
import 'package:khataplus/features/ledger/presentation/screens/party_ledger_screen.dart';

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  bool _isSearching = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersProvider);
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search suppliers...',
                  border: InputBorder.none,
                ),
                onChanged: (val) => ref.read(suppliersProvider.notifier).searchSuppliers(val),
              )
            : Text(
                'Suppliers',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(suppliersProvider.notifier).loadSuppliers();
                }
              });
            },
          ),
        ],
      ),
      body: suppliersAsync.when(
        data: (suppliers) {
          if (suppliers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No suppliers yet',
                    style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => NavigationUtils.push(context, const AddEditSupplierScreen()),
                    child: const Text('Add Your First Supplier'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              return Dismissible(
                key: Key(supplier.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Supplier'),
                      content: const Text('Are you sure you want to delete this supplier?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: AppColors.danger)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) {
                  ref.read(suppliersProvider.notifier).deleteSupplier(supplier.id);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
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
                      leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: supplier.photoUrl == null
                          ? Center(
                              child: Text(
                                supplier.name[0].toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(supplier.photoUrl!, fit: BoxFit.cover),
                            ),
                    ),
                    title: Text(
                      supplier.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            supplier.phone,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${settings.currency} ${supplier.balance.abs().toStringAsFixed(0)}',
                          style: GoogleFonts.robotoMono(
                            fontWeight: FontWeight.w800,
                            color: supplier.balance >= 0 ? AppColors.success : AppColors.danger,
                            fontSize: 18,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (supplier.balance >= 0 ? AppColors.success : AppColors.danger).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            supplier.balance >= 0 ? 'YOU GET' : 'YOU GIVE',
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: supplier.balance >= 0 ? AppColors.success : AppColors.danger,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      NavigationUtils.push(
                        context,
                        PartyLedgerScreen(
                          partyId: supplier.id,
                          partyName: supplier.name,
                          isCustomer: false,
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
        heroTag: 'add_supplier_fab',
        onPressed: () => NavigationUtils.push(context, const AddEditSupplierScreen()),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
