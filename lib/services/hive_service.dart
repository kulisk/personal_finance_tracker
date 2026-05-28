// Hive initialization and box access helpers.
import 'package:hive_flutter/hive_flutter.dart';

import '../models/account.dart';
import '../models/enums.dart';
import '../models/finance_transaction.dart';

// Wraps Hive setup and provides opened boxes.
class HiveService {
  // Backing boxes (initialized on startup).
  static late final Box<Account> _accountsBox;
  static late final Box<FinanceTransaction> _transactionsBox;
  static late final Box<int> _settingsBox;

  // Public box accessors.
  static Box<Account> get accountsBox => _accountsBox;
  static Box<FinanceTransaction> get transactionsBox => _transactionsBox;
  static Box<int> get settingsBox => _settingsBox;

  // Initializes Hive, registers adapters, and opens boxes.
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register all type adapters used in the app.
    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(FinanceTransactionAdapter());

    // Open boxes for accounts, transactions, and settings.
    _accountsBox = await Hive.openBox<Account>('accounts');
    _transactionsBox = await Hive.openBox<FinanceTransaction>('transactions');
    _settingsBox = await Hive.openBox<int>('settings');
  }
}
