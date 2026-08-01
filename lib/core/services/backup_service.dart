import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../database/app_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

class BackupService {
  final AppDatabase _db;

  BackupService(this._db);

  Future<String?> createBackup() async {
    try {
      // Use raw SQL to get data to avoid dependency on generated classes during build
      final businesses = await _db.customSelect('SELECT * FROM businesses').get();
      final customers = await _db.customSelect('SELECT * FROM customers').get();
      final suppliers = await _db.customSelect('SELECT * FROM suppliers').get();
      final transactions = await _db.customSelect('SELECT * FROM transactions').get();

      final backupData = {
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'businesses': businesses.map((e) => e.data).toList(),
        'customers': customers.map((e) => e.data).toList(),
        'suppliers': suppliers.map((e) => e.data).toList(),
        'transactions': transactions.map((e) => e.data).toList(),
      };

      final jsonString = jsonEncode(backupData);
      
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory(p.join(directory.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final fileName = 'backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File(p.join(backupDir.path, fileName));
      await file.writeAsString(jsonString);

      return file.path;
    } catch (e) {
      debugPrint('Backup Error: $e');
      return null;
    }
  }

  Future<bool> restoreBackup(File file) async {
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      
      if (data['version'] != 1) throw 'Unsupported backup version';

      await _db.transaction(() async {
        // Clear existing data safely using raw SQL
        await _db.customStatement('DELETE FROM transactions');
        await _db.customStatement('DELETE FROM customers');
        await _db.customStatement('DELETE FROM suppliers');
        await _db.customStatement('DELETE FROM businesses');

        // Restore using raw SQL inserts
        for (var map in data['businesses']) {
          await _db.customStatement(
            'INSERT INTO businesses (id, owner_id, name, type, phone, address, currency, low_balance_threshold, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [map['id'], map['owner_id'], map['name'], map['type'], map['phone'], map['address'], map['currency'], map['low_balance_threshold'], map['created_at']]
          );
        }
        for (var map in data['customers']) {
          await _db.customStatement(
            'INSERT INTO customers (id, business_id, name, phone, email, address, notes, photo_url, balance, is_favorite, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [map['id'], map['business_id'], map['name'], map['phone'], map['email'], map['address'], map['notes'], map['photo_url'], map['balance'], map['is_favorite'] ? 1 : 0, map['created_at']]
          );
        }
        for (var map in data['suppliers']) {
          await _db.customStatement(
            'INSERT INTO suppliers (id, business_id, name, phone, email, address, notes, photo_url, balance, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [map['id'], map['business_id'], map['name'], map['phone'], map['email'], map['address'], map['notes'], map['photo_url'], map['balance'], map['created_at']]
          );
        }
        for (var map in data['transactions']) {
          await _db.customStatement(
            'INSERT INTO transactions (id, business_id, customer_id, supplier_id, amount, description, type, created_at, image_url, local_image_path, notes, tag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [map['id'], map['business_id'], map['customer_id'], map['supplier_id'], map['amount'], map['description'], map['type'], map['created_at'], map['image_url'], map['local_image_path'], map['notes'], map['tag']]
          );
        }
      });

      return true;
    } catch (e) {
      debugPrint('Restore Error: $e');
      return false;
    }
  }

  Future<List<File>> getBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(directory.path, 'backups'));
    if (!await backupDir.exists()) return [];

    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((file) => p.basename(file.path).startsWith('backup_') && p.extension(file.path) == '.json')
        .toList();
        
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    return files;
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return BackupService(db);
});
