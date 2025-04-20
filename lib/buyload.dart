import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/network_button.dart';
import 'components/amount_button.dart';
import 'components/slide_to_confirm.dart';
import 'components/transaction_receipt.dart';
import 'package:verdantbank/account.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/authentication_otp.dart';
import 'theme/colors.dart';

class BuyLoadPage extends StatefulWidget {
  @override
  _BuyLoadPageState createState() => _BuyLoadPageState();
}

class _BuyLoadPageState extends State<BuyLoadPage> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();
  String? selectedNetwork;
  int currentStep = 0;
  String? selectedAmount;
  String? _numberErrorText;
  bool _showConfirmationSlider = false;
  double _sliderValue = 0.0;
  bool _showReceipt = false;
  String _transactionId = "";
  DateTime _transactionDateTime = DateTime.now();
  
  // User account information
  Account userAccount = Account(
    accFirstName: "Jeff",
    accLastName: "Mendez",
    accNumber: "1013 456 1234",
    accBalance: 50000.00,
    accPhoneNum: "+1234567890",
  );

  // Philippine mobile number validation
  bool _isValidPhilippineNumber(String? number) {
    if (number == null || number.isEmpty) return false;

    // Remove any spaces, dashes, or parentheses
    String cleanNumber = number.replaceAll(RegExp(r'[\s\-()]'), '');

    // Check for +63 format or local format (starts with 09)
    bool isValidFormat = RegExp(r'^(\+63|0)9\d{9}$').hasMatch(cleanNumber);

    return isValidFormat;
  }

  // Method to show the confirmation slider
  void _showSlideToConfirm() {
    // Validation for amount
    if ((selectedAmount == null || selectedAmount!.isEmpty) && 
        (_customAmountController.text.isEmpty)) {
      _showErrorSnackBar("Please select or enter an amount");
      return;
    }
    
    double? amount;
    if (selectedAmount != null) {
      amount = double.tryParse(selectedAmount!.replaceAll('₱', ''));
    } else if (_customAmountController.text.isNotEmpty) {
      amount = double.tryParse(_customAmountController.text);
    }
    
    if (amount == null || amount <= 0) {
      _showErrorSnackBar("Please enter a valid amount");
      return;
    }
    
    // Check if amount exceeds balance
    if (amount > userAccount.accBalance) {
      _showErrorSnackBar("Amount exceeds available balance");
      return;
    }
    
    // First verify the transaction with OTP
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPConfirmationScreen(
          phoneNumber: userAccount.accPhoneNum,
          otpCode: "123456", // In production, this would be generated and sent to the user
          onConfirm: () {
            // First pop the OTP screen
            Navigator.pop(context);
            
            // Then navigate to summary page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoadSummaryPage(
                  account: userAccount,
                  mobileNumber: _mobileNumberController.text,
                  network: selectedNetwork!,
                  amount: selectedAmount != null 
                    ? selectedAmount!
                    : "₱${_customAmountController.text}",
                ),
              ),
            );
          },
          onResend: () {
            // In a real app, this would trigger sending a new OTP
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("New OTP code sent")),
            );
          },
        ),
      ),
    );
  }

  // Helper method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper method to show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Execute load transaction
  void _executeLoadTransaction() {
    // Reset slider
    setState(() {
      _sliderValue = 0.0;
      _showConfirmationSlider = false;
    });
    
    // Generate transaction ID (simple implementation)
    _transactionId = "LD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";
    _transactionDateTime = DateTime.now();
    
    // Show receipt instead of just a success message
    setState(() {
      _showReceipt = true;
    });
    
    // You would replace this with actual SMS sending code
    // _sendLoadSMS();
  }

  // Method to close receipt and navigate back to main page
  void _closeReceiptAndReturn() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  // Method to handle network selection
  void _handleNetworkSelection(String network) {
    // Only proceed if mobile number is valid
    if (_isValidPhilippineNumber(_mobileNumberController.text)) {
      setState(() {
        selectedNetwork = network;
        currentStep = 1; // Go directly to amount selection step
      });
    } else {
      // Show an error or prevent network selection
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid Philippine mobile number first'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Method to handle amount selection
  void _handleAmountSelection(String amount) {
    setState(() {
      selectedAmount = amount;
      // Clear custom amount if a preset amount is selected
      _customAmountController.clear();
    });
  }

  // Method to handle slider changes
  void _handleSliderChange(double value) {
    setState(() {
      _sliderValue = value;
    });
    
    // When slider reaches the end, process transaction
    if (value >= 0.99) {
      _executeLoadTransaction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lighterGreen),
          onPressed: () {
            if (_showReceipt) {
              setState(() {
                _showReceipt = false;
              });
            } else if (_showConfirmationSlider) {
              setState(() {
                _showConfirmationSlider = false;
              });
            } else if (currentStep > 0) {
              setState(() {
                currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'LOAD',
          style: TextStyle(
            color: AppColors.lighterGreen,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: _showReceipt 
                  ? _buildReceipt()
                  : _buildCurrentStep(),
              ),
            ),
            // Show slider confirmation when needed
            if (_showConfirmationSlider) 
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SlideToConfirm(
                  sliderValue: _sliderValue,
                  onChanged: _handleSliderChange,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget? _buildActionButton() {
    if (_showReceipt) {
      return null; // No FAB when showing receipt
    } else if (currentStep == 1 && !_showConfirmationSlider) {
      return FloatingActionButton.extended(
        onPressed: _showSlideToConfirm,
        backgroundColor: AppColors.lighterGreen,
        label: Text(
          'Send Load',
          style: TextStyle(color: Colors.black),
        ),
        icon: Icon(Icons.send, color: Colors.black),
      );
    }
    return null;
  }

  // Method to build the receipt UI
  Widget _buildReceipt() {
    // Format transaction amount
    String amountText = selectedAmount ?? "₱${_customAmountController.text}";
    if (amountText.isEmpty || (!amountText.startsWith("₱") && selectedAmount == null)) {
      amountText = "₱${_customAmountController.text}";
    }
    
    return TransactionReceipt(
      transactionId: _transactionId,
      transactionDateTime: _transactionDateTime,
      selectedNetwork: selectedNetwork,
      mobileNumber: _mobileNumberController.text,
      amountText: amountText,
      onSave: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Receipt saved"), backgroundColor: Colors.green)
        );
      },
      onDone: _closeReceiptAndReturn,
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildNetworkSelectionStep();
      case 1:
        return _buildAmountSelectionStep();
      default:
        return Container();
    }
  }

  Widget _buildNetworkSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Card Display
        Text(
          'SOURCE',
          style: TextStyle(
            color: AppColors.yellowGold,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        CardIcon(
          savingAccountNum: userAccount.accNumber,
          accountBalance: userAccount.accBalance,
        ),
        SizedBox(height: 20),
        
        TextField(
          controller: _mobileNumberController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Mobile No. (e.g., 09171234567 or +639171234567)',
            hintStyle: TextStyle(color: AppColors.yellowGold),
            errorText: _numberErrorText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.lighterGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: AppColors.lighterGreen),
            ),
            filled: true,
            fillColor: AppColors.darkGreen,
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
          ],
          onChanged: (value) {
            setState(() {
              // Validate number on each change
              if (_isValidPhilippineNumber(value)) {
                _numberErrorText = null;
              } else {
                _numberErrorText = 'Invalid Philippine mobile number';
              }
            });
          },
        ),
        SizedBox(height: 30),
        Text(
          'Choose Network',
          style: TextStyle(
            color: AppColors.yellowGold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
          physics: NeverScrollableScrollPhysics(),
          children: [
            NetworkButton(
              network: 'SMART', 
              imagePath: 'assets/smart_logo.png', 
              bgColor: AppColors.lighterGreen,
              onTap: () => _handleNetworkSelection('SMART'),
            ),
            NetworkButton(
              network: 'TNT', 
              imagePath: 'assets/tnt_logo.png', 
              bgColor: AppColors.lighterGreen,
              onTap: () => _handleNetworkSelection('TNT'),
            ),
            NetworkButton(
              network: 'GLOBE', 
              imagePath: 'assets/globe_logo.png', 
              bgColor: AppColors.lighterGreen,
              onTap: () => _handleNetworkSelection('GLOBE'),
            ),
            NetworkButton(
              network: 'DITO', 
              imagePath: 'assets/dito_logo.png', 
              bgColor: AppColors.lighterGreen,
              onTap: () => _handleNetworkSelection('DITO'),
            ),
            NetworkButton(
              network: 'TM', 
              imagePath: 'assets/tm_logo.png', 
              bgColor: AppColors.lighterGreen,
              onTap: () => _handleNetworkSelection('TM'),
            ),
            NetworkButton(
              network: 'CHERRY\nPREPAID', 
              imagePath: 'assets/cherry_logo.png', 
              bgColor: AppColors.lighterGreen,
              onTap: () => _handleNetworkSelection('CHERRY PREPAID'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSelectionStep() {
    // Proceed to amount selection only if number is valid
    if (!_isValidPhilippineNumber(_mobileNumberController.text)) {
      // If somehow reached without valid number, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentStep = 0;
        });
      });
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Source account display
        Text(
          'SOURCE',
          style: TextStyle(
            color: AppColors.yellowGold,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        CardIcon(
          savingAccountNum: userAccount.accNumber,
          accountBalance: userAccount.accBalance,
        ),
        SizedBox(height: 20),
        
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.lighterGreen),
                ),
                child: Text(
                  _mobileNumberController.text.isNotEmpty ? _mobileNumberController.text : 'No number entered',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.lighterGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedNetwork ?? 'Network',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'Choose Amount',
          style: TextStyle(
            color: AppColors.yellowGold,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 15),
        Container(
          margin: EdgeInsets.only(bottom: 15),
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.lighterGreen),
          ),
          child: TextField(
            controller: _customAmountController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Custom Amount',
              hintStyle: TextStyle(color: Colors.white38),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          physics: NeverScrollableScrollPhysics(),
          children: [
            AmountButton(
              amount: '₱10',
              isSelected: selectedAmount == '₱10',
              onTap: () => _handleAmountSelection('₱10'),
            ),
            AmountButton(
              amount: '₱15',
              isSelected: selectedAmount == '₱15',
              onTap: () => _handleAmountSelection('₱15'),
            ),
            AmountButton(
              amount: '₱20',
              isSelected: selectedAmount == '₱20',
              onTap: () => _handleAmountSelection('₱20'),
            ),
            AmountButton(
              amount: '₱30',
              isSelected: selectedAmount == '₱30',
              onTap: () => _handleAmountSelection('₱30'),
            ),
            AmountButton(
              amount: '₱40',
              isSelected: selectedAmount == '₱40',
              onTap: () => _handleAmountSelection('₱40'),
            ),
            AmountButton(
              amount: '₱50',
              isSelected: selectedAmount == '₱50',
              onTap: () => _handleAmountSelection('₱50'),
            ),
            AmountButton(
              amount: '₱100',
              isSelected: selectedAmount == '₱100',
              onTap: () => _handleAmountSelection('₱100'),
            ),
            AmountButton(
              amount: '₱150',
              isSelected: selectedAmount == '₱150',
              onTap: () => _handleAmountSelection('₱150'),
            ),
            AmountButton(
              amount: '₱200',
              isSelected: selectedAmount == '₱200',
              onTap: () => _handleAmountSelection('₱200'),
            ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _customAmountController.dispose();
    super.dispose();
  }
}

// Add new LoadSummaryPage - similar to PayBillSlideConfirmPage
class LoadSummaryPage extends StatefulWidget {
  final Account account;
  final String mobileNumber;
  final String network;
  final String amount;

  const LoadSummaryPage({
    Key? key,
    required this.account,
    required this.mobileNumber,
    required this.network,
    required this.amount,
  }) : super(key: key);

  @override
  _LoadSummaryPageState createState() => _LoadSummaryPageState();
}

class _LoadSummaryPageState extends State<LoadSummaryPage> {
  double _sliderValue = 0.0;

  void _processLoadTransaction() {
    // Generate transaction ID
    final String transactionId = 'LD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final DateTime transactionDateTime = DateTime.now();
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoadReceiptPage(
          transactionId: transactionId,
          transactionDateTime: transactionDateTime,
          mobileNumber: widget.mobileNumber,
          network: widget.network,
          amount: widget.amount,
          account: widget.account,
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
          "Confirm Load",
          style: TextStyle(
            color: AppColors.yellowGold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Load Summary",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.yellowGold,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      _buildDetailRow("Network", widget.network),
                      _buildDetailRow("Mobile Number", widget.mobileNumber),
                      _buildDetailRow("Amount", widget.amount),
                      _buildDetailRow("From Account", widget.account.accNumber),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: AppColors.green.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline, color: AppColors.lighterGreen),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Slide to confirm your load purchase of ${widget.amount} for ${widget.mobileNumber} (${widget.network})",
                                style: TextStyle(
                                  color: AppColors.lighterGreen,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SlideToConfirm(
              sliderValue: _sliderValue,
              onChanged: (double value) {
                setState(() {
                  _sliderValue = value;
                  if (value >= 0.95) {
                    _processLoadTransaction();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// Add LoadReceiptPage - similar to PayBillReceiptPage
class LoadReceiptPage extends StatelessWidget {
  final String transactionId;
  final DateTime transactionDateTime;
  final String mobileNumber;
  final String network;
  final String amount;
  final Account account;

  const LoadReceiptPage({
    Key? key,
    required this.transactionId,
    required this.transactionDateTime,
    required this.mobileNumber,
    required this.network,
    required this.amount,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          "Load Receipt",
          style: TextStyle(
            color: AppColors.yellowGold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.05,
              vertical: MediaQuery.of(context).size.height * 0.02,
            ),
            child: TransactionReceipt(
              transactionId: transactionId,
              transactionDateTime: transactionDateTime,
              amountText: amount,
              mobileNumber: mobileNumber,
              selectedNetwork: network,
              sourceAccount: account.accNumber,
              onSave: () {
                // In a real app, this would save the receipt to device or send via email
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Receipt saved")),
                );
              },
              onDone: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ),
        ),
      ),
    );
  }
}
