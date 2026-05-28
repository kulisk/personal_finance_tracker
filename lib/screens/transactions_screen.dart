// Transaction list with filters and totals.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../stores/finance_store.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_tile.dart';
import 'transaction_detail_screen.dart';

// Sorting options for transaction lists.
enum DateSortOrder { newestFirst, oldestFirst }

// Displays transactions with filters and summary totals.
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  // Active filter and sort state.
  TransactionType? _filterType;
  DateSortOrder _sortOrder = DateSortOrder.newestFirst;

  @override
  Widget build(BuildContext context) {
    // Rebuild when the store changes.
    return Consumer<FinanceStore>(
      builder: (context, store, _) {
        // Apply filters and compute totals.
        final filtered = _applyFilters(store.transactions);
        final totals = _buildTotals(store);

        if (store.transactions.isEmpty) {
          return const EmptyState(
            icon: Icons.list_alt,
            title: 'No transactions yet',
            message: 'Add your first income or expense to get started.',
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            // Summary totals row.
            totals,
            // Filter controls.
            _buildFilters(context),
            const SizedBox(height: 8),
            if (filtered.isEmpty)
              const EmptyState(
                icon: Icons.filter_alt_outlined,
                title: 'No matches',
                message: 'Try adjusting the filters to see transactions.',
              )
            else
              ...filtered.map(
                (transaction) => Card(
                  child: TransactionTile(
                    transaction: transaction,
                    account: store.accountById(transaction.accountId),
                    onTap: () => _openDetails(context, transaction),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Filters and sorts transactions by the current UI state.
  List<FinanceTransaction> _applyFilters(
    List<FinanceTransaction> transactions,
  ) {
    final filtered =
        _filterType == null
            ? [...transactions]
            : transactions
                .where((transaction) => transaction.type == _filterType)
                .toList();

    filtered.sort((a, b) {
      if (_sortOrder == DateSortOrder.newestFirst) {
        return b.date.compareTo(a.date);
      }
      return a.date.compareTo(b.date);
    });

    return filtered;
  }

  // Builds filter dropdowns for type and sort order.
  Widget _buildFilters(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<TransactionType?>(
              decoration: const InputDecoration(labelText: 'Type'),
              value: _filterType,
              items: const [
                DropdownMenuItem<TransactionType?>(
                  value: null,
                  child: Text('All'),
                ),
                DropdownMenuItem<TransactionType?>(
                  value: TransactionType.income,
                  child: Text('Income'),
                ),
                DropdownMenuItem<TransactionType?>(
                  value: TransactionType.expense,
                  child: Text('Expense'),
                ),
              ],
              onChanged: (value) => setState(() => _filterType = value),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButtonFormField<DateSortOrder>(
              decoration: const InputDecoration(labelText: 'Sort'),
              value: _sortOrder,
              items: const [
                DropdownMenuItem(
                  value: DateSortOrder.newestFirst,
                  child: Text('Newest first'),
                ),
                DropdownMenuItem(
                  value: DateSortOrder.oldestFirst,
                  child: Text('Oldest first'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _sortOrder = value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Summary cards for total income and expense.
  Widget _buildTotals(FinanceStore store) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _TotalCard(
              label: 'Income',
              value: formatCurrency(store.totalIncome),
              color: const Color(0xFF1B8D5E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _TotalCard(
              label: 'Expense',
              value: formatCurrency(store.totalExpense),
              color: const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }

  // Opens the transaction detail view.
  void _openDetails(BuildContext context, FinanceTransaction transaction) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TransactionDetailScreen(transactionId: transaction.id),
      ),
    );
  }
}

// Card used in the totals row.
class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 6),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
