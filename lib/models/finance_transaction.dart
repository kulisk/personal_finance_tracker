import 'package:hive/hive.dart';

import 'enums.dart';

class FinanceTransaction {
  FinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.createdAt,
    this.accountId,
    this.photoPath,
  });

  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final CategoryType category;
  final DateTime date;
  final DateTime createdAt;
  final String? accountId;
  final String? photoPath;

  FinanceTransaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    CategoryType? category,
    DateTime? date,
    DateTime? createdAt,
    String? accountId,
    String? photoPath,
    bool clearAccount = false,
    bool clearPhoto = false,
  }) {
    return FinanceTransaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      accountId: clearAccount ? null : (accountId ?? this.accountId),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
    );
  }
}

class FinanceTransactionAdapter extends TypeAdapter<FinanceTransaction> {
  @override
  final int typeId = 1;

  @override
  FinanceTransaction read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final amount = reader.readDouble();
    final type = reader.read() as TransactionType;
    final category = reader.read() as CategoryType;
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final hasAccount = reader.readBool();
    final accountId = hasAccount ? reader.readString() : null;
    final hasPhoto = reader.readBool();
    final photoPath = hasPhoto ? reader.readString() : null;
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());

    return FinanceTransaction(
      id: id,
      title: title,
      amount: amount,
      type: type,
      category: category,
      date: date,
      accountId: accountId,
      photoPath: photoPath,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceTransaction obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.title)
      ..writeDouble(obj.amount)
      ..write(obj.type)
      ..write(obj.category)
      ..writeInt(obj.date.millisecondsSinceEpoch)
      ..writeBool(obj.accountId != null);
    if (obj.accountId != null) {
      writer.writeString(obj.accountId!);
    }
    writer.writeBool(obj.photoPath != null);
    if (obj.photoPath != null) {
      writer.writeString(obj.photoPath!);
    }
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
