import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import '../../data/models/business_model.dart';
import '../../data/repositories/business_repository.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return BusinessRepository(supabase.client);
});

final selectedBusinessIdProvider = StateProvider<String?>((ref) => null);
final selectedBusinessProvider = StateProvider<BusinessModel?>((ref) => null);

final businessListProvider = StateNotifierProvider<BusinessNotifier, AsyncValue<List<BusinessModel>>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  final userId = ref.watch(supabaseServiceProvider).currentUser?.id;
  return BusinessNotifier(repository, userId);
});

class BusinessNotifier extends StateNotifier<AsyncValue<List<BusinessModel>>> {
  final BusinessRepository _repository;
  final String? _userId;

  BusinessNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadBusinesses();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> loadBusinesses() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final businesses = await _repository.getBusinesses(_userId!);
      state = AsyncValue.data(businesses);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createBusiness(BusinessModel business) async {
    try {
      await _repository.createBusiness(business);
      await loadBusinesses();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final businessNameProvider = Provider<String>((ref) {
  final selected = ref.watch(selectedBusinessProvider);
  return selected?.name ?? 'My Business';
});
