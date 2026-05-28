// Transaction create/edit form with optional photo.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/enums.dart';
import '../models/finance_transaction.dart';
import '../stores/finance_store.dart';
import '../utils/category_meta.dart';
import '../utils/formatters.dart';

// Form screen to add or edit a transaction.
class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.transaction});

  final FinanceTransaction? transaction;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  // Form state and field controllers.
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _picker = ImagePicker();

  // Selected values for the transaction.
  TransactionType _type = TransactionType.expense;
  CategoryType _category = CategoryType.food;
  DateTime _date = DateTime.now();
  String? _accountId;
  String? _photoPath;

  // Convenience flag for edit vs create.
  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    // Seed form values when editing.
    final transaction = widget.transaction;
    if (transaction != null) {
      _titleController.text = transaction.title;
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _type = transaction.type;
      _category = transaction.category;
      _date = transaction.date;
      _accountId = transaction.accountId;
      _photoPath = transaction.photoPath;
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid leaks.
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit transaction' : 'New transaction'),
      ),
      body: Consumer<FinanceStore>(
        builder: (context, store, _) {
          // Validate saved account selection against current accounts.
          final validAccountId =
              _accountId != null && store.accountById(_accountId) != null
                  ? _accountId
                  : null;
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final parsed = _parseAmount(value);
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TransactionType>(
                  value: _type,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      TransactionType.values
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _type = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<CategoryType>(
                  value: _category,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      CategoryType.values
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(metaFor(category).label),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _category = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  value: validAccountId,
                  decoration: const InputDecoration(
                    labelText: 'Account',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...store.accounts.map(
                      (account) => DropdownMenuItem<String?>(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _accountId = value),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickDate(context),
                  icon: const Icon(Icons.event),
                  label: Text('Date: ${formatDate(_date)}'),
                ),
                const SizedBox(height: 16),
                _buildPhotoPicker(),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => _save(context, store),
                  child: Text(_isEditing ? 'Save changes' : 'Add transaction'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Photo picker section with preview and actions.
  Widget _buildPhotoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Photo (optional)', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        if (_photoPath == null)
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Select photo'),
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_photoPath!),
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Replace'),
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _photoPath = null),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  // Date picker for the transaction date.
  Future<void> _pickDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selected != null) {
      setState(() => _date = selected);
    }
  }

  // Image picker for an optional receipt/photo.
  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() => _photoPath = picked.path);
    }
  }

  // Validates and persists the transaction.
  Future<void> _save(BuildContext context, FinanceStore store) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = _parseAmount(_amountController.text)!;
    final now = DateTime.now();
    final resolvedAccountId =
        _accountId != null && store.accountById(_accountId) != null
            ? _accountId
            : null;

    // Update the record or create one.
    if (_isEditing) {
      final original = widget.transaction!;
      final updated = original.copyWith(
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        accountId: resolvedAccountId,
        photoPath: _photoPath,
        clearAccount: resolvedAccountId == null,
        clearPhoto: _photoPath == null,
      );
      await store.updateTransaction(updated: updated, original: original);
    } else {
      final transaction = FinanceTransaction(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        amount: amount,
        type: _type,
        category: _category,
        date: _date,
        accountId: resolvedAccountId,
        photoPath: _photoPath,
        createdAt: now,
      );
      await store.addTransaction(transaction);
    }

    // Exit once saved.
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  // Parses amount input using comma or dot decimal separators.
  double? _parseAmount(String? value) {
    if (value == null) {
      return null;
    }
    final normalized = value.replaceAll(',', '.');
    return double.tryParse(normalized);
  }
}
