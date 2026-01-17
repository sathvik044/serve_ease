import 'package:flutter/material.dart';
import 'package:serve_ease_new/models/booking_model.dart';

class DashboardSection extends StatelessWidget {
  final List<BookingModel> bookings;
  final Function(String, bool) onBookingAction;

  const DashboardSection({
    Key? key,
    required this.bookings,
    required this.onBookingAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pendingBookings = bookings.where((b) => b.status == 'PENDING').toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pending Bookings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3C72),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: pendingBookings.length,
            itemBuilder: (context, index) {
              final booking = pendingBookings[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service: ${booking.serviceType}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Customer: ${booking.customerName}'),
                      Text('Date: ${booking.scheduledDate}'),
                      Text('Time: ${booking.scheduledTime}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => onBookingAction(booking.id, false),
                            child: const Text('Reject'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () => onBookingAction(booking.id, true),
                            child: const Text('Accept'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}