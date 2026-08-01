import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
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
            final Map<String, dynamic> cloudData = Map.from(data);
            
            // Handle Offline Image Upload
            if (item.localTable == 'transactions' && cloudData['local_image_path'] != null && cloudData['image_url'] == null) {
              final File file = File(cloudData['local_image_path']);
              if (await file.exists()) {
                try {
                  final fileName = 'tx_${DateTime.now().millisecondsSinceEpoch}.jpg';
                  final businessId = cloudData['business_id'];
                  final path = 'transactions/$businessId/$fileName';
                  
                  await _client.storage.from('transactions').upload(path, file);
                  final publicUrl = _client.storage.from('transactions').getPublicUrl(path);
                  
                  // Update cloudData with the new URL
                  cloudData['image_url'] = publicUrl;
                  
                  // Also update local DB so we don't try to upload again
                  await (_db.update(_db.transactions)..where((t) => t.id.equals(item.recordId)))
                      .write(TransactionsCompanion(imageUrl: Value(publicUrl)));
                } catch (storageErr) {
                  debugPrint('Storage upload failed, will retry: $storageErr');
                  // We continue with the DB sync even if image fails, it will retry next time
                }
              }
            }

            // Remove local-only fields that don't exist in Supabase schema (unless you added the column)
            cloudData.remove('local_image_path'); 
            
            await _client.from(item.localTable).upsert(cloudData);
            
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
          debugPrint('Sync failed for item ${item.id} (${item.localTable}): $e');
          // skip this item and continue with the rest of the queue
          continue;
        }
      }
    } catch (e) {
      debugPrint('SyncService Error: $e');
    }
    return successCount;
  }
}
