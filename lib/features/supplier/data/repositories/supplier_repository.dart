import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supplier_model.dart';

class SupplierRepository {
  final SupabaseClient _client;

  SupplierRepository(this._client);

  Future<List<SupplierModel>> getSuppliers(String businessId) async {
    try {
      final response = await _client
          .from('suppliers')
          .select()
          .eq('business_id', businessId)
          .order('name');
      return (response as List).map((json) => SupplierModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    await _client.from('suppliers').insert(supplier.toJson());
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await _client
        .from('suppliers')
        .update(supplier.toJson())
        .eq('id', supplier.id);
  }

  Future<void> deleteSupplier(String supplierId) async {
    await _client.from('suppliers').delete().eq('id', supplierId);
  }
}
