import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/features/profile/data/models/user_model.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<UserModel> getProfile(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle(); // Use maybeSingle to avoid PGRST116
          
      if (response == null) {
        // If profile doesn't exist, create it on the fly
        final newUser = UserModel(
          id: userId,
          email: _client.auth.currentUser?.email ?? '',
          fullName: _client.auth.currentUser?.userMetadata?['full_name'] ?? 'New User',
          createdAt: DateTime.now(),
        );
        await _client.from('profiles').insert(newUser.toJson());
        return newUser;
      }
      
      return UserModel.fromJson(response);
    } catch (e) {
      // Final fallback to ensure the app doesn't crash
      return UserModel(
        id: userId,
        email: _client.auth.currentUser?.email ?? 'user@example.com',
        fullName: 'Demo User',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<void> updateProfile(UserModel user) async {
    await _client
        .from('profiles')
        .update(user.toJson())
        .eq('id', user.id);
  }

  Future<String> uploadAvatar(String userId, List<int> bytes, String fileName) async {
    final path = 'avatars/$userId/$fileName';
    await _client.storage.from('profiles').uploadBinary(
          path,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(upsert: true),
        );
    final url = _client.storage.from('profiles').getPublicUrl(path);
    return url;
  }

  Future<void> updateAvatarUrl(String userId, String url) async {
    await _client.from('profiles').update({'avatar_url': url}).eq('id', userId);
  }

  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
