import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/getting_started_screen.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool isAccepted = false;

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
              const Text(
                'Your Privacy is\nImportant to us',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  height: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    border: Border.all(
                      color: AppColors.lighterGreen.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _privacyText,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        height: 1.5,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Checkbox(
                    value: isAccepted,
                    onChanged: (value) {
                      setState(() {
                        isAccepted = value ?? false;
                      });
                    },
                    fillColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.transparent,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      "I'm allowing VerdantBank to collect and process my personal information",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
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
                        Navigator.pop(context);
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
                        disabledBackgroundColor: AppColors.lightGreen,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                        ),
                      ),
                      onPressed: isAccepted
                        ? () {
                            Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const GettingStartedScreen(),
                            ),
                            );
                        }
                        : null,
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: AppColors.darkGreen,
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

  final String _privacyText = '''
We are committed to protecting your personal information and ensuring a secure banking experience. Our advanced encryption technology safeguards your data, keeping your transactions safe from unauthorized access. We never share your information without your consent and adhere to the highest industry standards for privacy protection. Your trust is our priority, and we continuously work to enhance our security measures to give you peace of mind while banking with us.

VerdantBank Data Privacy Statement

At VerdantBank, we are committed to protecting your personal data and ensuring a secure banking experience. This Data Privacy Statement explains how we collect, use, and safeguard your information in compliance with applicable privacy laws and regulations.

1. Information We Collect
We may collect personal information such as your name, contact details, account information, transaction history, and other relevant data necessary for banking services. This may also include digital identifiers such as device information and location data.

2. How We Use Your Information
- To provide and maintain our banking services
- To process transactions and verify your identity
- To communicate important account information
- To improve our services and user experience
- To comply with legal and regulatory requirements

3. Data Security
We implement strict security measures to protect your information from unauthorized access, disclosure, alteration, and destruction. Our security protocols are regularly updated to maintain the highest standards of protection.

4. Your Rights
You have the right to:
- Access your personal information
- Request corrections to your data
- Opt out of certain data collection
- Request data deletion where applicable
- Receive information about how your data is used

5. Third-Party Sharing
We only share your information with trusted third parties when necessary for providing our services or when required by law. All third-party partners are bound by strict confidentiality agreements.
''';
}