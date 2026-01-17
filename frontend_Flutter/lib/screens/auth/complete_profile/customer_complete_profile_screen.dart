import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:serve_ease_new/models/customer_model.dart';
import 'package:serve_ease_new/screens/dashboards/customer_dashboard_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final User user;
  
  const CompleteProfileScreen({super.key, required this.user});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _placeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();  // Added state controller
  bool _isLoading = false;

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customer = CustomerModel(
        customerId: widget.user.uid,
        name: widget.user.displayName ?? '',  // Use displayName from Google
        email: widget.user.email ?? '',
        phone: _phoneController.text.trim(),
        address: '${_placeController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()}',
        isVerified: false,
        registrationDate: DateTime.now().toIso8601String(),
        bookings: [],
        role: 'customer',
      );

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.user.uid)
          .set(customer.toMap());  // Changed customerModel to customer

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to complete profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _placeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A1931), Color(0xFF185ADB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Complete Your Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome ${widget.user.displayName}! Please provide additional details.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Add your form fields here (phone, place, city, pinCode)
                      // Similar to the registration form but only the required fields
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}