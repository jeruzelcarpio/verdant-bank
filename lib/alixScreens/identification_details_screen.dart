import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/account_completion_screen.dart';

class IdentificationDetailsScreen extends StatefulWidget {
  const IdentificationDetailsScreen({super.key});

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
                isIdentificationStep ? 'Auto-Fill' : '',
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
                              _buildTextField(
                                controller: _firstNameController,
                                label: 'First Name',
                                suffixIcon: Icons.check_circle,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                suffixIcon: Icons.check_circle,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _birthDateController,
                                label: 'Date of Birth',
                                suffixIcon: Icons.check_circle,
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
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (isIdentificationStep) {
                            setState(() {
                              isIdentificationStep = false;
                            });
                          } else {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AccountCompletionScreen(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
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
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
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
      ),
    );
  }
}