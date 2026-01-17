import 'package:flutter/material.dart';
import 'package:serve_ease_new/models/admin_dashboard_model.dart';
import 'package:serve_ease_new/utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';  
import 'package:serve_ease_new/screens/admin/providers_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;  // Add this line
  bool _isLoading = true;
  String _error = '';
  AdminDashboardModel _stats = AdminDashboardModel(
    totalProviders: 0,
    pendingProviders: 0,
    totalCustomers: 0,
    totalBookings: 0,
  );

  Future<void> _fetchDashboardStats() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // Add headers for better request handling
      final headers = {'Content-Type': 'application/json'};
      
      final responses = await Future.wait([
        http.get(   
          Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/service-providers'),
          headers: headers
        ),
        http.get(
          Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/service-providers/pending'),
          headers: headers
        ),
        http.get(
          Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/bookings'),
          headers: headers
        ),
        http.get(
          Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/customers'),
          headers: headers
        ),
      ]).timeout(
        const Duration(seconds: 30),  // Increased timeout
        onTimeout: () {
          throw TimeoutException('Request timed out');
        },
      );

      if (!mounted) return;

      // Detailed error checking
      for (var i = 0; i < responses.length; i++) {
        final response = responses[i];
        if (response.statusCode != 200) {
          print('Error in request ${i + 1}: Status ${response.statusCode}');
          print('Response body: ${response.body}');
          throw Exception('Request ${i + 1} failed with status: ${response.statusCode}');
        }
      }

      setState(() {
        _stats = AdminDashboardModel(
          totalProviders: json.decode(responses[0].body).length,
          pendingProviders: json.decode(responses[1].body).length,
          totalBookings: json.decode(responses[2].body).length,
          totalCustomers: json.decode(responses[3].body).length,
        );
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is TimeoutException 
            ? 'Request timed out. Please try again.'
            : 'Error: ${e.toString()}';
        _isLoading = false;
      });
      print('Dashboard error: $e');  // For debugging
    }
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchDashboardStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF185ADB),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Stack(
              children: [
                Icon(Icons.notifications),
                Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    radius: 8,
                    child: Text(
                      '3',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1E3C72), Color(0xFF2A5298)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings, size: 35, color: Color(0xFF1E3C72)),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Admin Panel',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'Manage your services',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              selected: _selectedIndex == 0,
              onTap: () {
                setState(() => _selectedIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Service Providers'),
              selected: _selectedIndex == 1,
              onTap: () {
                setState(() => _selectedIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book_online),
              title: const Text('Bookings'),
              selected: _selectedIndex == 2,
              onTap: () {
                setState(() => _selectedIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Customers'),
              selected: _selectedIndex == 3,
              onTap: () {
                setState(() => _selectedIndex = 3);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: Implement logout
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchDashboardStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchDashboardStats,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        GridView.count(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildStatCard(
                              title: 'Service Providers',
                              value: _stats.totalProviders,
                              icon: Icons.business,
                              color: Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProvidersScreen(initialTabIndex: 0),
                                  ),
                                );
                              },
                            ),
                            _buildStatCard(
                              title: 'Pending Approvals',
                              value: _stats.pendingProviders,
                              icon: Icons.pending_actions,
                              color: Colors.orange,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProvidersScreen(initialTabIndex: 1),
                                  ),
                                );
                              },
                            ),
                            _buildStatCard(
                              title: 'Total Bookings',
                              value: _stats.totalBookings,
                              icon: Icons.book_online,
                              color: Colors.green,
                            ),
                            _buildStatCard(
                              title: 'Total Customers',
                              value: _stats.totalCustomers,
                              icon: Icons.people,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                       // const SizedBox(height: 20),
                       // TextButton (
                        //  onPressed : (){

                        //  },
                       //  child: const Text('Text Button', style: TextStyle(
                          
                         // fontWeight: FontWeight.bold,
                        // ),
                        // ),
                       // ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Providers',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Customers',
          ),
        ],
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 1) { // Providers tab
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProvidersScreen(),
              ),
            );
          }
          // ... handle other tabs
        },
        // ... rest of the bottom navigation code
      ),
    );
  }
}