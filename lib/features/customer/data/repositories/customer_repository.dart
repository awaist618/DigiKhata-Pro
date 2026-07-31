import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final SupabaseClient _client;

  CustomerRepository(this._client);

  Future<List<CustomerModel>> getCustomers(String businessId) async {
    final response = await _client
        .from('customers')
        .select()
        .eq('business_id', businessId)
        .order('name');
    return (response as List).map((json) => CustomerModel.fromJson(json)).toList();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    await _client.from('customers').insert(customer.toJson());
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    await _client
        .from('customers')
        .update(customer.toJson())
        .eq('id', customer.id);
  }

  Future<void> deleteCustomer(String customerId) async {
    await _client.from('customers').delete().eq('id', customerId);
  }

  Future<void> toggleFavorite(String customerId, bool isFavorite) async {
    await _client
        .from('customers')
        .update({'is_favorite': isFavorite})
        .eq('id', customerId);
  }
}
