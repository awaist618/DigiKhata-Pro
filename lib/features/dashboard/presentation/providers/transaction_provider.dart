import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';
import 'dashboard_provider.dart';
import 'package:khataplus/features/customer/presentation/providers/customer_provider.dart';
import 'package:khataplus/features/supplier/presentation/providers/supplier_provider.dart';
import 'package:khataplus/core/providers/database_provider.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final database = ref.watch(databaseProvider);
  return TransactionRepository(supabase.client, database);
});

final transactionActionProvider = Provider<TransactionActionNotifier>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionActionNotifier(ref, repository);
});

class TransactionActionNotifier {
  final Ref _ref;
  final TransactionRepository _repository;

  TransactionActionNotifier(this._ref, this._repository);

  Future<void> addTransaction(TransactionModel tx) async {
    try {
      await _repository.addTransaction(tx);
      _refreshAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTransaction(TransactionModel tx) async {
    try {
      await _repository.deleteTransaction(tx);
      _refreshAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTransaction(TransactionModel oldTx, TransactionModel newTx) async {
    try {
      await _repository.updateTransaction(oldTx, newTx);
      _refreshAll();
    } catch (e) {
      rethrow;
    }
  }

  void _refreshAll() {
    _ref.invalidate(dashboardStatsProvider);
    _ref.read(customersProvider.notifier).loadCustomers();
    _ref.read(suppliersProvider.notifier).loadSuppliers();
  }
}
