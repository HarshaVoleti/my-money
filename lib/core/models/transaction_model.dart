import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_money/core/enums/label_enums.dart';

class TransactionModel {

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.description,
    required this.paymentMethod,
    required this.date, 
    required this.createdAt, 
    this.accountName,
    this.labelIds = const [],
    this.tags = const [],
    this.updatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) => 
      TransactionModel(
        id: map['id'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        type: TransactionType.fromString(map['type'] as String? ?? ''),
        category: map['category'] as String? ?? '',
        description: map['description'] as String? ?? '',
        paymentMethod: map['paymentMethod'] as String? ?? '',
        accountName: map['accountName'] as String?,
        labelIds: List<String>.from(map['labelIds'] as List<dynamic>? ?? []),
        tags: List<String>.from(map['tags'] as List<dynamic>? ?? []),
        date: DateTime.parse(map['date'] as String),
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null 
            ? DateTime.parse(map['updatedAt'] as String) 
            : null,
      );

  factory TransactionModel.fromDocument(DocumentSnapshot doc) => 
      TransactionModel.fromMap(doc.data()! as Map<String, dynamic>);
  
  final String id;
  final String userId;
  final double amount;
  final TransactionType type;
  final String category;
  final String description;
  final String paymentMethod;
  final String? accountName; // bank name or wallet name
  final List<String> labelIds; // References to LabelModel IDs
  final List<String> tags; // Additional text tags
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.value,
      'category': category,
      'description': description,
      'paymentMethod': paymentMethod,
      'accountName': accountName,
      'labelIds': labelIds,
      'tags': tags,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    TransactionType? type,
    String? category,
    String? description,
    String? paymentMethod,
    String? accountName,
    List<String>? labelIds,
    List<String>? tags,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      accountName: accountName ?? this.accountName,
      labelIds: labelIds ?? this.labelIds,
      tags: tags ?? this.tags,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'TransactionModel{id: $id, amount: $amount, type: ${type.value}}';
}
