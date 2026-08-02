import 'package:khataplus/core/database/app_database.dart';
import 'package:drift/drift.dart';
import '../models/transaction_model.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class DashboardStats {
  final double totalReceivable;
  final double totalPayable;
  final double todayCashIn;
  final double todayCashOut;
  final List<TransactionModel> recentTransactions;

  DashboardStats({
    required this.totalReceivable,
    required this.totalPayable,
    required this.todayCashIn,
    required this.todayCashOut,
    required this.recentTransactions,
  });

  static DashboardStats empty() => DashboardStats(
    totalReceivable: 0,
    totalPayable: 0,
    todayCashIn: 0,
    todayCashOut: 0,
    recentTransactions: [],
  );
}

class DashboardRepository {
  final AppDatabase _db;

  DashboardRepository(this._db);

  Stream<DashboardStats> watchDashboardStats(String businessId) {
    final controller = StreamController<DashboardStats>();

    void update() async {
      try {
        final customers = await (_db.select(_db.customers)..where((t) => t.businessId.equals(businessId))).get();
        final suppliers = await (_db.select(_db.suppliers)..where((t) => t.businessId.equals(businessId))).get();
        final transactions = await (_db.select(_db.transactions)
          ..where((t) => t.businessId.equals(businessId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .get();

        double receivable = 0;
        double payable = 0;

        for (var c in customers) {
          if (c.balance > 0) {
            receivable += c.balance;
          } else if (c.balance < 0) {
            payable += c.balance.abs();
          }
        }

        for (var s in suppliers) {
          if (s.balance > 0) {
            payable += s.balance;
          } else if (s.balance < 0) {
            receivable += s.balance.abs();
          }
        }

        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        
        double cashIn = 0;
        double cashOut = 0;
        
        final recentModels = transactions.map((t) => TransactionModel(
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
        )).toList();

        for (var t in transactions) {
          // Include everything from the start of the current calendar day
          if (t.createdAt.isAtSameMomentAs(startOfToday) || t.createdAt.isAfter(startOfToday)) {
            if (t.type == 'credit') {
              cashIn += t.amount;
            } else {
              cashOut += t.amount;
            }
          }
        }

        if (!controller.isClosed) {
          controller.add(DashboardStats(
            totalReceivable: receivable,
            totalPayable: payable,
            todayCashIn: cashIn,
            todayCashOut: cashOut,
            recentTransactions: recentModels,
          ));
        }
      } catch (e) {
        debugPrint('Dashboard watch error: $e');
      }
    }

    update();

    final cSub = _db.select(_db.customers).watch().listen((_) => update());
    final sSub = _db.select(_db.suppliers).watch().listen((_) => update());
    final tSub = _db.select(_db.transactions).watch().listen((_) => update());

    controller.onCancel = () {
      cSub.cancel();
      sSub.cancel();
      tSub.cancel();
      controller.close();
    };

    return controller.stream;
  }
}
