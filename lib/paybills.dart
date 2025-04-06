import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verdantbank/account.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'package:verdantbank/components/card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme/colors.dart';

class PaybillsPage extends StatefulWidget {
  @override
  _PaybillsPageState createState() => _PaybillsPageState();
}

class _PaybillsPageState extends State<PaybillsPage> {
  Account userAccount = Account(
    accFirstName: "Jeff",
    accLastName: "Mendez",
    accNumber: "1013 456 1234",
    accBalance: 50000.00,
  );

  void _openPayBillWidget(String billType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayBillWidget(
          account: userAccount,
          billType: billType,
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
      ),
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  "BILL CATEGORIES",
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
                  buttonName: "Utilities",
                  icon: FontAwesomeIcons.bolt,
                  onPressColor: AppColors.lightGreen,
                  onPressed: () => _openPayBillWidget("Utilities"),
                ),
                SizedBox(width: 16),
                MenuButton(
                  bgColor: AppColors.lighterGreen,
                  buttonName: "Credit Card",
                  icon: FontAwesomeIcons.creditCard,
                  onPressColor: AppColors.lightGreen,
                  isActive: true,
                  onPressed: () => _openPayBillWidget("Credit Card"),
                ),
                SizedBox(width: 16),
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
    );
  }
}

class PayBillWidget extends StatefulWidget {
  final Account account;
  final String billType;

  const PayBillWidget({
    Key? key,
    required this.account,
    required this.billType,
  }) : super(key: key);

  @override
  _PayBillWidgetState createState() => _PayBillWidgetState();
}

class _PayBillWidgetState extends State<PayBillWidget> {
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  String? selectedCompany;

  List<String> companies = [
    'Company 1',
    'Company 2',
    'Company 3',
    'Company 4',
    'Company 5',
  ];

  void _payBill() {
    if (selectedCompany == null) {
      _showErrorDialog("Please select a company.");
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

    // Navigate to confirmation page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PayBillConfirmationPage(
          billType: widget.billType,
          company: selectedCompany!,
          amount: amount,
          remarks: remarksController.text,
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
      ),
      body: Padding(
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
                      'BILL DETAILS',
                      style: TextStyle(
                        color: AppColors.yellowGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 30),
                    
                    // Dropdown for companies
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
                    SizedBox(height: 30),

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
                      keyboardType: TextInputType.phone,
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
    );
  }
}

class PayBillConfirmationPage extends StatelessWidget {
  final String billType;
  final String company;
  final double amount;
  final String remarks;

  const PayBillConfirmationPage({
    Key? key,
    required this.billType,
    required this.company,
    required this.amount,
    required this.remarks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          "Payment Confirmation",
          style: TextStyle(
            color: AppColors.yellowGold,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bill Payment Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.yellowGold,
              ),
            ),
            SizedBox(height: 16),
            Text("Bill Type: $billType", style: TextStyle(color: Colors.white)),
            Text("Company: $company", style: TextStyle(color: Colors.white)),
            Text("Amount: \$${amount.toStringAsFixed(2)}", style: TextStyle(color: Colors.white)),
            Text("Remarks: $remarks", style: TextStyle(color: Colors.white)),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.lighterGreen),
                  SizedBox(width: 8),
                  Text(
                    "Payment Successful",
                    style: TextStyle(
                      color: AppColors.lighterGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighterGreen,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: Text(
                  "Done",
                  style: TextStyle(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
