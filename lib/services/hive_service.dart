import 'package:hive_flutter/hive_flutter.dart';

import '../models/account.dart';
import '../models/enums.dart';
import '../models/finance_transaction.dart';

class HiveService {
  static late final Box<Account> _accountsBox;
  static late final Box<FinanceTransaction> _transactionsBox;
  static late final Box<int> _settingsBox;

  static Box<Account> get accountsBox => _accountsBox;
  static Box<FinanceTransaction> get transactionsBox => _transactionsBox;
  static Box<int> get settingsBox => _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(FinanceTransactionAdapter());

    _accountsBox = await Hive.openBox<Account>('accounts');
    _transactionsBox = await Hive.openBox<FinanceTransaction>('transactions');
    _settingsBox = await Hive.openBox<int>('settings');
  }
}
