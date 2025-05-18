import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'components/network_button.dart';
import 'components/amount_button.dart';
import 'components/slide_to_confirm.dart';
import 'components/transaction_receipt.dart';
import 'package:verdantbank/models/account.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/authentication_otp.dart';
import 'theme/colors.dart';
import 'main.dart'; // Import userAccount

class BuyLoadPage extends StatefulWidget {
  final Account userAccount; // Add userAccount parameter
  final VoidCallback? onUpdate;

  const BuyLoadPage({Key? key, required this.userAccount, this.onUpdate}) : super(key: key);

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
  bool _isTransactionInProgress = false;

  // Philippine mobile number validation
  bool _isValidPhilippineNumber(String? number) {
    if (number == null || number.isEmpty) return false;
    String cleanNumber = number.replaceAll(RegExp(r'[\s\-()]'), '');
    return RegExp(r'^(\+63|0)9\d{9}$').hasMatch(cleanNumber);
  }

  void _showSlideToConfirm() {
    if (selectedNetwork == null) {
      _showErrorSnackBar("Please select a network.");
      return;
    }
    if (!_isValidPhilippineNumber(_mobileNumberController.text)) {
      _showErrorSnackBar("Please enter a valid Philippine mobile number.");
      return;
    }
    double? amount = _getSelectedAmount();
    if (amount == null || amount <= 0) {
      _showErrorSnackBar("Please select or enter a valid amount.");
      return;
    }
    if (amount > widget.userAccount.accBalance) {
      _showErrorSnackBar("Amount exceeds available balance.");
      return;
    }
    setState(() {
      _showConfirmationSlider = true;
      _sliderValue = 0.0;
    });
  }

  double? _getSelectedAmount() {
    if (selectedAmount != null) {
      return double.tryParse(selectedAmount!.replaceAll('₱', ''));
    } else if (_customAmountController.text.isNotEmpty) {
      return double.tryParse(_customAmountController.text);
    }
    return null;
  }

  void _executeLoadTransaction() {
    if (_isTransactionInProgress) return;
    setState(() {
      _isTransactionInProgress = true;
    });

    double amount = _getSelectedAmount()!;
    setState(() {
      widget.userAccount.accBalance -= amount;
      _sliderValue = 0.0;
      _showConfirmationSlider = false;
    });

    /*
    widget.userAccount.addTransaction(
      Transaction(
        type: "Bought Load",
        recipient: _mobileNumberController.text + " (${selectedNetwork!})",
        dateTime: _getCurrentDateTimeString(),
        amount: amount,
        isAdded: false,
      ),
    );
    */


    if (widget.onUpdate != null) widget.onUpdate!();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPConfirmationScreen(
          phoneNumber: widget.userAccount.accPhoneNum,
          otpCode: "123456",
          onConfirm: () {
            Navigator.pop(context);
            _navigateToReceipt(amount);
          },
          onResend: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("New OTP code sent")),
            );
          },
        ),
      ),
    ).then((_) {
      setState(() {
        _isTransactionInProgress = false;
      });
    });
  }

  void _navigateToReceipt(double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadReceiptPage(
          mobileNumber: _mobileNumberController.text,
          network: selectedNetwork!,
          amount: amount,
          account: widget.userAccount,
        ),
      ),
    );
  }

  String _getCurrentDateTimeString() {
    final now = DateTime.now();
    return "${_getMonthAbbr(now.month)} ${now.day}, ${now.year}, ${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
  }

  String _getMonthAbbr(int month) {
    const months = [
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];
    return months[month - 1];
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleNetworkSelection(String network) {
    if (_isValidPhilippineNumber(_mobileNumberController.text)) {
      setState(() {
        selectedNetwork = network;
        currentStep = 1;
      });
    } else {
      _showErrorSnackBar('Please enter a valid Philippine mobile number first');
    }
  }

  void _handleAmountSelection(String amount) {
    setState(() {
      selectedAmount = amount;
      _customAmountController.clear();
    });
  }

  void _handleSliderChange(double value) {
    setState(() {
      _sliderValue = value;
    });
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
            if (_showConfirmationSlider) {
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
                child: _buildCurrentStep(),
              ),
            ),
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
    if (currentStep == 1 && !_showConfirmationSlider) {
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
          savingAccountNum: widget.userAccount.accNumber,
          accountBalance: widget.userAccount.accBalance,
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
    if (!_isValidPhilippineNumber(_mobileNumberController.text)) {
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
          savingAccountNum: widget.userAccount.accNumber,
          accountBalance: widget.userAccount.accBalance,
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
            onChanged: (val) {
              setState(() {
                selectedAmount = null;
              });
            },
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

class LoadReceiptPage extends StatelessWidget {
  final String mobileNumber;
  final String network;
  final double amount;
  final Account account;

  const LoadReceiptPage({
    Key? key,
    required this.mobileNumber,
    required this.network,
    required this.amount,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String transactionId = 'LD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final DateTime transactionDateTime = DateTime.now();

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
              amountText: "₱${amount.toStringAsFixed(2)}",
              mobileNumber: mobileNumber,
              selectedNetwork: network,
              sourceAccount: account.accNumber,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Receipt saved")),
                );
              },
              onDone: () {
                // Modified: Navigate to home page (first route) instead of login page
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ),
      ),
    );
  }
}