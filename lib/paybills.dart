import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verdantbank/models/account.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/authentication_otp.dart';
import 'package:verdantbank/components/slide_to_confirm.dart';
import 'package:verdantbank/components/transaction_receipt.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme/colors.dart';
import 'main.dart'; // <-- Import userAccount


class PaybillsPage extends StatefulWidget {
  final Account userAccount; // Add userAccount parameter
  final VoidCallback? onUpdate;

  const PaybillsPage({Key? key, required this.userAccount, this.onUpdate}) : super(key: key);

  @override
  _PaybillsPageState createState() => _PaybillsPageState();
}

class _PaybillsPageState extends State<PaybillsPage> {
  void _openPayBillWidget(String billType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayBillWidget(
          account: widget.userAccount, // Use widget.userAccount
          billType: billType,
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
          'PAY BILLS',
          style: TextStyle(
            color: AppColors.lighterGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lighterGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.05,
            vertical: MediaQuery.of(context).size.height * 0.02,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "BILL CATEGORIES",
                style: TextStyle(
                  color: AppColors.yellowGold,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  MenuButton(
                    bgColor: AppColors.lighterGreen,
                    buttonName: "Utilities",
                    icon: FontAwesomeIcons.bolt,
                    onPressColor: AppColors.lightGreen,
                    onPressed: () => _openPayBillWidget("Utilities"),
                  ),
                  MenuButton(
                    bgColor: AppColors.lighterGreen,
                    buttonName: "Credit Card",
                    icon: FontAwesomeIcons.creditCard,
                    onPressColor: AppColors.lightGreen,
                    isActive: true,
                    onPressed: () => _openPayBillWidget("Credit Card"),
                  ),
                  MenuButton(
                    bgColor: AppColors.lighterGreen,
                    buttonName: "Internet",
                    icon: FontAwesomeIcons.wifi,
                    onPressColor: AppColors.lightGreen,
                    isActive: true,
                    onPressed: () => _openPayBillWidget("Internet"),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PayBillWidget extends StatefulWidget {
  final Account account;
  final String billType;
  final VoidCallback? onUpdate;

  const PayBillWidget({
    Key? key,
    required this.account,
    required this.billType,
    this.onUpdate,
  }) : super(key: key);

  @override
  _PayBillWidgetState createState() => _PayBillWidgetState();
}

class _PayBillWidgetState extends State<PayBillWidget> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  String? selectedCompany;

  List<String> companies = [
    'MERALCO',
    'MAYNILAD',
    'PLDT',
    'GLOBE',
    'SMART',
  ];

  void _payBill() {
    if (selectedCompany == null || selectedCompany!.isEmpty) {
      _showErrorDialog("Please select a company.");
      return;
    }
    if (amountController.text.isEmpty) {
      _showErrorDialog("Please enter an amount.");
      return;
    }
    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorDialog("Please enter a valid amount.");
      return;
    }
    if (amount > widget.account.accBalance) {
      _showErrorDialog("Amount exceeds available balance.");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPConfirmationScreen(
          phoneNumber: widget.account.accPhoneNum,
          otpCode: "123456",
          onConfirm: () {
            Navigator.pop(context);
            final double amount = double.parse(amountController.text);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PayBillSlideConfirmPage(
                  billType: widget.billType,
                  company: selectedCompany!,
                  amount: amount,
                  remarks: remarksController.text,
                  account: widget.account,
                  onUpdate: widget.onUpdate,
                ),
              ),
            );
          },
          onResend: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("New OTP code sent")),
            );
          },
        ),
      ),
    );
  }

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final verticalPadding = screenHeight * 0.02;

    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          "PAY BILLS",
          style: TextStyle(
            color: AppColors.yellowGold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lighterGreen),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
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
                    padding: EdgeInsets.all(screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BILL DETAILS',
                          style: TextStyle(
                            color: AppColors.yellowGold,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Color(0xFFC1FD52)),
                            color: AppColors.green,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                'Select Company',
                                style: TextStyle(color: AppColors.lighterGreen),
                              ),
                              value: selectedCompany,
                              dropdownColor: AppColors.green,
                              icon: Icon(Icons.arrow_drop_down, color: AppColors.lighterGreen),
                              style: TextStyle(color: Colors.white),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCompany = newValue;
                                });
                              },
                              items: companies.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        TextField(
                          controller: amountController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            hintText: 'Amount',
                            hintStyle: TextStyle(color: AppColors.lighterGreen),
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
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
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
                        Container(
                          height: screenHeight * 0.10,
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
                        onPressed: _payBill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lighterGreen,
                        ),
                        child: Text(
                          "Pay Bill",
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
        ),
      ),
    );
  }
}

class PayBillSlideConfirmPage extends StatefulWidget {
  final String billType;
  final String company;
  final double amount;
  final String remarks;
  final Account account;
  final VoidCallback? onUpdate;

  const PayBillSlideConfirmPage({
    Key? key,
    required this.billType,
    required this.company,
    required this.amount,
    required this.remarks,
    required this.account,
    this.onUpdate,
  }) : super(key: key);

  @override
  _PayBillSlideConfirmPageState createState() => _PayBillSlideConfirmPageState();
}

class _PayBillSlideConfirmPageState extends State<PayBillSlideConfirmPage> {
  double _sliderValue = 0.0;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          "Confirm Payment",
          style: TextStyle(
            color: AppColors.yellowGold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lighterGreen),
          onPressed: () => Navigator.pop(context),
        ),
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
                        "Payment Summary",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.yellowGold,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      _buildDetailRow("Bill Type", widget.billType),
                      _buildDetailRow("Provider", widget.company),
                      _buildDetailRow("Amount", "₱${widget.amount.toStringAsFixed(2)}"),
                      if (widget.remarks.isNotEmpty)
                        _buildDetailRow("Remarks", widget.remarks),
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
                                "Slide to confirm your payment of ₱${widget.amount.toStringAsFixed(2)} to ${widget.company}",
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
                });
                if (value >= 0.99 && !_isProcessing) {
                  _processPayment();
                }
              },
              info: {},
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

  void _processPayment() {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
    });

    /*
    widget.account.addTransaction(
      Transaction(
        type: "Sent To",
        recipient: widget.company,
        dateTime: _getCurrentDateTimeString(),
        amount: widget.amount,
        isAdded: false,
      ),
    );

     */
    if (widget.onUpdate != null) widget.onUpdate!();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => PayBillReceiptPage(
          billType: widget.billType,
          company: widget.company,
          amount: widget.amount,
          remarks: widget.remarks,
          account: widget.account,
        ),
      ),
    );
  }

  String _getCurrentDateTimeString() {
    final now = DateTime.now();
    const months = [
      "JAN", "FEB", "MAR", "APR", "MAY", "JUN",
      "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"
    ];
    return "${months[now.month - 1]} ${now.day}, ${now.year}, ${now.hour}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
  }
}

class PayBillReceiptPage extends StatelessWidget {
  final String billType;
  final String company;
  final double amount;
  final String remarks;
  final Account account;

  const PayBillReceiptPage({
    Key? key,
    required this.billType,
    required this.company,
    required this.amount,
    required this.remarks,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String transactionId = 'TR${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final DateTime transactionDateTime = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          "Payment Receipt",
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
              merchant: company,
              sourceAccount: account.accNumber,
              onSave: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Receipt saved")),
                );
              },
              onDone: () {
                // Navigate to homepage instead of popping to first route
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(userAccount: account), // Use 'account' instead of 'widget.userAccount'
                  ),
                      (route) => false,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}