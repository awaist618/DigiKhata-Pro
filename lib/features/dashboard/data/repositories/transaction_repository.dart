import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final SupabaseClient _client;

  TransactionRepository(this._client);

  Future<void> deleteTransaction(TransactionModel tx) async {
    await _client.from('transactions').delete().eq('id', tx.id);
    
    // Reverse balance update
    final factor = tx.type == TransactionType.credit ? -1 : 1;
    final amountChange = tx.amount * factor;

    if (tx.customerId != null) {
      await _client.rpc('update_customer_balance', params: {
        'c_id': tx.customerId,
        'amount_change': amountChange,
      });
    } else if (tx.supplierId != null) {
      await _client.rpc('update_supplier_balance', params: {
        's_id': tx.supplierId,
        'amount_change': amountChange,
      });
    }
  }

  Future<void> updateTransaction(TransactionModel oldTx, TransactionModel newTx) async {
    await _client.from('transactions').update(newTx.toJson()).eq('id', newTx.id);

    // Update balance: Subtract old amount and add new amount
    // For credit: +old, then -old (reverse), then +new
    // For debit: -old, then +old (reverse), then -new
    
    final oldFactor = oldTx.type == TransactionType.credit ? -1 : 1;
    final reverseAmount = oldTx.amount * oldFactor;

    final newFactor = newTx.type == TransactionType.credit ? 1 : -1;
    final applyAmount = newTx.amount * newFactor;

    final totalChange = reverseAmount + applyAmount;

    if (newTx.customerId != null) {
      await _client.rpc('update_customer_balance', params: {
        'c_id': newTx.customerId,
        'amount_change': totalChange,
      });
    } else if (newTx.supplierId != null) {
      await _client.rpc('update_supplier_balance', params: {
        's_id': newTx.supplierId,
        'amount_change': totalChange,
      });
    }
  }
}
