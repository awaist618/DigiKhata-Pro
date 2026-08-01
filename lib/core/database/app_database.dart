import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

class Businesses extends Table {
  TextColumn get id => text()();
  TextColumn get ownerId => text()();
  TextColumn get name => text()();
  TextColumn get type => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('PKR'))();
  RealColumn get lowBalanceThreshold => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TransactionTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()(); // Hex color
}

class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  RealColumn get balance => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get businessId => text().references(Businesses, #id)();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  TextColumn get type => text()(); // credit, debit
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get localImagePath => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tag => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get localTable => text()();
  TextColumn get action => text()(); // insert, update, delete
  TextColumn get recordId => text()();
  TextColumn get data => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime()();
}

class LocalNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get type => text()(); // payment, info, success, announcement
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
}

@DataClassName('LinkedBusiness')
class LinkedBusinesses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text().nullable()();
  TextColumn get phone => text().nullable()();
  DateTimeColumn get linkedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Businesses, Customers, Suppliers, Transactions, SyncQueue, LinkedBusinesses, LocalNotifications, TransactionTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.createTable(localNotifications);
        }
        if (from < 3) {
          await customStatement('CREATE TABLE IF NOT EXISTS transaction_tags (id INTEGER PRIMARY KEY AUTOINCREMENT, business_id TEXT NOT NULL, name TEXT NOT NULL, color TEXT)');
        }
      },
    );
  }

  // Transaction Tags Helpers
  Future<List<dynamic>> getTags(String businessId) async {
    // Use raw query to avoid dependency on generated code during build phase
    final results = await customSelect(
      'SELECT * FROM transaction_tags WHERE business_id = ?',
      variables: [Variable.withString(businessId)],
    ).get();
    return results;
  }

  Future<void> addTagRaw(String businessId, String name, String? color) async {
    await customStatement(
      'INSERT INTO transaction_tags (business_id, name, color) VALUES (?, ?, ?)',
      [businessId, name, color],
    );
  }

  Future<bool> deleteTag(int id) async {
    final count = await customUpdate(
      'DELETE FROM transaction_tags WHERE id = ?',
      variables: [Variable.withInt(id)],
    );
    return count > 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
