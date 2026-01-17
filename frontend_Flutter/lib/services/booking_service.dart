import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookingService {
  static Future<Map<String, dynamic>> createBooking({
    required String providerId,
    required String serviceType,
    required String description,
    required String scheduledDate,
    required String scheduledTime,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/bookings/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'service_provider_id': providerId,
          'service_type': serviceType,
          'description': description,
          'scheduledDate': scheduledDate,
          'scheduledTime': scheduledTime,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Failed to create booking');
      }
    } catch (e) {
      throw Exception('Error creating booking: $e');
    }
  }
}