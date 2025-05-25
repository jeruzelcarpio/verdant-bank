import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/account_completion_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class IdentificationDetailsScreen extends StatefulWidget {
  final String email;
  final String idType;
  final String? idImagePath;

  const IdentificationDetailsScreen({
    super.key,
    required this.email,
    required this.idType,
    this.idImagePath,
  });

  @override
  State<IdentificationDetailsScreen> createState() => _IdentificationDetailsScreenState();
}

class _IdentificationDetailsScreenState extends State<IdentificationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idNumberController = TextEditingController();
  final _expirationController = TextEditingController();
  final _addressController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswer1Controller = TextEditingController();
  final _securityAnswer2Controller = TextEditingController();
  bool isIdentificationStep = true;

  final List<String> securityQuestions = [
    'What is your mother\'s maiden name?',
    'What was the name of your first pet?',
    'In which city were you born?',
    'What was your childhood nickname?',
    'What is the name of your favorite teacher?'
  ];
  String? selectedQuestion1;
  String? selectedQuestion2;

  @override
  void initState() {
    super.initState();
    // Fetch existing user data when the screen loads
    _fetchUserData();
  }

  // Method to fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(widget.email)
          .get();
      
      if (userDoc.exists) {
        setState(() {
          // Auto-fill fields with previously entered data
          _firstNameController.text = userDoc.data()?['accFirstName'] ?? '';
          _lastNameController.text = userDoc.data()?['accLastName'] ?? '';
          _birthDateController.text = userDoc.data()?['dateOfBirth'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Don't show an error to the user since this is just prefilling data
    }
  }

  Future<void> _saveUserData() async {
    // Validate required fields
    if (!_validateFields()) {
      return;
    }
    
    try {
      // First save the identification details
      if (isIdentificationStep) {
        await _saveIdentificationDetails();
      } else {
        // Save security credentials for login
        await _saveLoginCredentials();
        
        // Navigate to completion screen
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => AccountCompletionScreen(
                email: widget.email, // Pass email to completion screen
              ),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error saving user data: $e');
    }
  }

  // Validate all required fields based on current step
  bool _validateFields() {
    if (isIdentificationStep) {
      if (_idNumberController.text.trim().isEmpty) {
        _showError('Please enter your ID number');
        return false;
      }
      if (_addressController.text.trim().isEmpty) {
        _showError('Please enter your residential address');
        return false;
      }
      return true;
    } else {
      // Password validation
      if (_passwordController.text.isEmpty) {
        _showError('Please enter a password');
        return false;
      }
      if (_passwordController.text.length < 8) {
        _showError('Password must be at least 8 characters');
        return false;
      }
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Passwords do not match');
        return false;
      }
      
      // Security questions validation
      if (selectedQuestion1 == null) {
        _showError('Please select security question 1');
        return false;
      }
      if (_securityAnswer1Controller.text.trim().isEmpty) {
        _showError('Please answer security question 1');
        return false;
      }
      if (selectedQuestion2 == null) {
        _showError('Please select security question 2');
        return false;
      }
      if (_securityAnswer2Controller.text.trim().isEmpty) {
        _showError('Please answer security question 2');
        return false;
      }
      if (selectedQuestion1 == selectedQuestion2) {
        _showError('Please select different security questions');
        return false;
      }
      
      return true;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Save identification details to Firebase
  Future<void> _saveIdentificationDetails() async {
    // Convert ID image to base64 if available
    String? idImageBase64;
    if (widget.idImagePath != null) {
      final file = File(widget.idImagePath!);
      final bytes = await file.readAsBytes();
      idImageBase64 = base64Encode(bytes);
    }
    
    // Create identification data
    final identificationData = {
      'idType': widget.idType,
      'idNumber': _idNumberController.text.trim(),
      'expirationDate': _expirationController.text.trim(),
      'residentialAddress': _addressController.text.trim(),
      'idImageBase64': idImageBase64,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('accounts')
        .doc(widget.email)
        .set({
      'identification': identificationData,
      'registrationStep': 'identification_completed',
    }, SetOptions(merge: true));
    
    // Move to the next step
    setState(() {
      isIdentificationStep = false;
    });
  }

  // Save login credentials to Firebase
  Future<void> _saveLoginCredentials() async {
    // Hash the password (for demo purposes using a simple hash)
    // In production, use a proper password hashing algorithm
    final String hashedPassword = _secureHash(_passwordController.text);
    
    // Create security data
    final securityData = {
      'password': hashedPassword,
      'securityQuestions': [
        {
          'question': selectedQuestion1,
          'answer': _securityAnswer1Controller.text.trim().toLowerCase(),
        },
        {
          'question': selectedQuestion2,
          'answer': _securityAnswer2Controller.text.trim().toLowerCase(),
        },
      ],
      'updatedAt': FieldValue.serverTimestamp(),
    };
    
    // Save to Firestore
    await FirebaseFirestore.instance
        .collection('accounts')
        .doc(widget.email)
        .set({
      'security': securityData,
      'registrationStep': 'completed',
      'registrationCompleted': true,
    }, SetOptions(merge: true));
  }
  
  // Simple password hashing function (for demo purposes only)
  // In production, use a proper crypto library for password hashing
  String _secureHash(String password) {
    // This is a simple implementation - NOT for production use
    // Use bcrypt, scrypt, or other proper hashing algorithms in production
    final bytes = utf8.encode(password + "verdant_salt_123"); 
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.lighterGreen.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              hint,
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          isExpanded: true,
          dropdownColor: AppColors.darkGreen,
          icon: const Padding(
            padding: EdgeInsets.only(right: 24),
            child: Icon(Icons.keyboard_arrow_down, color: AppColors.lighterGreen),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  item,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? suffixIcon,
    bool isPassword = false,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: TextStyle(
        color: enabled ? Colors.white : Colors.white.withOpacity(0.7),
      ),
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: AppColors.lighterGreen.withOpacity(0.3),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide(
            color: AppColors.lighterGreen.withOpacity(0.15),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: const BorderSide(
            color: AppColors.lighterGreen,
          ),
        ),
        suffixIcon: isPassword
            ? Icon(
                Icons.visibility_off,
                color: AppColors.lighterGreen,
              )
            : suffixIcon != null
                ? Icon(
                    suffixIcon,
                    color: AppColors.lighterGreen,
                  )
                : null,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        filled: !enabled,
        fillColor: enabled ? null : AppColors.darkGreen.withOpacity(0.3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Getting\nStarted',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: AppColors.lighterGreen,
                            ),
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.lighterGreen,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Verify\nIdentity',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.lighterGreen,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: AppColors.lighterGreen,
                            ),
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.lighterGreen,
                              child: CircleAvatar(
                                radius: 4,
                                backgroundColor: AppColors.darkGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Create\nAccount',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 2,
                              color: Colors.white24,
                            ),
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.white24,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                isIdentificationStep ? 'Identification Details' : 'Create Password',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isIdentificationStep ? 'Please provide your identification details' : 'Create a secure password',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: isIdentificationStep
                          ? [
                              // Identification Details fields
                              _buildTextField(
                                controller: _idNumberController,
                                label: 'ID Number',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _expirationController,
                                label: 'Expiration Date',
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _addressController,
                                label: 'Residential Address',
                              ),
                              const Divider(
                                height: 48,
                                color: Colors.white24,
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Auto-filled from registration',
                                style: TextStyle(
                                  color: AppColors.lighterGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                suffixIcon: Icons.check_circle,
                                enabled: false, // Make it read-only since it's auto-filled
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                suffixIcon: Icons.check_circle,
                                enabled: false, // Make it read-only since it's auto-filled
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _birthDateController,
                                label: 'Date of Birth',
                                suffixIcon: Icons.check_circle,
                                enabled: false, // Make it read-only since it's auto-filled
                              ),
                            ]
                          : [
                              // Password and Security Questions fields
                              _buildTextField(
                                controller: _passwordController,
                                label: 'Enter Password',
                                isPassword: true,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _confirmPasswordController,
                                label: 'Confirm Password',
                                isPassword: true,
                              ),
                              const Divider(
                                height: 48,
                                color: Colors.white24,
                              ),
                              _buildDropdown(
                                value: selectedQuestion1,
                                hint: 'Security Question 1',
                                items: securityQuestions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedQuestion1 = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _securityAnswer1Controller,
                                label: 'Enter Answer',
                              ),
                              const SizedBox(height: 24),
                              _buildDropdown(
                                value: selectedQuestion2,
                                hint: 'Security Question 2',
                                items: securityQuestions,
                                onChanged: (value) {
                                  setState(() {
                                    selectedQuestion2 = value;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _securityAnswer2Controller,
                                label: 'Enter Answer',
                              ),
                            ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.lighterGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Back',
                        style: TextStyle(color: AppColors.lighterGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lighterGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: _saveUserData,
                      child: Text(
                        isIdentificationStep ? 'Next' : 'Create',
                        style: const TextStyle(
                          color: AppColors.darkGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}