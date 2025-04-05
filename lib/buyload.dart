import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'components/network_button.dart';
import 'components/amount_button.dart';
import 'components/slide_to_confirm.dart';
import 'components/transaction_receipt.dart';

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
    setState(() {
      _showConfirmationSlider = true;
      _sliderValue = 0.0; // Reset slider value when showing
    });
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
      backgroundColor: Color(0xFF0A1922),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1922),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFC1FD52)),
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
            color: Color(0xFFC1FD52),
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
        backgroundColor: Color(0xFFC1FD52),
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
        SizedBox(height: 15),
        TextField(
          controller: _mobileNumberController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Mobile No. (e.g., 09171234567 or +639171234567)',
            hintStyle: TextStyle(color: Color(0xFFFFD700)),
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
            fillColor: Color(0xFF0A1922),
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
            color: Color(0xFFFFD700),
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
              bgColor: Color(0xFFC1FD52),
              onTap: () => _handleNetworkSelection('SMART'),
            ),
            NetworkButton(
              network: 'TNT', 
              imagePath: 'assets/tnt_logo.png', 
              bgColor: Color(0xFFC1FD52),
              onTap: () => _handleNetworkSelection('TNT'),
            ),
            NetworkButton(
              network: 'GLOBE', 
              imagePath: 'assets/globe_logo.png', 
              bgColor: Color(0xFFC1FD52),
              onTap: () => _handleNetworkSelection('GLOBE'),
            ),
            NetworkButton(
              network: 'DITO', 
              imagePath: 'assets/dito_logo.png', 
              bgColor: Color(0xFFC1FD52),
              onTap: () => _handleNetworkSelection('DITO'),
            ),
            NetworkButton(
              network: 'TM', 
              imagePath: 'assets/tm_logo.png', 
              bgColor: Color(0xFFC1FD52),
              onTap: () => _handleNetworkSelection('TM'),
            ),
            NetworkButton(
              network: 'CHERRY\nPREPAID', 
              imagePath: 'assets/cherry_logo.png', 
              bgColor: Color(0xFFC1FD52),
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
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Color(0xFFC1FD52)),
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
                color: Color(0xFFC1FD52),
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
            color: Color(0xFFFFD700),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 15),
        Container(
          margin: EdgeInsets.only(bottom: 15),
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Color(0xFFC1FD52)),
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
