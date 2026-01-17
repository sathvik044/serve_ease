import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProviderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> provider;
  const ProviderDetailsScreen({super.key, required this.provider});

  @override
  State<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends State<ProviderDetailsScreen> {
  late Map<String, dynamic> _providerData;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed provider data
    _providerData = {
      ...widget.provider,
      'serviceType': (widget.provider['services'] as List?)?.join(', ') ?? '',
      'location': widget.provider['address'] ?? '',
      'status': widget.provider['approvalStatus']?.toString().toUpperCase() ?? 'PENDING',
    };
    _fetchProviderDetails();
  }

  Future<void> _fetchProviderDetails() async {
    try {
      final providerId = _providerData['provider_id'];

      final response = await http.get(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/service-providers/$providerId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle services with case formatting
        final services = data['services'] != null 
            ? (data['services'] as List).map((service) => 
                service.toString().trim().split(' ').map(
                  (word) => word[0].toUpperCase() + word.substring(1).toLowerCase()
                ).join(' ')
              ).join(', ')
            : '';
            
        setState(() {
          _providerData = {
            'provider_id': data['provider_id'] ?? '',
            'name': data['name'] ?? '',
            'email': data['email'] ?? '',
            'phone': data['phone'] ?? '',
            'serviceType': services,
            'location': data['address'] ?? '',
            'experience': data['experience']?.toString() ?? 'Not specified',
            'status': data['approvalStatus']?.toString().toUpperCase() ?? 'PENDING',
            'about': data['about'] ?? '',
            'age': data['age']?.toString() ?? '',
            'gender': data['gender']?.toString().toLowerCase() ?? '',
            'adhar': data['adhar'] ?? '',
          };
        });
      }
    } catch (e) {
      print('Error fetching provider details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    String status = (_providerData['status'] ?? 'PENDING').toString().toUpperCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Details'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchProviderDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.person, size: 50, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                title: 'Basic Information',
                content: Column(
                  children: [
                    _buildInfoRow('Name', _providerData['name'] ?? 'N/A'),
                    _buildInfoRow('Email', _providerData['email'] ?? 'N/A'),
                    _buildInfoRow('Phone', _providerData['phone'] ?? 'N/A'),
                    _buildInfoRow('Service Type', _providerData['serviceType'] ?? 'N/A'),
                    _buildInfoRow('Location', _providerData['location'] ?? 'N/A'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Service Details',
                content: Column(
                  children: [
                    _buildInfoRow('Experience', _providerData['experience'] ?? 'Not specified'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                title: 'Additional Information',
                content: Column(
                  children: [
                    _buildInfoRow('Status', status),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required Widget content}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3C72),
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 15,
                color: label == 'Status' 
                    ? _getStatusColor(value)
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.black87;
    }
  }
}