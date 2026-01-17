// Update imports - remove Firebase related imports
import 'package:flutter/material.dart';
import 'package:serve_ease_new/utils/app_theme.dart';
import 'package:serve_ease_new/models/service_provider_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serve_ease_new/models/booking_model.dart';
import 'package:serve_ease_new/screens/auth/service_provider_login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceProviderDashboardScreen extends StatefulWidget {
  const ServiceProviderDashboardScreen({super.key});

  @override
  State<ServiceProviderDashboardScreen> createState() => _ServiceProviderDashboardScreenState();
}

class _ServiceProviderDashboardScreenState extends State<ServiceProviderDashboardScreen> {
  ServiceProviderModel? serviceProvider;
  bool _isLoading = true;
  List<BookingModel> bookings = [];
  
  @override
  void initState() {
    super.initState();
    _loadServiceProviderData();
    _fetchBookings();  // Add this line to the existing initState
  }

  // Remove the second initState method that was added
  Future<void> _loadServiceProviderData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/service-providers/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          serviceProvider = ServiceProviderModel.fromJson(data);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      print('Error loading service provider data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Get the token from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/service-providers/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Clear token regardless of response
      await prefs.remove('token');

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ServiceProviderLoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to logout. Please try again.')),
      );
    }
  }

  Future<void> _fetchBookings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final providerId = prefs.getString('providerId');
      final token = prefs.getString('token');

      if (providerId == null) {
        throw Exception('Provider ID not found');
      }

      final response = await http.get(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/bookings/provider/$providerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          bookings = data.map((json) => BookingModel.fromJson(json)).toList();
        });
      } else {
        throw Exception('Failed to fetch bookings');
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load bookings: ${e.toString()}')),
      );
    }
  }

  // Update the booking list UI
  Widget _buildBookingList() {
    return ListView.builder(
      itemCount: bookings.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(booking.serviceType),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(booking.description),
                Text(
                  'Scheduled: ${booking.scheduledDate} at ${booking.scheduledTime}',
                  style: const TextStyle(
                    color: Color(0xFF1E3C72),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Status: ${booking.status}',
                  style: TextStyle(
                    color: _getStatusColor(booking.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Add refresh functionality
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadServiceProviderData(),
      _fetchBookings(),
    ]);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3C72),
        title: const Text('ServeEase Provider', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Color(0xFF1E3C72)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    serviceProvider?.name ?? 'Loading...',
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    serviceProvider?.email ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('My Profile'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & Support'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Welcome section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.business_center,
                        size: 60,
                        color: Color(0xFF1E3C72),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome, ${serviceProvider?.name ?? "Service Provider"}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3C72),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bookings section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Your Bookings',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _buildBookingList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}