import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/core/database/app_database.dart';
import 'package:drift/drift.dart';
import '../models/business_model.dart';

class LinkedBusinessRepository {
  final SupabaseClient _client;
  final AppDatabase _db;

  LinkedBusinessRepository(this._client, this._db);

  Future<BusinessModel?> fetchBusinessById(String businessId) async {
    try {
      final response = await _client
          .from('businesses')
          .select()
          .eq('id', businessId)
          .single();
      
      return BusinessModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<void> linkBusiness(BusinessModel business) async {
    await _db.into(_db.linkedBusinesses).insertOnConflictUpdate(LinkedBusinessesCompanion.insert(
      id: business.id,
      name: business.name,
      type: Value(business.type),
      phone: Value(business.phone),
      linkedAt: DateTime.now(),
    ));

    // Optional: Sync this link to Supabase under a 'linked_businesses' table
    // For now, keeping it local as a "Bookmark" feature
  }

  Future<List<LinkedBusiness>> getLinkedBusinesses() async {
    return await _db.select(_db.linkedBusinesses).get();
  }
}
