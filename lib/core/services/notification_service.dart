import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseService _supabase;

  NotificationService(this._supabase);

  Future<void> initialize() async {
    // 1. Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
      
      // 2. Get device token
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }

      // 3. Listen for token refresh
      _fcm.onTokenRefresh.listen(_saveTokenToSupabase);

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification!.body}');
        }
      });
    }
  }

  Future<void> _saveTokenToSupabase(String token) async {
    final user = _supabase.currentUser;
    if (user != null) {
      try {
        await _supabase.client.from('profiles').update({
          'fcm_token': token,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', user.id);
        debugPrint('FCM Token saved to Supabase');
      } catch (e) {
        debugPrint('Error saving FCM token: $e');
      }
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return NotificationService(supabase);
});
