import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  void _filterCustomers(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCustomers = List.from(_customers);
      } else {
        query = query.toLowerCase();
        _filteredCustomers = _customers.where((customer) {
          final name = (customer['name'] ?? '').toString().toLowerCase();
          final email = (customer['email'] ?? '').toString().toLowerCase();
          final phone = (customer['phone'] ?? '').toString();
          return name.contains(query) || 
                 email.contains(query) || 
                 phone.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _fetchCustomers() async {
    setState(() => _isLoading = true);

    try {
      final response = await http.get(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/customers'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final customers = json.decode(response.body);
        setState(() {
          _customers = customers;
          _filteredCustomers = List.from(customers);
          _isLoading = false;
          _error = '';
        });
      } else {
        throw Exception('Failed to fetch customers');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildCustomerCard(dynamic customer) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          child: const Icon(Icons.person, color: Colors.white),
        ),
        title: Text(customer['name'] ?? 'N/A'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer['email'] ?? 'N/A'),
            Text('Phone: ${customer['phone'] ?? 'N/A'}'),
            Text('Address: ${customer['address'] ?? 'N/A'}'),
            Text('Registration Date: ${DateTime.parse(customer['registrationDate']).toLocal().toString().split('.')[0]}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
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
                        onPressed: _fetchCustomers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name, email or phone',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: _filterCustomers,
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchCustomers,
                        child: ListView.builder(
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) => 
                            _buildCustomerCard(_filteredCustomers[index]),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}