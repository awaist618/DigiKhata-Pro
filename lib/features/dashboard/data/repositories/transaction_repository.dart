import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:khataplus/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'dart:convert';
import '../../data/models/transaction_model.dart';
import '../../../notifications/data/models/notification_model.dart';
import '../../../notifications/data/repositories/notification_repository.dart';

import 'package:easy_localization/easy_localization.dart';

class TransactionRepository {
  final SupabaseClient _client;
  final AppDatabase _db;
  final NotificationRepository _notificationRepo;

  TransactionRepository(this._client, this._db, this._notificationRepo);

  Stream<List<TransactionModel>> watchPartyTransactions(String partyId, bool isCustomer) {
    final query = _db.select(_db.transactions)
      ..where((t) => isCustomer ? t.customerId.equals(partyId) : t.supplierId.equals(partyId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)]);

    return query.watch().map((rows) => rows.map((t) => TransactionModel(
          id: t.id,
          businessId: t.businessId,
          customerId: t.customerId,
          supplierId: t.supplierId,
          amount: t.amount,
          description: t.description,
          type: t.type == 'credit' ? TransactionType.credit : TransactionType.debit,
          date: t.createdAt,
          imageUrl: t.imageUrl,
          localImagePath: t.localImagePath,
          notes: t.notes,
          tag: t.tag,
        )).toList());
  }

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
      localImagePath: Value(updatedTx.localImagePath),
      notes: Value(updatedTx.notes),
      tag: Value(updatedTx.tag),
    ));

    // 2. Add professional notification
    await _notificationRepo.addNotification(NotificationModel(
      title: updatedTx.type == TransactionType.credit ? 'cash_in_recorded'.tr() : 'cash_out_recorded'.tr(),
      body: updatedTx.type == TransactionType.credit 
          ? 'received_amount'.tr(args: [updatedTx.amount.toString(), updatedTx.description ?? "Transaction"])
          : 'paid_amount'.tr(args: [updatedTx.amount.toString(), updatedTx.description ?? "Transaction"]),
      type: updatedTx.type == TransactionType.credit ? NotificationType.success : NotificationType.payment,
      createdAt: DateTime.now(),
    ));

    // 3. Add to sync queue
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
      localImagePath: Value(newTx.localImagePath),
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
          final data = jsonDecode(item.data);
          if (item.action == 'insert' || item.action == 'update') {
            // Filter out local-only fields
            final cloudData = Map<String, dynamic>.from(data);
            cloudData.remove('local_image_path');
            
            await _client.from(item.localTable).upsert(cloudData);
            
            if (item.localTable == 'transactions' && item.action == 'insert') {
              final factor = data['type'] == 'credit' ? 1 : -1;
              final amount = (data['amount'] as num).toDouble() * factor;
              
              if (data['customer_id'] != null) {
                await _client.rpc('update_customer_balance', params: {
                  'c_id': data['customer_id'],
                  'amount_change': amount,
                });
              } else if (data['supplier_id'] != null) {
                await _client.rpc('update_supplier_balance', params: {
                  's_id': data['supplier_id'],
                  'amount_change': amount,
                });
              }
            }
          } else if (item.action == 'delete') {
            await _client.from(item.localTable).delete().eq('id', item.recordId);
          }
          await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(item.id))).go();
        } catch (e) {
          debugPrint('Immediate sync failed for ${item.id}: $e');
          break;
        }
      }
    } catch (_) {}
  }
}
