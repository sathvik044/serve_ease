import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serve_ease_new/screens/customer/booking_screen.dart';  // Add this import
import 'package:firebase_auth/firebase_auth.dart';

class ProviderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  final String serviceType;

  const ProviderDetailsScreen({
    super.key,
    required this.provider,
    required this.serviceType,
  });

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('providerId', isEqualTo: widget.provider['provider_id'])  // Changed from 'id' to 'provider_id'
          .get();

      setState(() {
        _reviews = reviewsSnapshot.docs
            .map((doc) => {
                  ...doc.data(),
                  'id': doc.id,
                })
            .toList();

        if (_reviews.isNotEmpty) {
          _averageRating = _reviews
                  .map((review) => review['rating'] as num)
                  .reduce((a, b) => a + b) /
              _reviews.length;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load reviews: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.provider['name']),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.person, size: 40),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.provider['name'] ?? 'N/A',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                    if (widget.provider['phone'] != null)
                                      Text('Phone: ${widget.provider['phone']}'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          Text(
                            'Service Type: ${widget.serviceType}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (widget.provider['experience'] != null)
                            Text(
                              'Experience: ${widget.provider['experience']} years',
                            ),
                          if (widget.provider['about'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'About: ${widget.provider['about']}',
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                'Average Rating: ${_averageRating.toStringAsFixed(1)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reviews (${_reviews.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_reviews.isEmpty)
                    const Center(
                      child: Text('No reviews yet'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reviews.length,
                      itemBuilder: (context, index) {
                        final review = _reviews[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ...List.generate(
                                      review['rating'] as int,
                                      (index) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 18,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(review['comment'] ?? 'No comment'),
                                const SizedBox(height: 4),
                                Text(
                                  'By: ${review['customerName'] ?? 'Anonymous'}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(
                  provider: widget.provider,
                  serviceType: widget.serviceType,
                ),
              ),
            );
          },
          child: const Text('Book Now'),
        ),
      ),
    );
  }
}