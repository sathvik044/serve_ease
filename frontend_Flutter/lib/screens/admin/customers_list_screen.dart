import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serve_ease_new/models/customer.dart';
import 'package:intl/intl.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  List<Customer> customers = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    print('Starting to fetch customers...'); // Debug print
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/customers'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}'); // Debug print
      print('Response body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          customers = data.map((json) => Customer.fromJson(json)).toList();
          isLoading = false;
          error = null;
        });
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      print('Error fetching customers: $e'); // Debug print
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Customers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchCustomers,
          ),
        ],
      ),
      body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchCustomers,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : customers.isEmpty
                  ? const Center(
                      child: Text('No customers found'),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchCustomers,
                      child: ListView.builder(
                        itemCount: customers.length,
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: ExpansionTile(
                              title: Text(
                                customer.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(customer.email),
                              leading: CircleAvatar(
                                backgroundColor: customer.verified ? Colors.green : Colors.grey,
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (customer.phone.isNotEmpty)
                                        ListTile(
                                          leading: const Icon(Icons.phone),
                                          title: Text(customer.phone),
                                          dense: true,
                                        ),
                                      if (customer.address.isNotEmpty)
                                        ListTile(
                                          leading: const Icon(Icons.location_on),
                                          title: Text(customer.address),
                                          dense: true,
                                        ),
                                      ListTile(
                                        leading: const Icon(Icons.calendar_today),
                                        title: Text(
                                          'Registered: ${DateFormat('MMM dd, yyyy').format(customer.registrationDate)}',
                                        ),
                                        dense: true,
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.book),
                                        title: Text('Total Bookings: ${customer.bookings.length}'),
                                        dense: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}