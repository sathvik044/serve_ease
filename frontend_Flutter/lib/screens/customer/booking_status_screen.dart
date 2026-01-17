import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingStatusScreen extends StatelessWidget {
  final String bookingId;

  const BookingStatusScreen({
    super.key,
    required this.bookingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Status'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bookings')
            .doc(bookingId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final booking = snapshot.data!.data() as Map<String, dynamic>;
          final status = booking['status'] as String;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(
                  'Booking Requested',
                  'Your request has been sent to the provider',
                  Icons.schedule,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildStatusCard(
                  'Provider Review',
                  _getStatusMessage(status),
                  _getStatusIcon(status),
                  _getStatusColor(status),
                ),
                if (status == 'ACCEPTED') ...[
                  const SizedBox(height: 16),
                  _buildStatusCard(
                    'Booking Confirmed',
                    'Your booking has been confirmed',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(
    String title,
    String message,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(message),
      ),
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'PENDING':
        return 'Waiting for provider response';
      case 'ACCEPTED':
        return 'Provider accepted your request';
      case 'REJECTED':
        return 'Provider rejected your request';
      default:
        return 'Unknown status';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'ACCEPTED':
        return Icons.check_circle;
      case 'REJECTED':
        return Icons.cancel;
      default:
        return Icons.error;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}