import 'package:flutter/material.dart';
import 'package:serve_ease_new/screens/admin/admin_customers_screen.dart';
class AdminDashboardModel {
  final int totalProviders;
  final int pendingProviders;
  final int totalCustomers;
  final int totalBookings;

  AdminDashboardModel({
    required this.totalProviders,
    required this.pendingProviders,
    required this.totalCustomers,
    required this.totalBookings,
  });

  Map<String, dynamic> toMap() {
    return {
      'totalProviders': totalProviders,
      'pendingProviders': pendingProviders,
      'totalCustomers': totalCustomers,
      'totalBookings': totalBookings,
    };
  }

  factory AdminDashboardModel.fromMap(Map<String, dynamic> map) {
    return AdminDashboardModel(
      totalProviders: map['totalProviders'] ?? 0,
      pendingProviders: map['pendingProviders'] ?? 0,
      totalCustomers: map['totalCustomers'] ?? 0,
      totalBookings: map['totalBookings'] ?? 0,
    );
  }
}