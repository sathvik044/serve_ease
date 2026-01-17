import 'package:flutter/material.dart';
import 'package:serve_ease_new/models/booking_model.dart';
import 'package:serve_ease_new/screens/service_provider/provider_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingsSection extends StatefulWidget {
  const BookingsSection({Key? key}) : super(key: key);

  @override
  State<BookingsSection> createState() => _BookingsSectionState();
}

class _BookingsSectionState extends State<BookingsSection> {
  List<BookingModel> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final bookingsData = await ProviderService.getProviderBookings(user.uid);
        setState(() {
          bookings = bookingsData.map((json) => BookingModel.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bookings: $e')),
      );
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const TabBar(
            labelColor: Color(0xFF1E3C72),
            tabs: [
              Tab(text: 'All'),
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildBookingsList(bookings),
                _buildBookingsList(bookings.where((b) => b.status == 'APPROVED').toList()),
                _buildBookingsList(bookings.where((b) => b.status == 'COMPLETED').toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(List<BookingModel> bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text('No bookings found'));
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              title: Text(booking.serviceType),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Customer: ${booking.customerName}'),
                  Text('Date: ${booking.scheduledDate}'),
                  Text('Time: ${booking.scheduledTime}'),
                  Text('Status: ${booking.status}'),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}