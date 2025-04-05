import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verdantbank/account.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'package:verdantbank/components/card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme/colors.dart';

class TransferPage extends StatefulWidget {
  @override
  _TransferPageState createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  Account userAccount = Account(
    accFirstName: "Jeff",
    accLastName: "Mendez",
    accNumber: "1013 456 1234",
    accBalance: 50000.00,
  );

  void _openTransferWidget(String transferType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransferWidget(
          account: userAccount,
          transferType: transferType,
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
      body:
      Padding(padding: EdgeInsets.all(40),
        child:
          Column(
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
            SizedBox(height: 20,),
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

  const TransferWidget({
    Key? key,
    required this.account,
    required this.transferType,
  }) : super(key: key);

  @override
  _TransferWidgetState createState() => _TransferWidgetState();
}

class _TransferWidgetState extends State<TransferWidget> {
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  String? _numberErrorText;

  void _transfer() {
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
        builder: (context) => TransferConfirmationPage(
          transferType: widget.transferType,
          accountNumber: accountNumberController.text,
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
          "TRANSFER",
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
              child:
              Padding(padding: EdgeInsets.all(20),
                  child:
                  Column(
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
                        height: 88, // Makes the field visually larger
                        child: TextField(
                          controller: remarksController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            counterText: "", // Hides the default character counter
                            errorText: _numberErrorText,
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
                  )
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context), // Navigates back
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen,
                      side: BorderSide(color: AppColors.lighterGreen), // Border color
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
                SizedBox(width: 16), // Adds spacing between the buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: _transfer, // Calls the transfer function
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lighterGreen,

                    ),
                    child: Text(
                      "Transfer",
                      style: TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 14,// Ensures text is visible on the green button
                      ),
                    ),
                  ),
                ),
              ],
            )






          ],
        ),
      ),
    );
  }
}

class TransferConfirmationPage extends StatelessWidget {
  final String transferType;
  final String accountNumber;
  final double amount;
  final String remarks;

  const TransferConfirmationPage({
    Key? key,
    required this.transferType,
    required this.accountNumber,
    required this.amount,
    required this.remarks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transfer Confirmation"),
        backgroundColor: AppColors.darkGreen,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Transfer Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.yellowGold,
              ),
            ),
            SizedBox(height: 16),
            Text("Transfer Type: $transferType"),
            Text("Account Number: $accountNumber"),
            Text("Amount: \$${amount.toStringAsFixed(2)}"),
            Text("Remarks: $remarks"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightGreen,
              ),
              child: Text("Done"),
            ),
          ],
        ),
      ),
    );
  }
}