import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/terms_and_conditions.dart';

class SavingsAccountScreen extends StatefulWidget {
  final String email; // Add this
  
  const SavingsAccountScreen({
    Key? key, 
    required this.email,
  }) : super(key: key);
  
  @override
  State<SavingsAccountScreen> createState() => _SavingsAccountScreenState();
}

class _SavingsAccountScreenState extends State<SavingsAccountScreen> {
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
              const SizedBox(height: 48),
              const Text(
                'VerdantBank\'s Savings\nAccount',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              _buildAccountDetail('Minimum Initial Deposit:', '₱1,000'),
              _buildAccountDetail('Maintaining Balance:', '₱5,000'),
              _buildAccountDetail('Interest Rate:', '1.5% per annum (subject to change)'),
              _buildAccountDetail('Interest Crediting:', 'Monthly'),
              const SizedBox(height: 32),
              const Text(
                'Features:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildFeature('24/7 Mobile & Online Banking – Access your account anytime, anywhere.'),
              _buildFeature('Secure Transactions – Advanced encryption for safe banking.'),
              _buildFeature('Free Fund Transfers – No charges for transfers within JeruBank accounts.'),
              _buildFeature('SMS & Email Alerts – Get instant notifications on transactions.'),
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
                  Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => TermsAndConditionsScreen(
                    email: widget.email, // Or however you're getting the email in this screen
                  ),
                  ),
                  );
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

  Widget _buildAccountDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              '$label $value',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.lighterGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: AppColors.darkGreen,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}