import 'package:flutter/material.dart';
import 'package:serve_ease_new/utils/app_theme.dart';
import 'package:serve_ease_new/models/service_provider_model.dart';
import 'package:serve_ease_new/screens/auth/waiting_approval_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ServiceProviderRegisterScreen extends StatefulWidget {
  const ServiceProviderRegisterScreen({super.key});

  @override
  State<ServiceProviderRegisterScreen> createState() => _ServiceProviderRegisterScreenState();
}

class _ServiceProviderRegisterScreenState extends State<ServiceProviderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _aadharController = TextEditingController();
  final _placeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _ageController = TextEditingController();
  final _aboutController = TextEditingController();
  final _experienceController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  Gender _selectedGender = Gender.male;
  List<String> _selectedServices = [];
  bool _acceptedTerms = false;

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

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('https://serveeaseserver-production.up.railway.app/api/service-providers/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'adhar': _aadharController.text.trim(),
          'address': '${_placeController.text.trim()}, ${_cityController.text.trim()}, ${_stateController.text.trim()}',
          'gender': _selectedGender.toString().split('.').last,
          'age': int.parse(_ageController.text.trim()),
          'about': _aboutController.text.trim(),
          'services': _selectedServices,
          'experience': _experienceController.text.trim(),
          'password': _passwordController.text,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 201) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const WaitingApprovalScreen()),
          );
        }
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed. Please try again.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    if (!RegExp(r'[A-Z]').hasMatch(value)) return 'Password must contain at least one uppercase letter';
    if (!RegExp(r'[a-z]').hasMatch(value)) return 'Password must contain at least one lowercase letter';
    if (!RegExp(r'[0-9]').hasMatch(value)) return 'Password must contain at least one number';
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) return 'Password must contain at least one special character (!@#\$&*~)';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Please enter a valid 10-digit phone number';
    return null;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'Register as a Service Provider',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 5),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                            errorStyle: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                          validator: _validatePhone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _ageController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Age',
                            prefixIcon: Icon(Icons.cake_outlined),
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            final age = int.tryParse(value!);
                            if (age == null || age < 18) return 'Must be at least 18 years old';
                            if (age > 100) return 'Please enter a valid age';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24), // Increased spacing
                        TextFormField(
                          controller: _aadharController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Aadhar Number',
                            prefixIcon: Icon(Icons.credit_card),
                            errorStyle: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            if (!RegExp(r'^[0-9]{12}$').hasMatch(value!)) {
                              return 'Please enter a valid 12-digit Aadhar number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24), // Increased spacing
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
                          'Address',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _placeController,
                          decoration: const InputDecoration(
                            labelText: 'Place/Street',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (value) => value?.isEmpty == true ? 'Required' : null,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: const InputDecoration(
                                  labelText: 'City',
                                  prefixIcon: Icon(Icons.location_city),
                                ),
                                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _stateController,
                                decoration: const InputDecoration(
                                  labelText: 'State',
                                  prefixIcon: Icon(Icons.map_outlined),
                                ),
                                validator: (value) => value?.isEmpty == true ? 'Required' : null,
                              ),
                            ),
                          ],
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
                        const Text(
                          'Account Security',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              height: 1.2,
                            ),
                            errorMaxLines: 6,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            errorStyle: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) return 'Required';
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        // Terms and Conditions section
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Terms and Conditions',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3C72)),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Service Quality & Compliance\n'
                                  '• Services must be provided professionally and follow local laws.\n'
                                  '• False claims or misleading information are strictly prohibited.\n'
                                  'User Interaction & Reviews\n'
                                  '• Must maintain professional behavior and cannot manipulate reviews.\n'
                                  '• Can respond to reviews but must do so respectfully.\n'
                                  'Account Suspension & Termination\n'
                                  '• Violation of terms, fraud, or repeated complaints may lead to account suspension or termination.\n'
                                  'Data Privacy & Confidentiality\n'
                                  '• Must protect user data and not misuse customer information.',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          value: _acceptedTerms,
                          onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
                          title: const Text('I accept the terms and conditions'),
                          controlAffinity: ListTileControlAffinity.leading, // This moves the checkbox to the left
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading || !_acceptedTerms ? null : _handleRegistration,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF185ADB),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Register',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
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
