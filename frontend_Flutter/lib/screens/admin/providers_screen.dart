import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:serve_ease_new/screens/admin/provider_details_screen.dart';
import 'package:serve_ease_new/screens/role_selection_screen.dart';

class ProvidersScreen extends StatefulWidget {
  final int initialTabIndex;

  const ProvidersScreen({super.key, this.initialTabIndex = 0});

  @override
  State<ProvidersScreen> createState() => _ProvidersScreenState();
}

class _ProvidersScreenState extends State<ProvidersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _allProviders = [];
  List<dynamic> _pendingProviders = [];
  TextEditingController _searchController = TextEditingController();

  // Add these properties
  List<dynamic> _filteredAllProviders = [];
  List<dynamic> _filteredPendingProviders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
    _fetchProviders();
  }

  // Add this method to filter providers
  // Update the filter providers method
  void _filterProviders(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAllProviders = List.from(_allProviders);
        _filteredPendingProviders = List.from(_pendingProviders);
      } else {
        query = query.toLowerCase();
        _filteredAllProviders = _allProviders.where((provider) {
          final name = (provider['name'] ?? '').toString().toLowerCase();
          final services = provider['services'] != null 
              ? (provider['services'] as List).map((s) => s.toString().toLowerCase()).toList()
              : [(provider['serviceType'] ?? '').toString().toLowerCase()];
          
          // Check if query matches name or any of the services
          return name.contains(query) || 
                 services.any((service) => service.contains(query));
        }).toList();

        _filteredPendingProviders = _pendingProviders.where((provider) {
          final name = (provider['name'] ?? '').toString().toLowerCase();
          final services = provider['services'] != null 
              ? (provider['services'] as List).map((s) => s.toString().toLowerCase()).toList()
              : [(provider['serviceType'] ?? '').toString().toLowerCase()];
          
          // Check if query matches name or any of the services
          return name.contains(query) || 
                 services.any((service) => service.contains(query));
        }).toList();
      }
    });
  }

  // Update the _fetchProviders method
  // Keep this version of _fetchProviders
  Future<void> _fetchProviders() async {
    setState(() => _isLoading = true);

    try {
      final headers = {'Content-Type': 'application/json'};
      
      final responses = await Future.wait([
        http.get(
          Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/service-providers'),
          headers: headers
        ),
        http.get(
          Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/service-providers/pending'),
          headers: headers
        ),
      ]);

      if (!mounted) return;

      // Add debug prints
      print('All providers response: ${responses[0].body}');
      print('Pending providers response: ${responses[1].body}');

      for (var response in responses) {
        if (response.statusCode != 200) {
          throw Exception('Failed to fetch providers');
        }
      }

      setState(() {
        _allProviders = json.decode(responses[0].body);
        _pendingProviders = json.decode(responses[1].body);
        // Initialize filtered lists
        _filteredAllProviders = List.from(_allProviders);
        _filteredPendingProviders = List.from(_pendingProviders);
        _isLoading = false;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Keep only ONE _fetchProviders method - DELETE the second one that appears after this
  
  Future<void> _handleApproval(String? providerId, bool approve) async {
    if (providerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Provider ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Show loading indicator
      setState(() => _isLoading = true);

      if (!approve) {
        final bool? confirmReject = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Confirm Rejection'),
            content: const Text('Are you sure you want to reject this provider?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Reject'),
              ),
            ],
          ),
        );
        if (confirmReject != true) {
          setState(() => _isLoading = false);
          return;
        }
      }

      final response = await http.put(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/admin/service-providers/$providerId/approval'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': approve ? 'APPROVED' : 'REJECTED'}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Refresh the lists
        await _fetchProviders();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              approve ? 'Provider approved successfully' : 'Provider rejected successfully',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: approve ? Colors.green : Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('Failed to update provider status: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildProviderCard(dynamic provider, {bool isPending = false}) {
    // Format services list
    final services = provider['services'] != null 
        ? (provider['services'] as List).join(', ')
        : provider['serviceType'] ?? 'N/A';
    
    // Get provider ID
    final String? providerId = provider['provider_id']?.toString();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPending ? Colors.orange : Colors.blue,
          child: const Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(provider['name'] ?? 'N/A'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider['email'] ?? 'N/A'),
            Text('Service: $services'),
          ],
        ),
        trailing: isPending
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    onPressed: () async {
                      if (providerId != null) {
                        await _handleApproval(providerId, true);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: _isLoading 
                      ? null 
                      : () async {
                          if (providerId != null) {
                            await _handleApproval(providerId, false);
                          }
                        },
                  ),
                ],
              )
            : IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProviderDetailsScreen(provider: provider),
                    ),
                  );
                },
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Providers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Providers'),
            Tab(text: 'Pending Approval'),
          ],
        ),
        // In the AppBar actions where the logout button is defined
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const RoleSelectionScreen(),
                ),
                (route) => false, // This removes all previous routes from the stack
              );
            },
          ),
        ],
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
                        onPressed: _fetchProviders,
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
                          hintText: 'Search by name or service type',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onChanged: _filterProviders,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // All Providers Tab
                          RefreshIndicator(
                            onRefresh: _fetchProviders,
                            child: ListView.builder(
                              itemCount: _filteredAllProviders.length,
                              itemBuilder: (context, index) => 
                                _buildProviderCard(_filteredAllProviders[index]),
                            ),
                          ),
                          // Pending Approval Tab
                          RefreshIndicator(
                            onRefresh: _fetchProviders,
                            child: ListView.builder(
                              itemCount: _filteredPendingProviders.length,
                              itemBuilder: (context, index) => 
                                _buildProviderCard(_filteredPendingProviders[index], isPending: true),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}