import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'package:khataplus/core/providers/database_provider.dart';
import '../../data/models/supplier_model.dart';
import '../../data/repositories/supplier_repository.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:khataplus/core/services/supabase_service.dart';

// ... (other imports)

final supplierRepositoryProvider = Provider<SupplierRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final database = ref.watch(databaseProvider);
  return SupplierRepository(supabase.client, database);
});

final suppliersProvider = StateNotifierProvider<SupplierNotifier, AsyncValue<List<SupplierModel>>>((ref) {
  final repository = ref.watch(supplierRepositoryProvider);
  final businessId = ref.watch(selectedBusinessIdProvider);
  return SupplierNotifier(repository, businessId);
});

class SupplierNotifier extends StateNotifier<AsyncValue<List<SupplierModel>>> {
  final SupplierRepository _repository;
  final String? _businessId;
  StreamSubscription? _subscription;

  SupplierNotifier(this._repository, this._businessId) : super(const AsyncValue.loading()) {
    if (_businessId != null) {
      _listenToSuppliers();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  void _listenToSuppliers() {
    _subscription?.cancel();
    _subscription = _repository.watchSuppliers(_businessId!).listen(
      (suppliers) => state = AsyncValue.data(suppliers),
      onError: (e, st) => state = AsyncValue.error(e, st),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> loadSuppliers() async {
    if (_businessId != null && _subscription == null) {
      _listenToSuppliers();
    }
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    try {
      await _repository.addSupplier(supplier);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    try {
      await _repository.updateSupplier(supplier);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await _repository.deleteSupplier(id);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void searchSuppliers(String query) {
    if (query.isEmpty) {
      _listenToSuppliers();
      return;
    }

    final currentList = state.value;
    if (currentList == null) return;
    
    state = AsyncValue.data(
      currentList.where((s) => 
        s.name.toLowerCase().contains(query.toLowerCase()) || 
        s.phone.contains(query)
      ).toList()
    );
  }
}

