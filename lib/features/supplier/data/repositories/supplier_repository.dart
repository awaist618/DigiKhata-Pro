import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import '../models/supplier_model.dart';

class SupplierRepository {
  final SupabaseClient _client;
  final AppDatabase _db;

  SupplierRepository(this._client, this._db);

  Future<List<SupplierModel>> getSuppliers(String businessId) async {
    try {
      final localSuppliers = await (_db.select(_db.suppliers)..where((t) => t.businessId.equals(businessId))).get();
      
      if (localSuppliers.isNotEmpty) {
        return localSuppliers.map((s) => SupplierModel(
          id: s.id,
          businessId: s.businessId,
          name: s.name,
          phone: s.phone,
          email: s.email,
          address: s.address,
          notes: s.notes,
          photoUrl: s.photoUrl,
          balance: s.balance,
          createdAt: s.createdAt,
        )).toList();
      }

      final response = await _client
          .from('suppliers')
          .select()
          .eq('business_id', businessId)
          .order('name');
      
      final suppliers = (response as List).map((json) => SupplierModel.fromJson(json)).toList();

      for (var s in suppliers) {
        await _db.into(_db.suppliers).insertOnConflictUpdate(SuppliersCompanion.insert(
          id: s.id,
          businessId: s.businessId,
          name: s.name,
          phone: s.phone,
          email: Value(s.email),
          address: Value(s.address),
          notes: Value(s.notes),
          photoUrl: Value(s.photoUrl),
          balance: Value(s.balance),
          createdAt: s.createdAt,
        ));
      }

      return suppliers;
    } catch (e) {
      return [];
    }
  }

  Future<void> addSupplier(SupplierModel supplier) async {
    final id = supplier.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : supplier.id;
    final updatedSupplier = supplier.copyWith(id: id);

    await _db.into(_db.suppliers).insert(SuppliersCompanion.insert(
      id: id,
      businessId: updatedSupplier.businessId,
      name: updatedSupplier.name,
      phone: updatedSupplier.phone,
      email: Value(updatedSupplier.email),
      address: Value(updatedSupplier.address),
      notes: Value(updatedSupplier.notes),
      photoUrl: Value(updatedSupplier.photoUrl),
      balance: Value(updatedSupplier.balance),
      createdAt: updatedSupplier.createdAt,
    ));

    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'suppliers',
      action: 'insert',
      recordId: id,
      data: jsonEncode(updatedSupplier.toJson()),
      createdAt: DateTime.now(),
    ));

    _trySync();
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await (_db.update(_db.suppliers)..where((t) => t.id.equals(supplier.id))).write(SuppliersCompanion(
      name: Value(supplier.name),
      phone: Value(supplier.phone),
      email: Value(supplier.email),
      address: Value(supplier.address),
      notes: Value(supplier.notes),
      photoUrl: Value(supplier.photoUrl),
    ));

    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'suppliers',
      action: 'update',
      recordId: supplier.id,
      data: jsonEncode(supplier.toJson()),
      createdAt: DateTime.now(),
    ));

    _trySync();
  }

  Future<void> deleteSupplier(String supplierId) async {
    await (_db.delete(_db.suppliers)..where((t) => t.id.equals(supplierId))).go();

    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'suppliers',
      action: 'delete',
      recordId: supplierId,
      data: '{}',
      createdAt: DateTime.now(),
    ));

    _trySync();
  }

  Future<void> _trySync() async {
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
          await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(item.id))).go();
        } catch (e) {
          break;
        }
      }
    } catch (_) {}
  }
}
