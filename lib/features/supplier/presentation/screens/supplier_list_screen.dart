import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:khataplus/core/theme/app_colors.dart';
import 'package:khataplus/core/utils/navigation_utils.dart';
import '../providers/supplier_provider.dart';
import 'add_edit_supplier_screen.dart';

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
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                      backgroundImage: supplier.photoUrl != null ? NetworkImage(supplier.photoUrl!) : null,
                      child: supplier.photoUrl == null
                          ? Text(
                              supplier.name[0].toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                            )
                          : null,
                    ),
                    title: Text(
                      supplier.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      supplier.phone,
                      style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₹ ${supplier.balance.abs().toStringAsFixed(0)}',
                          style: GoogleFonts.robotoMono(
                            fontWeight: FontWeight.bold,
                            color: supplier.balance >= 0 ? AppColors.success : AppColors.danger,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          supplier.balance >= 0 ? 'You Get' : 'You Give',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: supplier.balance >= 0 ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to Supplier Details/Ledger
                    },
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
        onPressed: () => NavigationUtils.push(context, const AddEditSupplierScreen()),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
