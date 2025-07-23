import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_money/core/enums/investment_enums.dart';
import 'package:my_money/core/enums/label_enums.dart';

class DepositModel {
  final String id;
  final String name;
  final String description;
  final DepositType type;
  final double principalAmount;
  final double currentValue;
  final double interestRate;
  final DateTime startDate;
  final DateTime maturityDate;
  final int? tenureMonths;
  final int? tenureDays;
  final double? monthlyInstallment; // For RD
  final String bankName;
  final String? accountNumber;
  final String? certificateNumber;
  final DepositStatus status;
  final LabelColor color;
  final bool autoRenewal;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DepositModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.principalAmount,
    required this.currentValue,
    required this.interestRate,
    required this.startDate,
    required this.maturityDate,
    this.tenureMonths,
    this.tenureDays,
    this.monthlyInstallment,
    required this.bankName,
    this.accountNumber,
    this.certificateNumber,
    required this.status,
    required this.color,
    required this.autoRenewal,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  double get expectedMaturityAmount {
    if (type == DepositType.recurringDeposit && monthlyInstallment != null && tenureMonths != null) {
      // Simple RD maturity calculation: M = P * [(1 + r/4)^(4*n) - 1] / (1/4)
      // Simplified for demonstration
      final monthlyRate = interestRate / 100 / 12;
      final amount = monthlyInstallment! * tenureMonths! * 
          (1 + (tenureMonths! + 1) * monthlyRate / 24);
      return amount;
    } else {
      // Simple compound interest for FD
    final P = principalAmount;
    final r = interestRate / 100;
    final t = maturityDate.difference(startDate).inDays / 365.25;
    return P * pow(1 + r, t);
    }
  }

  double get totalInterest => expectedMaturityAmount - principalAmount;

  int get daysToMaturity => maturityDate.difference(DateTime.now()).inDays;

  bool get isMatured => DateTime.now().isAfter(maturityDate);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'principalAmount': principalAmount,
      'currentValue': currentValue,
      'interestRate': interestRate,
      'startDate': startDate.toIso8601String(),
      'maturityDate': maturityDate.toIso8601String(),
      'tenureMonths': tenureMonths,
      'tenureDays': tenureDays,
      'monthlyInstallment': monthlyInstallment,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'certificateNumber': certificateNumber,
      'status': status.name,
      'color': color.name,
      'autoRenewal': autoRenewal,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DepositModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DepositModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      type: DepositType.values.firstWhere(
        (t) => t.name == data['type'],
        orElse: () => DepositType.fixedDeposit,
      ),
      principalAmount: (data['principalAmount'] as num?)?.toDouble() ?? 0.0,
      currentValue: (data['currentValue'] as num?)?.toDouble() ?? 0.0,
      interestRate: (data['interestRate'] as num?)?.toDouble() ?? 0.0,
      startDate: DateTime.parse(
        data['startDate']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      maturityDate: DateTime.parse(
        data['maturityDate']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      tenureMonths: (data['tenureMonths'] as num?)?.toInt(),
      tenureDays: (data['tenureDays'] as num?)?.toInt(),
      monthlyInstallment: (data['monthlyInstallment'] as num?)?.toDouble(),
      bankName: data['bankName']?.toString() ?? '',
      accountNumber: data['accountNumber']?.toString(),
      certificateNumber: data['certificateNumber']?.toString(),
      status: DepositStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => DepositStatus.active,
      ),
      color: LabelColor.values.firstWhere(
        (c) => c.name == data['color'],
        orElse: () => LabelColor.blue,
      ),
      autoRenewal: data['autoRenewal'] as bool? ?? false,
      tags: (data['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(
        data['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        data['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  DepositModel copyWith({
    String? id,
    String? name,
    String? description,
    DepositType? type,
    double? principalAmount,
    double? currentValue,
    double? interestRate,
    DateTime? startDate,
    DateTime? maturityDate,
    int? tenureMonths,
    int? tenureDays,
    double? monthlyInstallment,
    String? bankName,
    String? accountNumber,
    String? certificateNumber,
    DepositStatus? status,
    LabelColor? color,
    bool? autoRenewal,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DepositModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      principalAmount: principalAmount ?? this.principalAmount,
      currentValue: currentValue ?? this.currentValue,
      interestRate: interestRate ?? this.interestRate,
      startDate: startDate ?? this.startDate,
      maturityDate: maturityDate ?? this.maturityDate,
      tenureMonths: tenureMonths ?? this.tenureMonths,
      tenureDays: tenureDays ?? this.tenureDays,
      monthlyInstallment: monthlyInstallment ?? this.monthlyInstallment,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      status: status ?? this.status,
      color: color ?? this.color,
      autoRenewal: autoRenewal ?? this.autoRenewal,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'DepositModel(id: $id, name: $name, type: $type, principalAmount: $principalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DepositModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
