// Detailed view for a single transaction.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../stores/finance_store.dart';
import '../utils/category_meta.dart';
import '../utils/formatters.dart';
import 'transaction_form_screen.dart';

// Shows all details for a single transaction.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  Widget build(BuildContext context) {
    // Listen to transaction updates.
    return Consumer<FinanceStore>(
      builder: (context, store, _) {
        final transaction = store.transactionById(transactionId);
        if (transaction == null) {
          return const Scaffold(
            body: Center(child: Text('Transaction not found.')),
          );
        }

        final account = store.accountById(transaction.accountId);
        final meta = metaFor(transaction.category);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Transaction details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              TransactionFormScreen(transaction: transaction),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, store, transaction),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Photo header or placeholder.
              _buildPhoto(transaction, meta),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _DetailRow(
                        label: 'Amount',
                        value: formatCurrency(transaction.amount),
                      ),
                      _DetailRow(label: 'Type', value: transaction.type.label),
                      _DetailRow(label: 'Category', value: meta.label),
                      _DetailRow(
                        label: 'Date',
                        value: formatDate(transaction.date),
                      ),
                      _DetailRow(
                        label: 'Account',
                        value: account?.name ?? 'None',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Renders the attached photo if present.
  Widget _buildPhoto(FinanceTransaction transaction, CategoryMeta meta) {
    if (transaction.photoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          File(transaction.photoPath!),
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackImage(meta),
        ),
      );
    }

    return _fallbackImage(meta);
  }

  // Placeholder image using category styling.
  Widget _fallbackImage(CategoryMeta meta) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: meta.color.withAlpha(38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Icon(meta.icon, size: 64, color: meta.color)),
    );
  }

  // Confirms and deletes the transaction.
  Future<void> _confirmDelete(
    BuildContext context,
    FinanceStore store,
    FinanceTransaction transaction,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete transaction'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await store.deleteTransaction(transaction);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
