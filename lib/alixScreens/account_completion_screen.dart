import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/signIn_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class AccountCompletionScreen extends StatefulWidget {
  final String email;

  const AccountCompletionScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  State<AccountCompletionScreen> createState() => _AccountCompletionScreenState();
}

class _AccountCompletionScreenState extends State<AccountCompletionScreen> {
  bool _isProcessing = true;
  
  @override
  void initState() {
    super.initState();
    _finalizeAccountSetup();
  }
  
  // Generate a unique account number that doesn't exist in Firestore
  Future<String> _generateUniqueAccountNumber() async {
    final Random random = Random();
    bool isUnique = false;
    String accNumber = '';

    while (!isUnique) {
      // Generate a random 10-digit number
      // First digit can't be 0 to ensure it's 10 digits
      int firstDigit = 1 + random.nextInt(9); // 1-9
      int remainingDigits = random.nextInt(1000000000); // 0-999999999

      // Format to ensure exactly 10 digits
      accNumber = firstDigit.toString() + remainingDigits.toString().padLeft(9, '0');
      
      // Check if this account number already exists
      final QuerySnapshot query = await FirebaseFirestore.instance
          .collection('accounts')
          .where('accNumber', isEqualTo: accNumber)
          .limit(1)
          .get();
      
      if (query.docs.isEmpty) {
        isUnique = true;
      }
    }
    
    return accNumber;
  }
  
  // Add account number and balance to Firestore
  Future<void> _finalizeAccountSetup() async {
    try {
      // Generate a unique account number
      final String accountNumber = await _generateUniqueAccountNumber();
      
      // Update the user's document with the account number and initial balance
      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(widget.email)
          .update({
            'accNumber': accountNumber,
            'accBalance': 0.0,
            'registrationCompleted': true,
          });
          
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      print('Error finalizing account setup: $e');
      // Continue showing the completion screen even if this fails
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Spacer(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.lighterGreen,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 50,
                        color: AppColors.lighterGreen,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Account Creation\nCompleted!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lighterGreen,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your information is being reviewed. Please\nallow up to 4 working days for verification. We\'ll\nnotify you once your account is ready to use.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighterGreen,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Done',
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}