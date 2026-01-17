import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:serve_ease_new/utils/app_theme.dart';
import 'package:serve_ease_new/screens/auth/waiting_approval_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class ProviderCompleteProfileScreen extends StatefulWidget {
  final User user;
  const ProviderCompleteProfileScreen({super.key, required this.user});

  @override
  State<ProviderCompleteProfileScreen> createState() => _ProviderCompleteProfileScreenState();
}

class _ProviderCompleteProfileScreenState extends State<ProviderCompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadharController = TextEditingController();
  final _addressController = TextEditingController();
  final _ageController = TextEditingController();
  final _aboutController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _isLoading = false;
  Gender _selectedGender = Gender.male;
  List<String> _selectedServices = [];
  Position? _currentPosition;
  String _currentAddress = "";

  final List<String> _availableServices = [
    'Plumbing',
    'Electrical',
    'Carpentry',
    'Painting',
    'Cleaning',
    'Gardening',
    'Moving',
    'Appliance Repair',
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    // Pre-fill name if available from Google Sign In
    if (widget.user.displayName != null) {
      final nameParts = widget.user.displayName!.split(' ');
      _firstNameController.text = nameParts.first;
      if (nameParts.length > 1) {
        _lastNameController.text = nameParts.skip(1).join(' ');
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.denied) {
        return;
      }

      setState(() => _isLoading = true);
      
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentPosition = position;
          _currentAddress = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}';
          _addressController.text = _currentAddress;
        });
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one service')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final serviceProvider = {
        'providerId': widget.user.uid,
        'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'email': widget.user.email,
        'phone': _phoneController.text.trim(),
        'adhar': _aadharController.text.trim(),
        'address': _addressController.text.trim(),
        'location': _currentPosition != null 
          ? {
              'latitude': _currentPosition!.latitude,
              'longitude': _currentPosition!.longitude,
            }
          : null,
        'gender': _selectedGender.toString().split('.').last,
        'age': int.parse(_ageController.text.trim()),
        'about': _aboutController.text.trim(),
        'services': _selectedServices,
        'approvalStatus': 'PENDING',  // Explicitly set status to PENDING
        'isVerified': false,
        'experience': int.parse(_experienceController.text.trim()),
        'registrationDate': DateTime.now().toIso8601String(),
        'active': false,
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('serviceProviders')  // Make sure collection name matches
          .doc(widget.user.uid)
          .set(serviceProvider);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WaitingApprovalScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Complete Your Profile',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Welcome ${widget.user.displayName ?? ""}! Please complete your profile to continue.',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Personal Information',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(
                                  labelText: 'First Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Last Name',
                                  prefixIcon: Icon(Icons.person_outline),
                                ),
                                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
                              return 'Please enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            prefixIcon: Icon(Icons.cake_outlined),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            final age = int.tryParse(value!);
                            if (age == null || age < 18) return 'Must be at least 18 years old';
                            if (age > 100) return 'Please enter a valid age';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _aadharController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Aadhar Number',
                            prefixIcon: Icon(Icons.credit_card),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            if (!RegExp(r'^[0-9]{12}$').hasMatch(value!)) {
                              return 'Please enter a valid 12-digit Aadhar number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<Gender>(
                          value: _selectedGender,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          items: Gender.values.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender.toString().split('.').last),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedGender = value!);
                          },
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Location',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(
                                  _currentAddress.isEmpty ? Icons.location_off : Icons.location_on,
                                  color: _currentAddress.isEmpty ? Colors.grey : Color(0xFF1E3C72),
                                ),
                                title: Text(
                                  _currentAddress.isEmpty ? 'Location not set' : 'Current Location',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _currentAddress.isEmpty ? Colors.grey : Colors.black,
                                  ),
                                ),
                                subtitle: _currentAddress.isEmpty
                                    ? null
                                    : Text(_currentAddress),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    setState(() => _isLoading = true);
                                    await _getCurrentLocation();
                                    if (_currentAddress.isNotEmpty && mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Location updated successfully!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  icon: _isLoading 
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Icon(Icons.my_location),
                                  label: Text(_currentAddress.isEmpty ? 'Set Location' : 'Update Location'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1E3C72),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                              if (_currentPosition != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 16, right: 16, bottom: 16),
                                  child: Row(
                                    children: [
                                      Icon(Icons.gps_fixed, 
                                        size: 16, 
                                        color: Color(0xFF1E3C72)
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}\nLong: ${_currentPosition!.longitude.toStringAsFixed(4)}',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Detailed Address',
                            hintText: 'Add apartment/house number, landmark, etc.',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF1E3C72)),
                            ),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Professional Information',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _experienceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Years of Experience',
                            prefixIcon: Icon(Icons.work_outline),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _aboutController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'About You',
                            prefixIcon: Icon(Icons.description_outlined),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Services Offered',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _availableServices.map((service) {
                            final isSelected = _selectedServices.contains(service);
                            return FilterChip(
                              label: Text(service),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedServices.add(service);
                                  } else {
                                    _selectedServices.remove(service);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _completeProfile,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFF1E3C72),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Complete Profile',
                                    style: TextStyle(fontSize: 16),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum Gender { male, female, other }