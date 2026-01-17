import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serve_ease_new/screens/customer/customer_bookings_screen.dart';
import 'package:serve_ease_new/screens/customer/service_providers_screen.dart';
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
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF185ADB), Color(0xFF1597BB)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hello!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'What service do you need today?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search for services',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Popular Services',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              children: const [
                ServiceCard(
                  icon: Icons.plumbing,
                  title: 'Plumbing',
                  color: Color(0xFF185ADB),
                ),
                ServiceCard(
                  icon: Icons.electrical_services,
                  title: 'Electrical',
                  color: Color(0xFF185ADB),
                ),
                ServiceCard(
                  icon: Icons.handyman,
                  title: 'Carpentry',
                  color: Color(0xFF185ADB),
                ),
                ServiceCard(
                  icon: Icons.format_paint,
                  title: 'Painting',
                  color: Color(0xFF185ADB),
                ),
                ServiceCard(
                  icon: Icons.cleaning_services,
                  title: 'Cleaning',
                  color: Color(0xFF185ADB),
                ),
                ServiceCard(
                  icon: Icons.yard,
                  title: 'Gardening',
                  color: Color(0xFF185ADB),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF185ADB),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          print('Button pressed: $index');
          
          switch (index) {
            case 1:
              print('Attempting to navigate to bookings screen');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CustomerBookingsScreen(),
                ),
              );
              break;
            default:
              setState(() {
                _selectedIndex = index;
              });
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
}

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        onTap: () async {
          try {
            print('Fetching providers for service: $title');
            final response = await http.get(
              Uri.parse('https://serveeaseserver-production.up.railway.app/api/customers/service-providers/service?service=$title'),
              headers: {'Content-Type': 'application/json'},
            );

            print('Response status code: ${response.statusCode}');
            print('Response body: ${response.body}');

            if (response.statusCode == 200) {
              final providers = json.decode(response.body);
              print('Decoded providers: $providers');
              
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceProvidersScreen(
                      serviceType: title,
                      providers: providers,
                    ),
                  ),
                );
              }
            } else {
              throw Exception('Failed to fetch service providers');
            }
          } catch (e) {
            print('Error: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${e.toString()}')),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
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