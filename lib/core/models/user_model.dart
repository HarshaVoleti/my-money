import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt, this.phoneNumber,
    this.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      name: map['name'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null 
          ? DateTime.parse(map['updatedAt'] as String) 
          : null,
    );

  factory UserModel.fromDocument(DocumentSnapshot doc) => 
      UserModel.fromMap(doc.data()! as Map<String, dynamic>);
  final String id;
  final String email;
  final String name;
  final String? phoneNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() => {
      'id': id,
      'email': email,
      'name': name,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phoneNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
}
