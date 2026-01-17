import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Add this import

class CustomerBookingsScreen extends StatelessWidget {
  const CustomerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(  // Update the type
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .where('customerId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
            // Remove the orderBy clause temporarily
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data?.docs ?? [];

          // Sort the bookings in memory instead
          bookings.sort((a, b) {
            final aTimestamp = a.data()['timestamp'] as Timestamp?;
            final bTimestamp = b.data()['timestamp'] as Timestamp?;
            if (aTimestamp == null || bTimestamp == null) return 0;
            return bTimestamp.compareTo(aTimestamp); // descending order
          });

          if (bookings.isEmpty) {
            return const Center(child: Text('No bookings yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index].data() as Map<String, dynamic>;
              final status = booking['status'] ?? 'PENDING';
              
              Color statusColor;
              switch (status) {
                case 'ACCEPTED':
                  statusColor = Colors.green;
                  break;
                case 'REJECTED':
                  statusColor = Colors.red;
                  break;
                default:
                  statusColor = Colors.orange;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            booking['providerName'] ?? 'Unknown Provider',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Service: ${booking['serviceType']}'),
                      const SizedBox(height: 4),
                      Text('Date: ${booking['date']}'),
                      const SizedBox(height: 4),
                      Text('Time: ${booking['time']}'),
                      if (booking['notes']?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text('Notes: ${booking['notes']}'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}