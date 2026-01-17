import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class ProviderService {
  static const String baseUrl = 'https://serveeaseserver-production.up.railway.app/api';

  static Future<Map<String, dynamic>> getProviderProfile(String providerId) async {
    final response = await http.get(Uri.parse('$baseUrl/service-providers/$providerId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load provider profile');
  }

  static Future<List<Map<String, dynamic>>> getProviderBookings(String providerId) async {
    final response = await http.get(Uri.parse('$baseUrl/bookings/provider/$providerId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load bookings');
  }

  static Future<void> updateBookingStatus(String bookingId, String status) async {
    final response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId/provider-approval'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': status}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update booking status');
    }
  }

  static Future<List<Map<String, dynamic>>> getProviderReviews(String providerId) async {
    final response = await http.get(Uri.parse('$baseUrl/reviews/provider/$providerId'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    throw Exception('Failed to load reviews');
  }
}