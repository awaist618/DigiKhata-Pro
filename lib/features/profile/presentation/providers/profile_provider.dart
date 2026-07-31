import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> pickAndUploadAvatar() async {
    if (_userId == null) return;
    
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (image != null) {
      state = const AsyncValue.loading();
      try {
        final bytes = await image.readAsBytes();
        final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final url = await _repository.uploadAvatar(_userId!, bytes, fileName);
        await _repository.updateAvatarUrl(_userId!, url);
        
        final currentUser = state.value;
        if (currentUser != null) {
          state = AsyncValue.data(currentUser.copyWith(avatarUrl: url));
        } else {
          await loadProfile();
        }
      } catch (e, st) {
        state = AsyncValue.error(e, st);
      }
    }
  }
}
