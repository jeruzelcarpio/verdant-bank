import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/signIn_screen.dart';

class AccountCompletionScreen extends StatelessWidget {
  const AccountCompletionScreen({super.key});

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