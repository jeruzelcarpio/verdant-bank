import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verdantbank/account.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/slide_to_confirm.dart';
import 'package:verdantbank/components/transaction_receipt.dart';
import 'package:verdantbank/components/authentication_otp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme/colors.dart';

class TransferPage extends StatefulWidget {
  final Account account;
  final VoidCallback onUpdate;

  const TransferPage({Key? key, required this.account, required this.onUpdate})
      : super(key: key);

  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  void _openTransferWidget(String transferType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferWidget(
          account: widget.account,
          transferType: transferType,
          onUpdate: widget.onUpdate,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          'TRANSFER',
          style: TextStyle(
            color: AppColors.lighterGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "TRANSFER TO",
                  style: TextStyle(
                    color: AppColors.yellowGold,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                MenuButton(
                  bgColor: AppColors.lighterGreen,
                  buttonName: "Other Accounts",
                  icon: FontAwesomeIcons.creditCard,
                  onPressColor: AppColors.lightGreen,
                  onPressed: () => _openTransferWidget("Other Accounts"),
                ),
                SizedBox(width: 16),
                MenuButton(
                  bgColor: AppColors.lighterGreen,
                  buttonName: "Other Banks",
                  icon: FontAwesomeIcons.buildingColumns,
                  onPressColor: AppColors.lightGreen,
                  isActive: true,
                  onPressed: () => _openTransferWidget("Other Banks"),
                ),
                SizedBox(width: 16),
                MenuButton(
                  bgColor: AppColors.lighterGreen,
                  buttonName: "Savings",
                  icon: FontAwesomeIcons.piggyBank,
                  onPressColor: AppColors.lightGreen,
                  isActive: true,
                  onPressed: () => _openTransferWidget("Savings"),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class TransferWidget extends StatefulWidget {
  final Account account;
  final String transferType;
  final VoidCallback onUpdate;

  const TransferWidget({
    Key? key,
    required this.account,
    required this.transferType,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _TransferWidgetState createState() => _TransferWidgetState();
}

class _TransferWidgetState extends State<TransferWidget> {
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? _numberErrorText;
  bool _showConfirmationSlider = false;
  double _sliderValue = 0.0;
  bool _isTransactionInProgress = false; // Flag to prevent double execution

  // Method to show the confirmation slider
  void _showSlideToConfirm() {
    setState(() {
      _showConfirmationSlider = true;
      _sliderValue = 0.0; // Reset slider value when showing
    });
  }

  // Execute transfer transaction
  void _executeTransferTransaction() {
    if (_isTransactionInProgress) return; // Prevent multiple executions

    setState(() {
      _isTransactionInProgress = true; // Mark transaction as in progress
    });

    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorDialog("Please enter a valid amount.");
      setState(() {
        _isTransactionInProgress = false; // Reset flag
      });
      return;
    }
    if (amount > widget.account.accBalance) {
      _showErrorDialog("Amount exceeds available balance.");
      setState(() {
        _isTransactionInProgress = false; // Reset flag
      });
      return;
    }

    // Deduct the amount from the account balance
    setState(() {
      widget.account.accBalance -= amount;
      _sliderValue = 0.0;
      _showConfirmationSlider = false;

      // Call the onUpdate callback to update the main page
      widget.onUpdate();
    });

    // Navigate to OTP confirmation screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPConfirmationScreen(
          phoneNumber: widget.account.accPhoneNum,
          otpCode: "123456", // Example OTP code
          onConfirm: () => _navigateToReceipt(amount),
          onResend: () {
            print("OTP Resent");
          },
        ),
      ),
    ).then((_) {
      // Reset the transaction flag when returning to this screen
      setState(() {
        _isTransactionInProgress = false;
      });
    });
  }

  // Navigate to the transaction receipt screen
  void _navigateToReceipt(double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.darkGreen,
            body: SingleChildScrollView( // Allows scrolling if content overflows
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TransactionReceipt(
                  transactionId: "TR-${DateTime.now().millisecondsSinceEpoch}",
                  transactionDateTime: DateTime.now(),
                  amountText: "₱${amount.toStringAsFixed(2)}",
                  selectedNetwork: null,
                  mobileNumber: null,
                  merchant: null,
                  sourceAccount: widget.account.accNumber,
                  destinationAccount: accountNumberController.text,
                  onSave: () {
                    print("Receipt saved!");
                  },
                  onDone: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          "TRANSFER",
          style: TextStyle(
            color: AppColors.yellowGold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        centerTitle: true,
      ),
      body: SafeArea(
        child:
        SingleChildScrollView(
          child:
          Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SOURCE',
                      style: TextStyle(
                        color: AppColors.yellowGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    CardIcon(
                      savingAccountNum: widget.account.accNumber,
                      accountBalance: widget.account.accBalance,
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: AppColors.green,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DESTINATION',
                              style: TextStyle(
                                color: AppColors.yellowGold,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 30),
                            TextField(
                              controller: accountNumberController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                hintText: 'Account No.',
                                hintStyle: TextStyle(color: AppColors.lighterGreen),
                                errorText: _numberErrorText,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Color(0xFFC1FD52)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Color(0xFFC1FD52)),
                                ),
                                filled: true,
                                fillColor: AppColors.green,
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                              ],
                            ),
                            SizedBox(height: 30),
                            TextField(
                              controller: amountController,
                              style: TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(20),
                                hintText: 'Amount',
                                hintStyle: TextStyle(color: AppColors.lighterGreen),
                                errorText: _numberErrorText,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Color(0xFFC1FD52)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(color: Color(0xFFC1FD52)),
                                ),
                                filled: true,
                                fillColor: AppColors.green,
                              ),
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Remarks',
                              style: TextStyle(
                                color: AppColors.lighterGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            SizedBox(
                              height: 88,
                              child: TextField(
                                controller: remarksController,
                                style: TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  counterText: "",
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFFC1FD52)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Color(0xFFC1FD52)),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.green,
                                ),
                                keyboardType: TextInputType.multiline,
                                maxLines: 4,
                                maxLength: 256,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
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
                        SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _showSlideToConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.lighterGreen,
                            ),
                            child: Text(
                              "Transfer",
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
              if (_showConfirmationSlider)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideToConfirm(
                    sliderValue: _sliderValue,
                    onChanged: (value) {
                      setState(() {
                        _sliderValue = value;
                      });
                      if (value >= 0.99) {
                        _executeTransferTransaction();
                      }
                    },
                  ),
                ),
            ],
          ),
        ),

      ),
    );
  }
}