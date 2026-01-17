import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String bookingId;
  final String customerId;
  final String serviceProviderId;
  final String serviceType;
  final String description;
  final String status;
  final DateTime bookingDate;
  final String scheduledDate;
  final String scheduledTime;

  BookingModel({
    required this.bookingId,
    required this.customerId,
    required this.serviceProviderId,
    required this.serviceType,
    required this.description,
    required this.status,
    required this.bookingDate,
    required this.scheduledDate,
    required this.scheduledTime,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['booking_id'] ?? '',
      customerId: json['customer_id'] ?? '',
      serviceProviderId: json['service_provider_id'] ?? '',
      serviceType: json['service_type'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'PENDING',
      bookingDate: DateTime.parse(json['bookingDate']),
      scheduledDate: json['scheduledDate'] ?? '',
      scheduledTime: json['scheduledTime'] ?? '',
    );
  }
}