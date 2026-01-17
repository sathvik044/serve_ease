import 'package:flutter/material.dart';
import 'package:serve_ease_new/utils/app_theme.dart';
import 'package:serve_ease_new/screens/customer/service_providers_screen.dart';
import 'package:serve_ease_new/screens/customer/customer_profile_screen.dart';
import 'package:serve_ease_new/screens/customer/customer_bookings_screen.dart'; // Add this import
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() => _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ServeEase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.backgroundGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'What service do you need today?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search for services',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Popular Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: 8, // Show all 8 services
                    itemBuilder: (context, index) {
                      return _buildServiceCard(index);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 1: // Bookings tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerBookingsScreen(),
                ),
              );
              break;
            case 2: // Profile tab
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CustomerProfileScreen(),
                ),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(int index) {
    final services = [
      {'name': 'Plumbing', 'icon': Icons.plumbing},
      {'name': 'Electrical', 'icon': Icons.electrical_services},
      {'name': 'Carpentry', 'icon': Icons.handyman},
      {'name': 'Painting', 'icon': Icons.format_paint},
      {'name': 'Cleaning', 'icon': Icons.cleaning_services},
      {'name': 'Gardening', 'icon': Icons.yard},
      {'name': 'Moving', 'icon': Icons.local_shipping},
      {'name': 'Appliance Repair', 'icon': Icons.build},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () async {
          try {
            print('Fetching providers for service: ${services[index]['name']}');
            final response = await http.get(
              Uri.parse('https://serveeaseserver-production.up.railway.app/api/customers/service-providers/service?service=${services[index]['name']}'),
              headers: {'Content-Type': 'application/json'},
            );

            print('Response status code: ${response.statusCode}');
            print('Response body: ${response.body}');

            if (!mounted) return;

            if (response.statusCode == 200) {
              final List<dynamic> providers = json.decode(response.body);
              print('Decoded providers: $providers');
              
              if (providers.isNotEmpty) {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceProvidersScreen(
                        serviceType: services[index]['name'] as String,
                        providers: providers.map((p) => p as Map<String, dynamic>).toList(),
                      ),
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No service providers available')),
                );
              }
            } else {
              throw Exception('Failed to fetch service providers');
            }
          } catch (e) {
            print('Error: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          }
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                services[index]['icon'] as IconData,
                size: 32,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                services[index]['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}