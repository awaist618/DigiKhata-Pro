import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';
import 'package:khataplus/core/providers/database_provider.dart';
import '../../data/models/customer_model.dart';
import '../../data/repositories/customer_repository.dart';

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final database = ref.watch(databaseProvider);
  return CustomerRepository(supabase.client, database);
});

final customersProvider = StateNotifierProvider<CustomerNotifier, AsyncValue<List<CustomerModel>>>((ref) {
  final repository = ref.watch(customerRepositoryProvider);
  final businessId = ref.watch(selectedBusinessIdProvider);
  return CustomerNotifier(repository, businessId);
});

class CustomerNotifier extends StateNotifier<AsyncValue<List<CustomerModel>>> {
  final CustomerRepository _repository;
  final String? _businessId;

  CustomerNotifier(this._repository, this._businessId) : super(const AsyncValue.loading()) {
    if (_businessId != null) {
      loadCustomers();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadCustomers() async {
    if (_businessId == null) return;
    state = const AsyncValue.loading();
    try {
      final customers = await _repository.getCustomers(_businessId!);
      state = AsyncValue.data(customers);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await _repository.addCustomer(customer);
      await loadCustomers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await _repository.updateCustomer(customer);
      await loadCustomers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _repository.deleteCustomer(id);
      await loadCustomers();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    try {
      await _repository.toggleFavorite(id, isFavorite);
      final currentList = state.value;
      if (currentList != null) {
        state = AsyncValue.data(
          currentList.map((c) => c.id == id ? c.copyWith(isFavorite: isFavorite) : c).toList(),
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void searchCustomers(String query) {
    final currentList = state.value;
    if (currentList == null) return;
    
    if (query.isEmpty) {
      loadCustomers();
      return;
    }

    state = AsyncValue.data(
      currentList.where((c) => 
        c.name.toLowerCase().contains(query.toLowerCase()) || 
        c.phone.contains(query)
      ).toList()
    );
  }

  void sortCustomers(String criteria) {
    final currentList = state.value;
    if (currentList == null) return;

    List<CustomerModel> sortedList = List.from(currentList);
    if (criteria == 'name') {
      sortedList.sort((a, b) => a.name.compareTo(b.name));
    } else if (criteria == 'balance') {
      sortedList.sort((a, b) => b.balance.abs().compareTo(a.balance.abs()));
    } else if (criteria == 'recent') {
      sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    state = AsyncValue.data(sortedList);
  }
}
