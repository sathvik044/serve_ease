class Customer {
  final String customerId;
  final String name;
  final String email;
  final String phone;
  final String address;
  final DateTime registrationDate;
  final List<dynamic> bookings;
  final bool verified;

  Customer({
    required this.customerId,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.registrationDate,
    required this.bookings,
    required this.verified,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      customerId: json['customer_id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      registrationDate: DateTime.parse(json['registrationDate']),
      bookings: json['bookings'] ?? [],
      verified: json['verified'] ?? false,
    );
  }
}