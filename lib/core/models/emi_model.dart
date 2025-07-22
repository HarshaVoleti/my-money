import 'package:cloud_firestore/cloud_firestore.dart';

class EmiModel {

  EmiModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.frequency,
    required this.dayOfMonth,
    required this.totalLoanAmount,
    required this.interestRate,
    required this.status,
    required this.payments,
    required this.reminderEnabled,
    required this.reminderDaysBefore,
    required this.createdAt,
    this.updatedAt,
  });

  factory EmiModel.fromMap(Map<String, dynamic> map) => EmiModel(
      id: map['id'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
      frequency: map['frequency'] as String? ?? '',
      dayOfMonth: (map['dayOfMonth'] as num?)?.toInt() ?? 1,
      totalLoanAmount: (map['totalLoanAmount'] as num?)?.toDouble() ?? 0.0,
      interestRate: (map['interestRate'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? '',
      payments: (map['payments'] as List<dynamic>? ?? [])
          .map<EmiPayment>(
            (payment) => EmiPayment.fromMap(
              payment as Map<String, dynamic>,
            ),
          )
          .toList(),
      reminderEnabled: map['reminderEnabled'] as bool? ?? false,
      reminderDaysBefore: (map['reminderDaysBefore'] as num?)?.toInt() ?? 3,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
    );

  factory EmiModel.fromDocument(DocumentSnapshot doc) => EmiModel.fromMap(
        doc.data()! as Map<String, dynamic>,
      );
  final String id;
  final String userId;
  final String title;
  final String type; // Home Loan, Car Loan, etc.
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final String frequency; // Monthly, Quarterly, etc.
  final int dayOfMonth; // for monthly EMIs
  final double totalLoanAmount;
  final double interestRate;
  final String status; // active, completed, closed
  final List<EmiPayment> payments;
  final bool reminderEnabled;
  final int reminderDaysBefore;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Calculated properties
  double get totalPaid => payments
      .where((payment) => payment.status == 'paid')
      .fold<double>(0, (total, payment) => total + payment.amount);

  double get remainingAmount => totalLoanAmount - totalPaid;

  int get totalInstallments => _calculateTotalInstallments();

  int get paidInstallments =>
      payments.where((payment) => payment.status == 'paid').length;

  int get remainingInstallments => totalInstallments - paidInstallments;

  DateTime? get nextDueDate => _calculateNextDueDate();

  int _calculateTotalInstallments() {
    final months = ((endDate.year - startDate.year) * 12) +
        (endDate.month - startDate.month);
    return frequency == 'Monthly'
        ? months
        : frequency == 'Quarterly'
            ? (months / 3).ceil()
            : frequency == 'Yearly'
                ? (months / 12).ceil()
                : months;
  }

  DateTime? _calculateNextDueDate() {
    final now = DateTime.now();
    final unpaidPayments = payments
        .where((payment) =>
            payment.status == 'pending' && payment.dueDate.isAfter(now),)
        .toList();

    if (unpaidPayments.isEmpty) {
      return null;
    }

    unpaidPayments.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return unpaidPayments.first.dueDate;
  }

  Map<String, dynamic> toMap() => {
      'id': id,
      'userId': userId,
      'title': title,
      'type': type,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'frequency': frequency,
      'dayOfMonth': dayOfMonth,
      'totalLoanAmount': totalLoanAmount,
      'interestRate': interestRate,
      'status': status,
      'payments': payments.map((payment) => payment.toMap()).toList(),
      'reminderEnabled': reminderEnabled,
      'reminderDaysBefore': reminderDaysBefore,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

  EmiModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? type,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? frequency,
    int? dayOfMonth,
    double? totalLoanAmount,
    double? interestRate,
    String? status,
    List<EmiPayment>? payments,
    bool? reminderEnabled,
    int? reminderDaysBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EmiModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      frequency: frequency ?? this.frequency,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      totalLoanAmount: totalLoanAmount ?? this.totalLoanAmount,
      interestRate: interestRate ?? this.interestRate,
      status: status ?? this.status,
      payments: payments ?? this.payments,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderDaysBefore: reminderDaysBefore ?? this.reminderDaysBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
}

class EmiPayment {

  EmiPayment({
    required this.id,
    required this.dueDate,
    required this.amount,
    required this.status,
    this.paidDate,
    this.paidAmount,
  });

  factory EmiPayment.fromMap(Map<String, dynamic> map) => EmiPayment(
      id: map['id'] as String? ?? '',
      dueDate: DateTime.parse(map['dueDate'] as String),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] as String? ?? '',
      paidDate: map['paidDate'] != null 
          ? DateTime.parse(map['paidDate'] as String) 
          : null,
      paidAmount: (map['paidAmount'] as num?)?.toDouble(),
    );
  final String id;
  final DateTime dueDate;
  final double amount;
  final String status; // pending, paid, overdue
  final DateTime? paidDate;
  final double? paidAmount;

  Map<String, dynamic> toMap() => {
      'id': id,
      'dueDate': dueDate.toIso8601String(),
      'amount': amount,
      'status': status,
      'paidDate': paidDate?.toIso8601String(),
      'paidAmount': paidAmount,
    };

  EmiPayment copyWith({
    String? id,
    DateTime? dueDate,
    double? amount,
    String? status,
    DateTime? paidDate,
    double? paidAmount,
  }) => EmiPayment(
      id: id ?? this.id,
      dueDate: dueDate ?? this.dueDate,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      paidDate: paidDate ?? this.paidDate,
      paidAmount: paidAmount ?? this.paidAmount,
    );
}
