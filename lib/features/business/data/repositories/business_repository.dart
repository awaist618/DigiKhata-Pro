import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/business_model.dart';

class BusinessRepository {
  final SupabaseClient _client;

  BusinessRepository(this._client);

  Future<List<BusinessModel>> getBusinesses(String userId) async {
    final response = await _client
        .from('businesses')
        .select()
        .eq('owner_id', userId)
        .order('created_at');
    return (response as List).map((json) => BusinessModel.fromJson(json)).toList();
  }

  Future<void> createBusiness(BusinessModel business) async {
    await _client.from('businesses').insert(business.toJson());
  }

  Future<void> updateBusiness(BusinessModel business) async {
    await _client
        .from('businesses')
        .update(business.toJson())
        .eq('id', business.id);
  }

  Future<void> deleteBusiness(String businessId) async {
    await _client.from('businesses').delete().eq('id', businessId);
  }
}
