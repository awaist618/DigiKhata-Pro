import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<AuthResponse> verifyOTP({
    required String email, 
    required String token,
    OtpType type = OtpType.signup,
  }) async {
    return await _client.auth.verifyOTP(
      email: email, 
      token: token,
      type: type,
    );
  }

  Future<AuthResponse> verifyPhoneOTP({
    required String phone, 
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  Future<AuthResponse> signInWithGoogle() async {
    try {
      final googleClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'];
      if (googleClientId == null || googleClientId.isEmpty) {
        throw 'Google Client ID not found in environment variables';
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: googleClientId,
      );
      
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw 'Sign in aborted by user';

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'No ID Token found.';

      // 2. Sign in to Supabase with the ID Token
      return await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}
  }

  Future<void> resetPassword(String email, {String? redirectTo}) async {
    await _client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  Future<void> resetPasswordViaPhone(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  User? get currentUser => _client.auth.currentUser;

  Session? get currentSession => _client.auth.currentSession;
}

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService();
});
