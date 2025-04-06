import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';

class OTPConfirmationScreen extends StatefulWidget {
  final String phoneNumber;
  final String otpCode;
  final VoidCallback onConfirm;
  final VoidCallback? onResend;

  const OTPConfirmationScreen({
    Key? key,
    required this.phoneNumber,
    required this.otpCode,
    required this.onConfirm,
    this.onResend,
  }) : super(key: key);

  @override
  State<OTPConfirmationScreen> createState() => _OTPConfirmationScreenState();
}

class _OTPConfirmationScreenState extends State<OTPConfirmationScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  String get enteredCode =>
      _controllers.map((controller) => controller.text).join();

  bool get isCodeComplete =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  void _handleInputChange(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          'AUTHENTICATION',
          style: TextStyle(
            color: AppColors.lighterGreen,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 572,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(21),
                color: AppColors.green,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock,
                      size: 80,
                      color: AppColors.yellowGold,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 252,
                      child: Text(
                        "This confirmation code has been sent to the phone number ${widget.phoneNumber}. Please enter the 6 digit code to continue:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.milk,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 74),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 40,
                          child: TextField(
                            controller: _controllers[index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: AppColors.lighterGreen,
                              fontWeight: FontWeight.w700,
                            ),
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: InputDecoration(
                              counterText: "",
                              filled: true,
                              fillColor: AppColors.darkGreen,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: AppColors.lighterGreen,
                                ),
                              ),
                            ),
                            onChanged: (value) =>
                                _handleInputChange(index, value),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 74),
                    Text(
                      "Did not receive a code?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.milk,
                        fontSize: 14,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onResend,
                      child: Text(
                        "Resend Code",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.milk,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 64),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      side: BorderSide(color: AppColors.lighterGreen),
                    ),
                    child: Text(
                      "Back",
                      style: TextStyle(
                        color: AppColors.lighterGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCodeComplete &&
                        enteredCode == widget.otpCode
                        ? widget.onConfirm
                        : (){},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lighterGreen,
                    ),
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
