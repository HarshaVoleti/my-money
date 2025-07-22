import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_money/core/enums/label_enums.dart';

enum AccountType {
  bank('bank'),
  wallet('wallet'),
  cash('cash'),
  creditCard('credit_card'),
  debitCard('debit_card');

  const AccountType(this.value);
  final String value;

  static AccountType fromString(String value) {
    return AccountType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => AccountType.bank,
    );
  }
}

enum AccountStatus {
  active('active'),
  inactive('inactive'),
  closed('closed');

  const AccountStatus(this.value);
  final String value;

  static AccountStatus fromString(String value) {
    return AccountStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => AccountStatus.active,
    );
  }
}

class BankAccountModel {
  final String id;
  final String userId;
  final String name;
  final String bankName;
  final String accountNumber;
  final AccountType type;
  final AccountStatus status;
  final double balance;
  final String? ifscCode;
  final String? branchName;
  final String? description;
  final String? iconUrl;
  final LabelColor color;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BankAccountModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.bankName,
    required this.accountNumber,
    required this.type,
    required this.status,
    required this.balance,
    this.ifscCode,
    this.branchName,
    this.description,
    this.iconUrl,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'type': type.value,
      'status': status.value,
      'balance': balance,
      'ifscCode': ifscCode,
      'branchName': branchName,
      'description': description,
      'iconUrl': iconUrl,
      'color': color.name,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BankAccountModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BankAccountModel(
      id: doc.id,
      userId: data['userId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      bankName: data['bankName']?.toString() ?? '',
      accountNumber: data['accountNumber']?.toString() ?? '',
      type: AccountType.fromString(data['type']?.toString() ?? 'bank'),
      status: AccountStatus.fromString(data['status']?.toString() ?? 'active'),
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      ifscCode: data['ifscCode']?.toString(),
      branchName: data['branchName']?.toString(),
      description: data['description']?.toString(),
      iconUrl: data['iconUrl']?.toString(),
      color: LabelColor.fromString(data['color']?.toString() ?? 'blue'),
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(data['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  factory BankAccountModel.fromMap(Map<String, dynamic> data) {
    return BankAccountModel(
      id: data['id']?.toString() ?? '',
      userId: data['userId']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      bankName: data['bankName']?.toString() ?? '',
      accountNumber: data['accountNumber']?.toString() ?? '',
      type: AccountType.fromString(data['type']?.toString() ?? 'bank'),
      status: AccountStatus.fromString(data['status']?.toString() ?? 'active'),
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      ifscCode: data['ifscCode']?.toString(),
      branchName: data['branchName']?.toString(),
      description: data['description']?.toString(),
      iconUrl: data['iconUrl']?.toString(),
      color: LabelColor.fromString(data['color']?.toString() ?? 'blue'),
      isDefault: data['isDefault'] as bool? ?? false,
      createdAt: DateTime.parse(data['createdAt']?.toString() ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(data['updatedAt']?.toString() ?? DateTime.now().toIso8601String()),
    );
  }

  BankAccountModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? bankName,
    String? accountNumber,
    AccountType? type,
    AccountStatus? status,
    double? balance,
    String? ifscCode,
    String? branchName,
    String? description,
    String? iconUrl,
    LabelColor? color,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankAccountModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      type: type ?? this.type,
      status: status ?? this.status,
      balance: balance ?? this.balance,
      ifscCode: ifscCode ?? this.ifscCode,
      branchName: branchName ?? this.branchName,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName {
    return '$name - $bankName';
  }

  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '*' * (accountNumber.length - 4) + accountNumber.substring(accountNumber.length - 4);
  }

  @override
  String toString() {
    return 'BankAccountModel(id: $id, name: $name, bankName: $bankName, type: $type, balance: $balance)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BankAccountModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
