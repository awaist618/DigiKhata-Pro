import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.watchNotifications();
});

class NotificationNotifier extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(const AsyncValue.data(null));

  Future<void> deleteNotification(int id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteNotification(id);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
    } catch (_) {}
  }
}

final notificationActionsProvider = StateNotifierProvider<NotificationNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});
