import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/services/supabase_service.dart';
import 'package:khataplus/features/notifications/data/models/notification_model.dart';
import 'package:khataplus/features/notifications/data/repositories/notification_repository.dart';
import 'dart:io' show Platform;

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final SupabaseService _supabase;
  final NotificationRepository _repository;

  NotificationService(this._supabase, this._repository);

  Future<void> initialize() async {
    // 1. Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
      
      // 2. Get device token (APNS for iOS, FCM for Android)
      String? token;
      if (Platform.isIOS) {
        token = await _fcm.getAPNSToken();
      } else {
        token = await _fcm.getToken();
      }

      if (token != null) {
        await _saveTokenToSupabase(token);
      }

      // 3. Listen for token refresh
      _fcm.onTokenRefresh.listen(_saveTokenToSupabase);

      // 4. Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        _processRemoteMessage(message);
      });

      // 5. Listen for Supabase Broadcasts (Realtime)
      _listenToSupabaseBroadcasts();
    }
  }

  void _listenToSupabaseBroadcasts() {
    try {
      _supabase.client
          .from('broadcasts')
          .stream(primaryKey: ['id'])
          .order('sent_at')
          .listen((List<Map<String, dynamic>> data) {
        if (data.isNotEmpty) {
          final lastBroadcast = data.last;
          final sentAt = DateTime.parse(lastBroadcast['sent_at']);
          
          if (DateTime.now().difference(sentAt).inSeconds < 10) {
            _repository.addNotification(NotificationModel(
              title: lastBroadcast['title'] ?? 'Announcement',
              body: lastBroadcast['body'] ?? '',
              type: NotificationType.info,
              createdAt: sentAt,
            ));
          }
        }
      }, onError: (error) {
        debugPrint('Supabase Realtime Error: $error');
      });
    } catch (e) {
      debugPrint('Failed to initialize Realtime listener: $e');
    }
  }

  void _processRemoteMessage(RemoteMessage message) {
    if (message.notification != null) {
      _repository.addNotification(NotificationModel(
        title: message.notification?.title ?? 'Notification',
        body: message.notification?.body ?? '',
        type: NotificationType.info,
        createdAt: DateTime.now(),
      ));
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
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationService(supabase, repository);
});
