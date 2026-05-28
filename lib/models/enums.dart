// Shared enums and Hive adapters.
import 'package:hive/hive.dart';

// Type of transaction affecting totals.
enum TransactionType { income, expense }

// Categories used for transaction labeling.
enum CategoryType {
  food,
  transport,
  bills,
  entertainment,
  shopping,
  health,
  salary,
  other,
}

// Human-friendly label for transaction type.
extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
    }
  }
}

// Human-friendly label for category type.
extension CategoryTypeX on CategoryType {
  String get label {
    switch (this) {
      case CategoryType.food:
        return 'Food';
      case CategoryType.transport:
        return 'Transport';
      case CategoryType.bills:
        return 'Bills';
      case CategoryType.entertainment:
        return 'Entertainment';
      case CategoryType.shopping:
        return 'Shopping';
      case CategoryType.health:
        return 'Health';
      case CategoryType.salary:
        return 'Salary';
      case CategoryType.other:
        return 'Other';
    }
  }
}

// Hive adapter for TransactionType.
class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 2;

  @override
  TransactionType read(BinaryReader reader) {
    // Restore enum by index.
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    // Persist enum index.
    writer.writeByte(obj.index);
  }
}

// Hive adapter for CategoryType.
class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 3;

  @override
  CategoryType read(BinaryReader reader) {
    // Restore enum by index.
    return CategoryType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    // Persist enum index.
    writer.writeByte(obj.index);
  }
}
