import 'package:hive/hive.dart';

enum TransactionType { income, expense }

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

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 2;

  @override
  TransactionType read(BinaryReader reader) {
    return TransactionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    writer.writeByte(obj.index);
  }
}

class CategoryTypeAdapter extends TypeAdapter<CategoryType> {
  @override
  final int typeId = 3;

  @override
  CategoryType read(BinaryReader reader) {
    return CategoryType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CategoryType obj) {
    writer.writeByte(obj.index);
  }
}
