enum LabelType {
  income('income'),
  expense('expense'),
  investment('investment'),
  other('other');

  const LabelType(this.value);
  final String value;

  static LabelType fromString(String value) {
    return LabelType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => LabelType.other,
    );
  }
}

enum TransactionType {
  income('income'),
  expense('expense'),
  investment('investment'),
  transfer('transfer');

  const TransactionType(this.value);
  final String value;

  static TransactionType fromString(String value) {
    return TransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => TransactionType.expense,
    );
  }

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.investment:
        return 'Investment';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }
}

enum LabelColor {
  red('red', 0xFFE53E3E),
  orange('orange', 0xFFFF8A00),
  yellow('yellow', 0xFFD69E2E),
  green('green', 0xFF38A169),
  teal('teal', 0xFF319795),
  blue('blue', 0xFF3182CE),
  cyan('cyan', 0xFF00B5D8),
  purple('purple', 0xFF805AD5),
  pink('pink', 0xFFD53F8C),
  gray('gray', 0xFF718096);

  const LabelColor(this.name, this.colorValue);
  final String name;
  final int colorValue;

  static LabelColor fromString(String name) {
    return LabelColor.values.firstWhere(
      (color) => color.name == name,
      orElse: () => LabelColor.blue,
    );
  }
}
