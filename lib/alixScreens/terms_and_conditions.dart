import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/alixScreens/UserRegistrationScreen.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  State<TermsAndConditions> createState() => _TermsAndConditions();
}

class _TermsAndConditions extends State<TermsAndConditions> {
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
                'VerdantBank Terms and Conditions',
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
                      "I agree to the Terms and Conditions",
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
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const UserRegistrationScreen(),
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
1. General Terms

1.1 By opening a VerdantBank Savings Account, you agree to abide by these Terms and Conditions.
1.2 VerdantBank reserves the right to amend these terms at any time, with due notice provided through official communication channels.
1.3 The account is subject to applicable banking laws and regulations in the Philippines.

2. Account Opening and Maintenance

2.1 A minimum initial deposit of ₱1,000 is required to open an account.
2.2 The account holder must maintain a minimum balance of ₱5,000 to keep the account active and avoid maintenance fees.
2.3 VerdantBank reserves the right to close dormant accounts after 12 months of inactivity, following proper notification.

3. Deposits and Withdrawals

3.1 Deposits may be made through bank branches, ATMs, mobile banking, or authorized payment partners.
3.2 Withdrawals are limited to 3 free transactions per month, with applicable fees for additional withdrawals.
3.3 VerdantBank may impose daily transaction limits for security purposes.

4. Interest and Fees

4.1 The account earns 1.5% interest per annum, credited monthly, subject to change at VerdantBanks discretion.
4.2 Maintenance fees apply if the balance falls below the required minimum.
4.3 Additional service fees may apply for specific transactions, as outlined in VerdantBanks official fee schedule.

5. Security and Liability

5.1 The account holder is responsible for safeguarding account credentials and PINs.
5.2 VerdantBank shall not be liable for unauthorized transactions caused by negligence or account holder misconduct.
5.3 In case of suspected fraud or unauthorized access, the account holder must report immediately to VerdantBank’s customer service.

6. Account Closure

6.1 The account holder may request account closure by submitting a formal request at a VerdantBank branch.
6.2 VerdantBank reserves the right to close accounts in cases of fraud, misuse, or non-compliance with regulations.
6.3 Any remaining balance after deducting fees shall be returned to the account holder upon closure.

7. Governing Law

7.1 These Terms and Conditions are governed by the laws of [Country Name].
7.2 Any disputes shall be resolved through legal proceedings or arbitration as required by local banking regulations.

8. Contact Information

For any inquiries, please contact VerdantBank Customer Support at support@Verdantbank.com or visit your nearest branch.

By using your VerdantBank Savings Account, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.
''';
}