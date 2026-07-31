import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/features/profile/data/models/user_model.dart';

class ProfileRepository {
  final SupabaseClient _client;

  ProfileRepository(this._client);

  Future<UserModel> getProfile(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(response);
  }

  Future<void> updateProfile(UserModel user) async {
    await _client
        .from('profiles')
        .update(user.toJson())
        .eq('id', user.id);
  }

  Future<void> updateAvatar(String userId, String filePath) async {
    // Implementation for uploading to Supabase Storage would go here
    // For now, we'll assume the URL is updated in the profile
  }

  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
