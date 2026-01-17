import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerId;  // Changed from uid
  final String name;       // Combined firstName and lastName
  final String email;
  final String phone;
  final String address;    // Changed from Map to String
  final bool isVerified;   // Added
  final String registrationDate;  // Changed from DateTime
  final List<String> bookings;    // Added
  final String role;      // Kept from existing implementation

  CustomerModel({
    required this.customerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.isVerified = false,
    String? registrationDate,
    this.bookings = const [],
    this.role = 'customer',
  }) : this.registrationDate = registrationDate ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'customer_id': customerId,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'isVerified': isVerified,
      'registrationDate': registrationDate,
      'bookings': bookings,
      'role': role,
    };
  }

  factory CustomerModel.fromMap(Map<String, dynamic> map) {
    return CustomerModel(
      customerId: map['customer_id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      isVerified: map['isVerified'] ?? false,
      registrationDate: map['registrationDate'],
      bookings: List<String>.from(map['bookings'] ?? []),
      role: map['role'] ?? 'customer',
    );
  }

  @override
  String toString() {
    return 'CustomerModel{customerId: $customerId, name: $name, email: $email, '
        'phone: $phone, address: $address, isVerified: $isVerified, '
        'registrationDate: $registrationDate, bookings: $bookings, role: $role}';
  }
}