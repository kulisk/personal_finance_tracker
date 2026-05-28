// Reusable list tile for account rows.
import 'package:flutter/material.dart';

import '../models/account.dart';
import '../utils/formatters.dart';

// Displays account name and balances in a list tile.
class AccountTile extends StatelessWidget {
  const AccountTile({super.key, required this.account, this.onTap});

  final Account account;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Present account details with a leading icon.
    return ListTile(
      onTap: onTap,
      leading: const CircleAvatar(
        child: Icon(Icons.account_balance_wallet_outlined),
      ),
      title: Text(account.name),
      subtitle: Text('Initial: ${formatCurrency(account.initialBalance)}'),
      trailing: Text(
        formatCurrency(account.balance),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
