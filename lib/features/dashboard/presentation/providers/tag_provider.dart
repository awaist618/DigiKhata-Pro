import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:khataplus/core/database/app_database.dart';
import 'package:khataplus/core/providers/database_provider.dart';
import 'package:khataplus/features/business/presentation/providers/business_provider.dart';

final tagsProvider = FutureProvider<List<dynamic>>((ref) async {
  final db = ref.watch(databaseProvider);
  final businessId = ref.watch(selectedBusinessIdProvider);
  if (businessId == null) return [];
  return db.getTags(businessId);
});

final tagActionProvider = Provider((ref) => TagActionNotifier(ref));

class TagActionNotifier {
  final Ref _ref;
  TagActionNotifier(this._ref);

  Future<void> addTag(String name, String? color) async {
    final db = _ref.read(databaseProvider);
    final businessId = _ref.read(selectedBusinessIdProvider);
    if (businessId == null) return;

    await db.addTagRaw(businessId, name, color);
    _ref.invalidate(tagsProvider);
  }

  Future<void> deleteTag(int id) async {
    final db = _ref.read(databaseProvider);
    await db.deleteTag(id);
    _ref.invalidate(tagsProvider);
  }
}
