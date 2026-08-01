import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';

class SyncService {
  final SupabaseClient _client;
  final AppDatabase _db;

  SyncService(this._client, this._db);

  Future<int> syncPendingChanges() async {
    int successCount = 0;
    try {
      final pending = await _db.select(_db.syncQueue).get();
      if (pending.isEmpty) return 0;

      for (var item in pending) {
        try {
          final data = jsonDecode(item.data);
          
          if (item.action == 'insert' || item.action == 'update') {
            await _client.from(item.localTable).upsert(data);
            
            // Special handling for transaction balances on server
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

          // Remove from local queue after successful cloud update
          await (_db.delete(_db.syncQueue)..where((t) => t.id.equals(item.id))).go();
          successCount++;
        } catch (e) {
          debugPrint('Sync failed for item ${item.id}: $e');
          // If network error, stop processing queue
          break; 
        }
      }
    } catch (e) {
      debugPrint('SyncService Error: $e');
    }
    return successCount;
  }
}
