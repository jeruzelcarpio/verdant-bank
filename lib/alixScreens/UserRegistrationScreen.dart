import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/id_verification_screen.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  bool isNameSection = true;
  final TextEditingController dateController = TextEditingController();
  String? selectedCountry;
  String? selectedCity;

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime.now().subtract(const Duration(days: 36500)), // 100 years ago
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.lighterGreen,
              surface: AppColors.darkGreen,
              onPrimary: Colors.white,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Widget _buildBirthdayContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'When is your birthday?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please enter your date of birth as shown on your official documents.',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 32),
        InkWell(
          onTap: _showDatePicker,
          child: TextField(
            controller: dateController,
            enabled: false,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Date of Birth',
              suffixIcon: const Icon(Icons.calendar_today, color: AppColors.lighterGreen),
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(
                  color: AppColors.lighterGreen.withOpacity(0.3),
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide(
                  color: AppColors.lighterGreen.withOpacity(0.3),
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildDropdown('Country of Birth', selectedCountry),
        const SizedBox(height: 16),
        _buildDropdown('City of Birth', selectedCity),
      ],
    );
  }

  Widget _buildDropdown(String placeholder, String? value) {
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
          hint: Text(
            placeholder,
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          isExpanded: true,
          dropdownColor: AppColors.darkGreen,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          style: const TextStyle(color: Colors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.lighterGreen),
          items: const [], // Add your items here
          onChanged: (newValue) {
            setState(() {
              if (placeholder.contains('Country')) {
                selectedCountry = newValue;
              } else {
                selectedCity = newValue;
              }
            });
          },
        ),
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
              // Progress Bar Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text(
                          'Getting\nStarted',
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
                          'Verify\nIdentity',
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
              isNameSection
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'What is your name?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Kindly enter your name exactly as it appears on your ID.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField('First Name'),
                        const SizedBox(height: 16),
                        _buildTextField('Middle Name (Optional)'),
                        const SizedBox(height: 16),
                        _buildTextField('Last Name'),
                        const SizedBox(height: 16),
                        _buildTextField('Suffix (Optional)'),
                        const SizedBox(height: 16),
                        _buildTextField('Mother\'s Maiden Name'),
                      ],
                    )
                  : _buildBirthdayContent(),
              const Spacer(),
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
                      onPressed: () {
                        if (!isNameSection) {
                          setState(() {
                            isNameSection = true;
                          });
                        } else {
                          Navigator.pop(context);
                        }
                      },
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
                        if (isNameSection) {
                            setState(() {
                            isNameSection = false;
                            });
                        } else {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const IdVerificationScreen(),
                            ),
                            );
                        }
                      },
                      child: const Text(
                        'Next',
                        style: TextStyle(color: AppColors.darkGreen),
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

  Widget _buildTextField(String placeholder) {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
    );
  }
}