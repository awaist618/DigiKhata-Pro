import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // Authentication
  Future<AuthResponse> signIn({required String email, required String password}) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp({required String email, required String password, Map<String, dynamic>? data}) async {
    return await _client.auth.signUp(email: email, password: password, data: data);
  }

  Future<AuthResponse> verifyOTP({required String email, required String token}) async {
    return await _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.signup,
    );
  }

  Future<AuthResponse> signInWithGoogle() async {
    throw 'Google Sign-In is temporarily disabled. Please use Email Sign-Up.';
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
