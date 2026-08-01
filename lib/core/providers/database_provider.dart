import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/sync_service.dart';
import '../services/supabase_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final client = ref.watch(supabaseServiceProvider).client;
  final db = ref.watch(databaseProvider);
  return SyncService(client, db);
});
