import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serve_ease_new/screens/customer/provider_details_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serve_ease_new/screens/customer/booking_screen.dart';
import 'package:serve_ease_new/services/booking_service.dart';
import 'package:serve_ease_new/widgets/booking_dialog.dart';

class ServiceProvidersScreen extends StatefulWidget {
  final String serviceType;
  final List<Map<String, dynamic>> providers;

  const ServiceProvidersScreen({
    super.key,
    required this.serviceType,
    required this.providers,
  });

  @override
  State<ServiceProvidersScreen> createState() => _ServiceProvidersScreenState();
}

class _ServiceProvidersScreenState extends State<ServiceProvidersScreen> {
  Future<void> _handleBooking(String providerId) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => BookingDialog(serviceType: widget.serviceType),
    );

    if (result != null) {
      try {
        await BookingService.createBooking(
          providerId: providerId,
          serviceType: widget.serviceType,
          description: result['description'] ?? '',
          scheduledDate: result['date'] ?? '',
          scheduledTime: result['time'] ?? '',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking created successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.serviceType} Providers'),
      ),
      body: widget.providers.isEmpty
          ? const Center(
              child: Text('No service providers found'),
            )
          : ListView.builder(
              itemCount: widget.providers.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final provider = widget.providers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProviderDetailsScreen(
                            provider: provider,
                            serviceType: widget.serviceType,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor,
                                child: Text(
                                  provider['name'][0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  provider['name'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Experience: ${provider["experience"] ?? "Not specified"} years',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Services: ${(provider["services"] as List).join(", ")}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone: ${provider["phone"]}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (provider['about'] != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'About: ${provider["about"]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _handleBooking(provider['_id']),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 45),
                            ),
                            child: const Text('Book Now'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}