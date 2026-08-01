import 'package:khataplus/core/database/app_database.dart';
import 'package:drift/drift.dart';
import '../models/notification_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/providers/database_provider.dart';

class NotificationRepository {
  final AppDatabase _db;

  NotificationRepository(this._db);

  Stream<List<NotificationModel>> watchNotifications() {
    return (_db.select(_db.localNotifications)
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map((row) => NotificationModel(
              id: row.id,
              title: row.title,
              body: row.body,
              type: NotificationType.values.firstWhere(
                (e) => e.name == row.type,
                orElse: () => NotificationType.info,
              ),
              createdAt: row.createdAt,
              isRead: row.isRead,
            )).toList());
  }

  Future<void> addNotification(NotificationModel notification) async {
    await _db.into(_db.localNotifications).insert(LocalNotificationsCompanion.insert(
          title: notification.title,
          body: notification.body,
          type: notification.type.name,
          createdAt: notification.createdAt,
          isRead: Value(notification.isRead),
        ));
  }

  Future<void> deleteNotification(int id) async {
    await (_db.delete(_db.localNotifications)..where((t) => t.id.equals(id))).go();
  }

  Future<void> markAsRead(int id) async {
    await (_db.update(_db.localNotifications)..where((t) => t.id.equals(id)))
        .write(const LocalNotificationsCompanion(isRead: Value(true)));
  }

  Future<void> markAllAsRead() async {
    await (_db.update(_db.localNotifications)).write(const LocalNotificationsCompanion(isRead: Value(true)));
  }
}

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationRepository(db);
});
