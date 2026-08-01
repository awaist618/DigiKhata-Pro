import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khataplus/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import '../models/transaction_model.dart';

class TransactionRepository {
  final SupabaseClient _client;
  final AppDatabase _db;

  TransactionRepository(this._client, this._db);

  Future<void> addTransaction(TransactionModel tx) async {
    final id = tx.id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : tx.id;
    final updatedTx = tx.copyWith(id: id);

    // 1. Save locally
    await _db.into(_db.transactions).insert(TransactionsCompanion.insert(
      id: id,
      businessId: updatedTx.businessId,
      customerId: Value(updatedTx.customerId),
      supplierId: Value(updatedTx.supplierId),
      amount: updatedTx.amount,
      description: Value(updatedTx.description),
      type: updatedTx.type.name,
      createdAt: updatedTx.date,
      imageUrl: Value(updatedTx.imageUrl),
      notes: Value(updatedTx.notes),
    ));

    // 2. Add to sync queue
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'transactions',
      action: 'insert',
      recordId: id,
      data: jsonEncode(updatedTx.toJson()),
      createdAt: DateTime.now(),
    ));

    // 3. Update local balance immediately
    final factor = updatedTx.type == TransactionType.credit ? 1 : -1;
    final amountChange = updatedTx.amount * factor;

    if (updatedTx.customerId != null) {
      final customer = await (_db.select(_db.customers)..where((t) => t.id.equals(updatedTx.customerId!))).getSingle();
      await (_db.update(_db.customers)..where((t) => t.id.equals(updatedTx.customerId!)))
          .write(CustomersCompanion(balance: Value(customer.balance + amountChange)));
    } else if (updatedTx.supplierId != null) {
      final supplier = await (_db.select(_db.suppliers)..where((t) => t.id.equals(updatedTx.supplierId!))).getSingle();
      await (_db.update(_db.suppliers)..where((t) => t.id.equals(updatedTx.supplierId!)))
          .write(SuppliersCompanion(balance: Value(supplier.balance + amountChange)));
    }

    _trySync();
  }

  Future<void> deleteTransaction(TransactionModel tx) async {
    // 1. Delete locally
    await (_db.delete(_db.transactions)..where((t) => t.id.equals(tx.id))).go();

    // 2. Sync queue
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'transactions',
      action: 'delete',
      recordId: tx.id,
      data: '{}',
      createdAt: DateTime.now(),
    ));

    // 3. Reverse local balance
    final factor = tx.type == TransactionType.credit ? -1 : 1;
    final amountChange = tx.amount * factor;

    if (tx.customerId != null) {
      final customer = await (_db.select(_db.customers)..where((t) => t.id.equals(tx.customerId!))).getSingle();
      await (_db.update(_db.customers)..where((t) => t.id.equals(tx.customerId!)))
          .write(CustomersCompanion(balance: Value(customer.balance + amountChange)));
    } else if (tx.supplierId != null) {
      final supplier = await (_db.select(_db.suppliers)..where((t) => t.id.equals(tx.supplierId!))).getSingle();
      await (_db.update(_db.suppliers)..where((t) => t.id.equals(tx.supplierId!)))
          .write(SuppliersCompanion(balance: Value(supplier.balance + amountChange)));
    }

    _trySync();
  }

  Future<void> updateTransaction(TransactionModel oldTx, TransactionModel newTx) async {
    // 1. Update locally
    await (_db.update(_db.transactions)..where((t) => t.id.equals(newTx.id))).write(TransactionsCompanion(
      amount: Value(newTx.amount),
      description: Value(newTx.description),
      notes: Value(newTx.notes),
      imageUrl: Value(newTx.imageUrl),
    ));

    // 2. Sync queue
    await _db.into(_db.syncQueue).insert(SyncQueueCompanion.insert(
      localTable: 'transactions',
      action: 'update',
      recordId: newTx.id,
      data: jsonEncode(newTx.toJson()),
      createdAt: DateTime.now(),
    ));

    // 3. Update local balance: Subtract old amount and add new amount
    final oldFactor = oldTx.type == TransactionType.credit ? -1 : 1;
    final reverseAmount = oldTx.amount * oldFactor;

    final newFactor = newTx.type == TransactionType.credit ? 1 : -1;
    final applyAmount = newTx.amount * newFactor;

    final totalChange = reverseAmount + applyAmount;

    if (newTx.customerId != null) {
      final customer = await (_db.select(_db.customers)..where((t) => t.id.equals(newTx.customerId!))).getSingle();
      await (_db.update(_db.customers)..where((t) => t.id.equals(newTx.customerId!)))
          .write(CustomersCompanion(balance: Value(customer.balance + totalChange)));
    } else if (newTx.supplierId != null) {
      final supplier = await (_db.select(_db.suppliers)..where((t) => t.id.equals(newTx.supplierId!))).getSingle();
      await (_db.update(_db.suppliers)..where((t) => t.id.equals(newTx.supplierId!)))
          .write(SuppliersCompanion(balance: Value(supplier.balance + totalChange)));
    }

    _trySync();
  }

  Future<void> _trySync() async {
    try {
      final pending = await _db.select(_db.syncQueue).get();
      for (var item in pending) {
        try {
          if (item.action == 'insert') {
            await _client.from(item.localTable).upsert(jsonDecode(item.data));
            if (item.localTable == 'transactions') {
              final txData = jsonDecode(item.data);
              final factor = txData['type'] == 'credit' ? 1 : -1;
              final amount = (txData['amount'] as num).toDouble() * factor;
              
              if (txData['customer_id'] != null) {
                await _client.rpc('update_customer_balance', params: {
                  'c_id': txData['customer_id'],
                  'amount_change': amount,
                });
              } else if (txData['supplier_id'] != null) {
                await _client.rpc('update_supplier_balance', params: {
                  's_id': txData['supplier_id'],
                  'amount_change': amount,
                });
              }
            }
          } else if (item.action == 'update') {
            await _client.from(item.localTable).update(jsonDecode(item.data)).eq('id', item.recordId);
            // Handle balance updates for transaction updates if necessary on server
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
