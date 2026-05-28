// Reusable list tile for transactions.
import 'package:flutter/material.dart';

import '../models/account.dart';
import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../utils/category_meta.dart';
import '../utils/formatters.dart';

// Displays a transaction with category, date, and amount.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.account,
    this.onTap,
  });

  final FinanceTransaction transaction;
  final Account? account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Derive label and color from category and type.
    final meta = metaFor(transaction.category);
    final isIncome = transaction.type == TransactionType.income;
    final amountColor =
        isIncome ? const Color(0xFF1B8D5E) : const Color(0xFFC62828);
    final amountPrefix = isIncome ? '+' : '-';

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: meta.color.withAlpha(51),
        child: Icon(meta.icon, color: meta.color),
      ),
      title: Text(transaction.title),
      subtitle: Text(
        '${meta.label} · ${formatDate(transaction.date)}'
        '${account != null ? ' · ${account!.name}' : ''}',
      ),
      trailing: Text(
        '$amountPrefix${formatCurrency(transaction.amount)}',
        style: TextStyle(color: amountColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
