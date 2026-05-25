import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/account.dart';
import '../stores/finance_store.dart';
import '../utils/formatters.dart';
import '../widgets/account_tile.dart';
import '../widgets/empty_state.dart';
import 'account_detail_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceStore>(
      builder: (context, store, _) {
        if (store.accounts.isEmpty) {
          return const EmptyState(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No accounts yet',
            message: 'Create an account to track balances automatically.',
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            ...store.accounts.map(
              (account) => Card(
                child: AccountTile(
                  account: account,
                  onTap: () => _openDetails(context, account),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _openDetails(BuildContext context, Account account) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AccountDetailScreen(accountId: account.id),
      ),
    );
  }
}

Future<void> showAccountFormDialog(
  BuildContext context, {
  Account? account,
}) async {
  final nameController = TextEditingController(text: account?.name ?? '');
  final balanceController = TextEditingController(
    text: account == null ? '' : account.initialBalance.toStringAsFixed(2),
  );
  final formKey = GlobalKey<FormState>();

  final store = context.read<FinanceStore>();

  final saved = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: Text(account == null ? 'New account' : 'Edit account'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Account name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter an account name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: balanceController,
                  enabled: account == null,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText:
                        account == null ? 'Initial balance' : 'Initial balance',
                    helperText:
                        account == null
                            ? 'Set the starting balance.'
                            : 'Locked',
                  ),
                  validator: (value) {
                    if (account != null) {
                      return null;
                    }
                    final parsed = _parseAmount(value);
                    if (parsed == null) {
                      return 'Enter a valid amount.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
  );

  if (saved != true) {
    return;
  }

  if (account == null) {
    final initialBalance = _parseAmount(balanceController.text) ?? 0;
    final newAccount = Account(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      initialBalance: initialBalance,
      balance: initialBalance,
      createdAt: DateTime.now(),
    );
    await store.addAccount(newAccount);
  } else {
    final updated = account.copyWith(name: nameController.text.trim());
    await store.updateAccount(updated);
  }

  if (context.mounted) {
    final info =
        account == null
            ? 'Created ${nameController.text.trim()} with ${formatCurrency(_parseAmount(balanceController.text) ?? 0)}.'
            : 'Updated ${nameController.text.trim()}.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(info)));
  }
}

double? _parseAmount(String? value) {
  if (value == null) {
    return null;
  }
  final normalized = value.replaceAll(',', '.');
  return double.tryParse(normalized);
}
