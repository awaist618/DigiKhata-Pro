import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import '../models/customer_model.dart';

class CustomerRepository {
  final SupabaseClient _client;
  final AppDatabase _db;

  CustomerRepository(this._client, this._db);

  Stream<List<CustomerModel>> watchCustomers(String businessId) {
    return (_db.select(_db.customers)..where((t) => t.businessId.equals(businessId))..orderBy([(t) => OrderingTerm(expression: t.name)]))
        .watch()
        .map((rows) => rows.map((c) => CustomerModel(
              id: c.id,
              businessId: c.businessId,
              name: c.name,
              phone: c.phone,
              email: c.email,
              address: c.address,
              notes: c.notes,
              photoUrl: c.photoUrl,
              balance: c.balance,
              isFavorite: c.isFavorite,
              createdAt: c.createdAt,
            )).toList());
  }

  Future<List<CustomerModel>> getCustomers(String businessId) async {
    try {
      // 1. Try to fetch from local database first
      final localCustomers = await (_db.select(_db.customers)..where((t) => t.businessId.equals(businessId))).get();
      
      if (localCustomers.isNotEmpty) {
        return localCustomers.map((c) => CustomerModel(
          id: c.id,
          businessId: c.businessId,
          name: c.name,
          phone: c.phone,
          email: c.email,
          address: c.address,
          notes: c.notes,
          photoUrl: c.photoUrl,
          balance: c.balance,
          isFavorite: c.isFavorite,
          createdAt: c.createdAt,
        )).toList();
      }

      // 2. If local is empty, fetch from Supabase
      final response = await _client
          .from('customers')
          .select()
          .eq('business_id', businessId)
          .order('name');
      
      final customers = (response as List).map((json) => CustomerModel.fromJson(json)).toList();

      // 3. Cache in local database
      for (var c in customers) {
        await _db.into(_db.customers).insertOnConflictUpdate(CustomersCompanion.insert(
          id: c.id,
          businessId: c.businessId,
          name: c.name,
          phone: c.phone,
          email: Value(c.email),
          address: Value(c.address),
          notes: Value(c.notes),
          photoUrl: Value(c.photoUrl),
          balance: Value(c.balance),
          isFavorite: Value(c.isFavorite),
          createdAt: c.createdAt,
        ));
      }

      return customers;
    } catch (e) {
      return [];
    }
  }

  Future<void> addCustomer(CustomerModel customer) async {
    // 1. Generate ID if not present
    final id = customer.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : customer.id;
    final updatedCustomer = customer.copyWith(id: id);

    // 2. Insert locally
    await _db.into(_db.customers).insert(CustomersCompanion.insert(
      id: id,
      businessId: updatedCustomer.businessId,
      name: updatedCustomer.name,
      phone: updatedCustomer.phone,
      email: Value(updatedCustomer.email),
      address: Value(updatedCustomer.address),
      notes: Value(updatedCustomer.notes),
      photoUrl: Value(updatedCustomer.photoUrl),
      balance: Value(updatedCustomer.balance),
      isFavorite: Value(updatedCustomer.isFavorite),
      createdAt: updatedCustomer.createdAt,
    ));

    // 3. Add to sync queue
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'customers',
      action: 'insert',
      recordId: id,
      data: jsonEncode(updatedCustomer.toJson()),
      createdAt: DateTime.now(),
    ));

    // 4. Try to sync immediately (will fail silently if offline)
    _trySync();
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    // 1. Update locally
    await (_db.update(_db.customers)..where((t) => t.id.equals(customer.id))).write(CustomersCompanion(
      name: Value(customer.name),
      phone: Value(customer.phone),
      email: Value(customer.email),
      address: Value(customer.address),
      notes: Value(customer.notes),
      photoUrl: Value(customer.photoUrl),
      isFavorite: Value(customer.isFavorite),
    ));

    // 2. Add to sync queue
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'customers',
      action: 'update',
      recordId: customer.id,
      data: jsonEncode(customer.toJson()),
      createdAt: DateTime.now(),
    ));

    _trySync();
  }

  Future<void> deleteCustomer(String customerId) async {
    // 1. Delete locally
    await (_db.delete(_db.customers)..where((t) => t.id.equals(customerId))).go();

    // 2. Add to sync queue
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'customers',
      action: 'delete',
      recordId: customerId,
      data: '{}',
      createdAt: DateTime.now(),
    ));

    _trySync();
  }

  Future<void> toggleFavorite(String customerId, bool isFavorite) async {
    await (_db.update(_db.customers)..where((t) => t.id.equals(customerId))).write(CustomersCompanion(
      isFavorite: Value(isFavorite),
    ));

    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'customers',
      action: 'update',
      recordId: customerId,
      data: jsonEncode({'is_favorite': isFavorite}),
      createdAt: DateTime.now(),
    ));

    _trySync();
  }

  Future<void> _trySync() async {
    // This is a simple immediate sync trigger. 
    // A more robust solution would be a separate SyncService.
    try {
      final pending = await _db.select(_db.syncQueue).get();
      for (var item in pending) {
        try {
          if (item.action == 'insert') {
            await _client.from(item.localTable).upsert(jsonDecode(item.data));
          } else if (item.action == 'update') {
            await _client.from(item.localTable).update(jsonDecode(item.data)).eq('id', item.recordId);
          } else if (item.action == 'delete') {
            await _client.from(item.localTable).delete().eq('id', item.recordId);
          }
          // Remove from queue if successful
          await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(item.id))).go();
        } catch (e) {
          // If network error, stop syncing
          break;
        }
      }
    } catch (_) {}
  }

  Future<CustomerModel?> fetchCustomerById(String id) async {
    try {
      final response = await _client.from('customers').select().eq('id', id).single();
      return CustomerModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
