import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String customerId;
  final String providerId;
  final String serviceType;
  final String status; // PENDING, ACCEPTED, REJECTED, COMPLETED
  final DateTime createdAt;
  final String customerName;
  final String providerName;

  Booking({
    required this.id,
    required this.customerId,
    required this.providerId,
    required this.serviceType,
    required this.status,
    required this.createdAt,
    required this.customerName,
    required this.providerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      'providerId': providerId,
      'serviceType': serviceType,
      'status': status,
      'createdAt': createdAt,
      'customerName': customerName,
      'providerName': providerName,
    };
  }
}