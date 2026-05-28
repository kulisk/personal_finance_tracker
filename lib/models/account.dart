// Account model and Hive adapter.
import 'package:hive/hive.dart';

// Represents a user account with balance tracking.
class Account {
  Account({
    required this.id,
    required this.name,
    required this.initialBalance,
    required this.balance,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double initialBalance;
  final double balance;
  final DateTime createdAt;

  // Creates a modified copy of the account.
  Account copyWith({
    String? id,
    String? name,
    double? initialBalance,
    double? balance,
    DateTime? createdAt,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

// Hive adapter for persisting accounts.
class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 0;

  @override
  Account read(BinaryReader reader) {
    // Deserialize fields in the same order as written.
    final id = reader.readString();
    final name = reader.readString();
    final initialBalance = reader.readDouble();
    final balance = reader.readDouble();
    final createdAt = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    return Account(
      id: id,
      name: name,
      initialBalance: initialBalance,
      balance: balance,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    // Serialize fields in a stable order.
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeDouble(obj.initialBalance)
      ..writeDouble(obj.balance)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
