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
  // Add temporary flag to accept any code
  final bool _temporaryAcceptAnyCode = true;
  
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());

  String get enteredCode =>
      _controllers.map((controller) => controller.text).join();

  bool get isCodeComplete =>
      _controllers.every((controller) => controller.text.isNotEmpty);

  bool _showError = false;

  void _handleInputChange(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).previousFocus();
    }
    
    // Reset error state when user types
    if (_showError) {
      setState(() {
        _showError = false;
      });
    } else {
      setState(() {});
    }
  }
  
  void _validateAndProceed() {
    if (!isCodeComplete) {
      setState(() {
        _showError = true;
      });
      return;
    }
    
    // Modified validation to accept any code if flag is enabled
    if (_temporaryAcceptAnyCode || enteredCode == widget.otpCode) {
      widget.onConfirm();
    } else {
      setState(() {
        _showError = true;
      });
    }
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
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double verticalPadding = constraints.maxHeight > 600 ? 20.0 : 10.0;
            final double horizontalPadding = 20.0;
            
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(21),
                        color: AppColors.green,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(constraints.maxHeight > 700 ? 20.0 : 15.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.lock,
                              size: constraints.maxHeight > 600 ? 60 : 40,
                              color: AppColors.yellowGold,
                            ),
                            SizedBox(height: constraints.maxHeight > 600 ? 16 : 8),
                            SizedBox(
                              width: constraints.maxWidth * 0.8,
                              child: Text(
                                "This confirmation code has been sent to the phone number ${widget.phoneNumber}. Please enter the 6 digit code to continue:",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.milk,
                                  fontSize: constraints.maxHeight > 600 ? 14 : 12,
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight > 600 ? 40 : 20),
                            _buildOtpFields(constraints),
                            SizedBox(height: constraints.maxHeight > 600 ? 30 : 20),
                            Text(
                              "Did not receive a code?",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.milk,
                                fontSize: constraints.maxHeight > 600 ? 14 : 12,
                              ),
                            ),
                            GestureDetector(
                              onTap: widget.onResend,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Resend Code",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.milk,
                                    fontSize: constraints.maxHeight > 600 ? 14 : 12,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: constraints.maxHeight > 600 ? 30 : 20),
                    _buildButtons(constraints),
                    SizedBox(height: constraints.maxHeight > 600 ? 20 : 10),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildOtpFields(BoxConstraints constraints) {
    double width = constraints.maxWidth > 300 ? 40 : 32;
    if (constraints.maxHeight < 500) {
      width = 28;
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return SizedBox(
          width: width,
          child: TextField(
            controller: _controllers[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: constraints.maxHeight > 600 ? 18 : 16,
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
              contentPadding: EdgeInsets.all(constraints.maxHeight > 600 ? 8 : 4),
            ),
            onChanged: (value) => _handleInputChange(index, value),
          ),
        );
      }),
    );
  }
  
  Widget _buildButtons(BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_showError)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              isCodeComplete ? "Invalid code. Please try again." : "Please fill in all fields.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.red[300],
                fontSize: constraints.maxHeight > 600 ? 14 : 12,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: constraints.maxHeight > 600 ? 48 : 40,
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
                      fontSize: constraints.maxHeight > 600 ? 14 : 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: constraints.maxHeight > 600 ? 48 : 40,
                child: ElevatedButton(
                  onPressed: _validateAndProceed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lighterGreen,
                  ),
                  child: Text(
                    "Confirm",
                    style: TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: constraints.maxHeight > 600 ? 14 : 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

