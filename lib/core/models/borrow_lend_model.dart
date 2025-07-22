import 'package:cloud_firestore/cloud_firestore.dart';

class BorrowLendModel {

  BorrowLendModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.personName,
    required this.description,
    required this.date,
    required this.status,
    required this.reminderDates,
    required this.createdAt,
    this.personContact,
    this.dueDate,
    this.returnedAmount,
    this.returnedDate,
    this.updatedAt,
  });

  factory BorrowLendModel.fromMap(Map<String, dynamic> map) => 
      BorrowLendModel(
        id: map['id'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        type: map['type'] as String? ?? '',
        personName: map['personName'] as String? ?? '',
        personContact: map['personContact'] as String?,
        description: map['description'] as String? ?? '',
        date: DateTime.parse(map['date'] as String),
        dueDate: map['dueDate'] != null 
            ? DateTime.parse(map['dueDate'] as String) 
            : null,
        status: map['status'] as String? ?? '',
        returnedAmount: (map['returnedAmount'] as num?)?.toDouble(),
        returnedDate: map['returnedDate'] != null
            ? DateTime.parse(map['returnedDate'] as String)
            : null,
        reminderDates: 
            List<String>.from(map['reminderDates'] as List<dynamic>? ?? []),
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null 
            ? DateTime.parse(map['updatedAt'] as String) 
            : null,
      );

  factory BorrowLendModel.fromDocument(DocumentSnapshot doc) => 
      BorrowLendModel.fromMap(doc.data()! as Map<String, dynamic>);
  final String id;
  final String userId;
  final double amount;
  final String type; // borrowed or lent
  final String personName;
  final String? personContact;
  final String description;
  final DateTime date;
  final DateTime? dueDate;
  final String status; // pending, completed, overdue
  final double? returnedAmount;
  final DateTime? returnedDate;
  final List<String> reminderDates;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Calculated properties
  double get pendingAmount => amount - (returnedAmount ?? 0.0);
  bool get isOverdue =>
      dueDate != null &&
      DateTime.now().isAfter(dueDate!) &&
      status == 'pending';

  Map<String, dynamic> toMap() => {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'personName': personName,
      'personContact': personContact,
      'description': description,
      'date': date.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'status': status,
      'returnedAmount': returnedAmount,
      'returnedDate': returnedDate?.toIso8601String(),
      'reminderDates': reminderDates,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

  BorrowLendModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? type,
    String? personName,
    String? personContact,
    String? description,
    DateTime? date,
    DateTime? dueDate,
    String? status,
    double? returnedAmount,
    DateTime? returnedDate,
    List<String>? reminderDates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BorrowLendModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      personName: personName ?? this.personName,
      personContact: personContact ?? this.personContact,
      description: description ?? this.description,
      date: date ?? this.date,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      returnedAmount: returnedAmount ?? this.returnedAmount,
      returnedDate: returnedDate ?? this.returnedDate,
      reminderDates: reminderDates ?? this.reminderDates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
}
