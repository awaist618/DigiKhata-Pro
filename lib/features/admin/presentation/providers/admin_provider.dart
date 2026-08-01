import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/admin_stats.dart';
import '../../data/repositories/admin_repository.dart';
import '../../../core/services/supabase_service.dart';
import '../../../profile/data/models/user_model.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final client = ref.watch(supabaseServiceProvider).client;
  return AdminRepository(client);
});

final adminStatsProvider = FutureProvider<AdminStats>((ref) async {
  return await ref.watch(adminRepositoryProvider).getDashboardStats();
});

final adminUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  return await ref.watch(adminRepositoryProvider).getUsers();
});

final adminBusinessesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await ref.watch(adminRepositoryProvider).getBusinesses();
});

class AdminActionsNotifier extends StateNotifier<AsyncValue<void>> {
  final AdminRepository _repository;
  final Ref _ref;

  AdminActionsNotifier(this._repository, this._ref) : super(const AsyncValue.data(null));

  Future<void> toggleUserBlock(String userId, bool isBlocked) async {
    state = const AsyncValue.loading();
    try {
      await _repository.updateBlockStatus(userId, isBlocked);
      _ref.invalidate(adminUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteUser(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteUser(userId);
      _ref.invalidate(adminUsersProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final adminActionsProvider = StateNotifierProvider<AdminActionsNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(adminRepositoryProvider);
  return AdminActionsNotifier(repository, ref);
});
