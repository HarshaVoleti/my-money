import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_money/core/enums/label_enums.dart';

class LabelModel {
  const LabelModel({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.userId,
    required this.createdAt,
    this.icon,
    this.description,
    this.updatedAt,
    this.isActive = true,
  });

  factory LabelModel.fromMap(Map<String, dynamic> map) => LabelModel(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        type: LabelType.fromString(map['type'] as String? ?? ''),
        color: LabelColor.fromString(map['color'] as String? ?? ''),
        userId: map['userId'] as String? ?? '',
        icon: map['icon'] as String?,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: map['updatedAt'] != null 
            ? DateTime.parse(map['updatedAt'] as String) 
            : null,
        isActive: map['isActive'] as bool? ?? true,
      );

  factory LabelModel.fromDocument(DocumentSnapshot doc) => 
      LabelModel.fromMap(doc.data()! as Map<String, dynamic>);

  final String id;
  final String name;
  final LabelType type;
  final LabelColor color;
  final String userId;
  final String? icon;
  final String? description;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Color get colorValue => Color(color.colorValue);

  IconData get iconData {
    if (icon == null) return _getDefaultIcon();
    
    // Map string icon names to IconData
    switch (icon) {
      case 'work':
        return Icons.work;
      case 'home':
        return Icons.home;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.local_hospital;
      case 'education':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_bag;
      case 'travel':
        return Icons.flight;
      case 'investment':
        return Icons.trending_up;
      case 'savings':
        return Icons.savings;
      case 'gift':
        return Icons.card_giftcard;
      case 'bills':
        return Icons.receipt;
      case 'insurance':
        return Icons.security;
      case 'taxes':
        return Icons.account_balance;
      default:
        return _getDefaultIcon();
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case LabelType.income:
        return Icons.trending_up;
      case LabelType.expense:
        return Icons.trending_down;
      case LabelType.investment:
        return Icons.show_chart;
      case LabelType.other:
        return Icons.label;
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.value,
        'color': color.name,
        'userId': userId,
        'icon': icon,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isActive': isActive,
      };

  LabelModel copyWith({
    String? id,
    String? name,
    LabelType? type,
    LabelColor? color,
    String? userId,
    String? icon,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) => LabelModel(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        color: color ?? this.color,
        userId: userId ?? this.userId,
        icon: icon ?? this.icon,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isActive: isActive ?? this.isActive,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LabelModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'LabelModel{id: $id, name: $name, type: ${type.value}}';
}
