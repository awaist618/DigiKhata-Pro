import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/profile/data/models/user_model.dart';
import 'package:khataplus/features/profile/data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return ProfileRepository(supabase.client);
});

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserModel?>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  final supabase = ref.watch(supabaseServiceProvider);
  return ProfileNotifier(repository, supabase.currentUser?.id);
});

class ProfileNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final ProfileRepository _repository;
  final String? _userId;

  ProfileNotifier(this._repository, this._userId) : super(const AsyncValue.loading()) {
    if (_userId != null) {
      loadProfile();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> loadProfile() async {
    if (_userId == null) return;
    state = const AsyncValue.loading();
    try {
      final user = await _repository.getProfile(_userId!);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile(UserModel user) async {
    try {
      await _repository.updateProfile(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Theme Provider
final themeProvider = StateProvider<bool>((ref) => false); // false for light, true for dark

// Language Provider (if not using easy_localization directly in UI)
final languageProvider = StateProvider<String>((ref) => 'en');
