import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/account.dart';
import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../services/hive_service.dart';

class FinanceStore extends ChangeNotifier {
  FinanceStore()
    : _accountsBox = HiveService.accountsBox,
      _transactionsBox = HiveService.transactionsBox;

  final Box<Account> _accountsBox;
  final Box<FinanceTransaction> _transactionsBox;

  List<Account> get accounts {
    final items = _accountsBox.values.toList();
    items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return items;
  }

  List<FinanceTransaction> get transactions {
    final items = _transactionsBox.values.toList();
    items.sort((a, b) => b.date.compareTo(a.date));
    return items;
  }

  Account? accountById(String? accountId) {
    if (accountId == null) {
      return null;
    }
    return _accountsBox.get(accountId);
  }

  FinanceTransaction? transactionById(String transactionId) {
    return _transactionsBox.get(transactionId);
  }

  Future<void> addAccount(Account account) async {
    await _accountsBox.put(account.id, account);
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    await _accountsBox.put(account.id, account);
    notifyListeners();
  }

  Future<void> deleteAccount(Account account) async {
    final items =
        transactions
            .where((transaction) => transaction.accountId == account.id)
            .toList();

    for (final transaction in items) {
      final updated = transaction.copyWith(accountId: null);
      await _transactionsBox.put(transaction.id, updated);
    }

    await _accountsBox.delete(account.id);
    notifyListeners();
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);
    await _applyAccountImpact(transaction);
    notifyListeners();
  }

  Future<void> updateTransaction({
    required FinanceTransaction updated,
    required FinanceTransaction original,
  }) async {
    await _transactionsBox.put(updated.id, updated);
    await _revertAccountImpact(original);
    await _applyAccountImpact(updated);
    notifyListeners();
  }

  Future<void> deleteTransaction(FinanceTransaction transaction) async {
    await _transactionsBox.delete(transaction.id);
    await _revertAccountImpact(transaction);
    notifyListeners();
  }

  double get totalIncome {
    return transactions
        .where((transaction) => transaction.type == TransactionType.income)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double get totalExpense {
    return transactions
        .where((transaction) => transaction.type == TransactionType.expense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double signedAmount(FinanceTransaction transaction) {
    return transaction.type == TransactionType.income
        ? transaction.amount
        : -transaction.amount;
  }

  Future<void> _applyAccountImpact(FinanceTransaction transaction) async {
    final accountId = transaction.accountId;
    if (accountId == null) {
      return;
    }

    final account = _accountsBox.get(accountId);
    if (account == null) {
      return;
    }

    final updated = account.copyWith(
      balance: account.balance + signedAmount(transaction),
    );
    await _accountsBox.put(accountId, updated);
  }

  Future<void> _revertAccountImpact(FinanceTransaction transaction) async {
    final accountId = transaction.accountId;
    if (accountId == null) {
      return;
    }

    final account = _accountsBox.get(accountId);
    if (account == null) {
      return;
    }

    final updated = account.copyWith(
      balance: account.balance - signedAmount(transaction),
    );
    await _accountsBox.put(accountId, updated);
  }
}
