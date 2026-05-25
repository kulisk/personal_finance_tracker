import 'package:hive_flutter/hive_flutter.dart';

import '../models/account.dart';
import '../models/enums.dart';
import '../models/finance_transaction.dart';

class HiveService {
  static late final Box<Account> _accountsBox;
  static late final Box<FinanceTransaction> _transactionsBox;

  static Box<Account> get accountsBox => _accountsBox;
  static Box<FinanceTransaction> get transactionsBox => _transactionsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AccountAdapter());
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryTypeAdapter());
    Hive.registerAdapter(FinanceTransactionAdapter());

    _accountsBox = await Hive.openBox<Account>('accounts');
    _transactionsBox = await Hive.openBox<FinanceTransaction>('transactions');
  }
}
