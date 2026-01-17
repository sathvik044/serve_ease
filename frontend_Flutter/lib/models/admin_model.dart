import 'package:cloud_firestore/cloud_firestore.dart';

class AdminModel {
  final String adminId;
  final String username;
  final String email;
  final String password;
  final String role;

  AdminModel({
    required this.adminId,
    required this.username,
    required this.email,
    required this.password,
    this.role = 'admin',
  });

  Map<String, dynamic> toMap() {
    return {
      'admin_id': adminId,
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      adminId: map['admin_id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'admin',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminModel && other.adminId == adminId;
  }

  @override
  int get hashCode => adminId.hashCode;
}