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

@DriftDatabase(tables: [Businesses, Customers, Suppliers, Transactions, SyncQueue, LinkedBusinesses, LocalNotifications])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          // Add LocalNotifications table if updating from version 1
          await m.createTable(localNotifications);
        }
      },
    );
  }

  // Sync logic helpers will be added here
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
