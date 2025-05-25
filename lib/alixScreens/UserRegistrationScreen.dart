import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/id_verification_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Add this import

class UserRegistrationScreen extends StatefulWidget {
  final String email; // Add this parameter
  
  const UserRegistrationScreen({
    super.key,
    required this.email, // Required email parameter
  });

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  bool isNameSection = true;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _suffixController = TextEditingController();
  final TextEditingController _mothersMaidenNameController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  String? selectedCountry;
  String? selectedCity;
  bool _isLoading = false;
  String? _errorMessage;

  // Country data structure
  final Map<String, List<String>> _countryToCities = {
    'Philippines': [
      'Manila', 'Quezon City', 'Cebu City', 'Davao City', 'Makati', 
      'Pasig', 'Taguig', 'Caloocan', 'Pasay', 'Bacolod'
    ],
    'United States': [
      'New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix',
      'Philadelphia', 'San Antonio', 'San Diego', 'Dallas', 'San Jose'
    ],
    'Canada': [
      'Toronto', 'Montreal', 'Vancouver', 'Calgary', 'Edmonton',
      'Ottawa', 'Winnipeg', 'Quebec City', 'Hamilton', 'Kitchener'
    ],
    'United Kingdom': [
      'London', 'Manchester', 'Birmingham', 'Glasgow', 'Liverpool',
      'Bristol', 'Edinburgh', 'Leeds', 'Sheffield', 'Leicester'
    ],
    'Australia': [
      'Sydney', 'Melbourne', 'Brisbane', 'Perth', 'Adelaide',
      'Gold Coast', 'Canberra', 'Newcastle', 'Wollongong', 'Hobart'
    ],
  };
  
  // Get cities based on selected country
  List<String> get _cities {
    if (selectedCountry == null) return [];
    return _countryToCities[selectedCountry] ?? [];
  }

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
    return InkWell(
      onTap: () {
        if (placeholder.contains('Country')) {
          _showCountrySelectionBottomSheet(context);
        } else if (selectedCountry != null) {
          _showCitySelectionBottomSheet(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a country first'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.lighterGreen.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(40),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? placeholder,
              style: TextStyle(
                color: value == null ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.lighterGreen),
          ],
        ),
      ),
    );
  }

  void _showCountrySelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Select Country of Birth',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white24),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _countryToCities.length,
                    itemBuilder: (context, index) {
                      final country = _countryToCities.keys.elementAt(index);
                      return ListTile(
                        title: Text(
                          country,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            selectedCountry = country;
                            selectedCity = null; // Reset city when country changes
                          });
                          Navigator.pop(context);
                        },
                        trailing: selectedCountry == country
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.lighterGreen,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCitySelectionBottomSheet(BuildContext context) {
    if (selectedCountry == null) return;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkGreen,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  child: Text(
                    'Select City in $selectedCountry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(color: Colors.white24),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _cities.length,
                    itemBuilder: (context, index) {
                      final city = _cities[index];
                      return ListTile(
                        title: Text(
                          city,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            selectedCity = city;
                          });
                          Navigator.pop(context);
                        },
                        trailing: selectedCity == city
                            ? const Icon(
                                Icons.check_circle,
                                color: AppColors.lighterGreen,
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveUserData() async {
    if (_isLoading) return;
    
    // Validate required fields
    if (_firstNameController.text.trim().isEmpty) {
      _showError('Please enter your first name');
      return;
    }
    
    if (_lastNameController.text.trim().isEmpty) {
      _showError('Please enter your last name');
      return;
    }
    
    if (dateController.text.isEmpty) {
      _showError('Please select your date of birth');
      return;
    }
    
    if (selectedCountry == null) {
      _showError('Please select your country of birth');
      return;
    }
    
    if (selectedCity == null) {
      _showError('Please select your city of birth');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create a user profile map with all the data
      final userData = {
        'accFirstName': _firstNameController.text.trim(),
        'accMiddleName': _middleNameController.text.trim(),
        'accLastName': _lastNameController.text.trim(),
        'accSuffix': _suffixController.text.trim(),
        'mothersMaidenName': _mothersMaidenNameController.text.trim(),
        'dateOfBirth': dateController.text,
        'countryOfBirth': selectedCountry,
        'cityOfBirth': selectedCity,
        'registrationStep': 'personal_info_completed',
        'registrationCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore using email as the document ID
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(widget.email)
          .set(userData, SetOptions(merge: true));

      // Navigate to the next screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IdVerificationScreen(
              email: widget.email,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save user data. Please try again.');
      print('Error saving user data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    // Dispose controllers when the screen is disposed
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _suffixController.dispose();
    _mothersMaidenNameController.dispose();
    dateController.dispose();
    super.dispose();
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
                        _buildTextField('First Name', _firstNameController),
                        const SizedBox(height: 16),
                        _buildTextField('Middle Name (Optional)', _middleNameController),
                        const SizedBox(height: 16),
                        _buildTextField('Last Name', _lastNameController),
                        const SizedBox(height: 16),
                        _buildTextField('Suffix (Optional)', _suffixController),
                        const SizedBox(height: 16),
                        _buildTextField('Mother\'s Maiden Name', _mothersMaidenNameController),
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
                      onPressed: _isLoading 
                          ? null 
                          : () {
                              if (isNameSection) {
                                setState(() {
                                  isNameSection = false;
                                });
                              } else {
                                _saveUserData();
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.darkGreen,
                              ),
                            )
                          : const Text(
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

  Widget _buildTextField(String placeholder, TextEditingController controller) {
    return TextField(
      controller: controller, // Add this to connect the controller
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