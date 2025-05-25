import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:verdantbank/models/account.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/slide_to_confirm.dart';
import 'package:verdantbank/components/transaction_receipt.dart';
import 'package:verdantbank/components/authentication_otp.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // Aliased import
import 'package:verdantbank/api/firestore.dart';
import 'package:verdantbank/api/send_otp.dart';
import 'package:verdantbank/transfer_other_banks.dart';

class TransferOtherBanksPage extends StatefulWidget {
  final Account account;
  final VoidCallback onUpdate;

  const TransferOtherBanksPage({Key? key, required this.account, required this.onUpdate}) : super(key: key);

  @override
  State<TransferOtherBanksPage> createState() => _TransferOtherBanksPageState();
}

class _TransferOtherBanksPageState extends State<TransferOtherBanksPage> {
  String? selectedBank;
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  final List<String> banks = [
    'BPI',
    'BDO Unibank',
    'Metrobank',
    'Landbank',
    'Security Bank',
  ];

  static const double transferFee = 25.0;
  bool _isTransactionInProgress = false;

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

  void _startTransfer() async {
    if (_isTransactionInProgress) return;

    final amount = double.tryParse(amountController.text);
    if (selectedBank == null || accountNumberController.text.isEmpty || amount == null || amount <= 0) {
      _showErrorDialog("Please fill all fields and enter a valid amount.");
      return;
    }
    final totalAmount = amount + transferFee;
    if (totalAmount > widget.account.accBalance) {
      _showErrorDialog("Insufficient balance for transfer and fee.");
      return;
    }

    setState(() => _isTransactionInProgress = true);

    final otp = generateOtp();
    await sendOtpToEmail(widget.account.accEmail, otp);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPConfirmationScreen(
          email: widget.account.accEmail,
          onSuccess: () async {
            try {
              final senderQuery = await firestore.FirebaseFirestore.instance
                  .collection('accounts')
                  .where('accNumber', isEqualTo: widget.account.accNumber)
                  .get();
              if (senderQuery.docs.isEmpty) throw Exception("Sender not found.");
              final senderRef = senderQuery.docs.first.reference;

              await firestore.FirebaseFirestore.instance.runTransaction((transaction) async {
                transaction.update(senderRef, {
                  'accBalance': firestore.FieldValue.increment(-totalAmount),
                });
              });

              // Create the transaction and get its reference
              final transactionRef = await firestore.FirebaseFirestore.instance.collection('transactions').add({
                'type': 'Transfer to Other Bank',
                'sourceAccount': widget.account.accNumber,
                'destinationAccount': accountNumberController.text,
                'bank': selectedBank,
                'dateTime': firestore.FieldValue.serverTimestamp(),
                'amount': amount,
                'fee': transferFee,
                'accounts': [widget.account.accNumber], // Add this line
              });

              setState(() {
                widget.account.accBalance -= totalAmount;
                widget.onUpdate();
              });

              // Show receipt
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SafeArea(
                    child: Scaffold(
                      backgroundColor: AppColors.darkGreen,
                      body: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: TransactionReceipt(
                            transactionId: transactionRef.id,
                            transactionDateTime: DateTime.now(),
                            amountText: "₱${amount.toStringAsFixed(2)}",
                            selectedNetwork: null,
                            mobileNumber: null,
                            merchant: null,
                            sourceAccount: widget.account.accNumber,
                            sourceAccountName: "${widget.account.accFirstName} ${widget.account.accLastName}",
                            destinationAccount: accountNumberController.text,
                            destinationAccountName: selectedBank,
                            onSave: () {},
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
            } catch (e) {
              _showErrorDialog("Failed to process transaction: $e");
            } finally {
              setState(() => _isTransactionInProgress = false);
            }
          },
          onResend: () async {
            final newOtp = generateOtp();
            await sendOtpToEmail(widget.account.accEmail, newOtp);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Your OTP code is: $newOtp')),
            );
          },
        ),
      ),
    ).then((_) => setState(() => _isTransactionInProgress = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lighterGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('TRANSFER', style: TextStyle(color: AppColors.lighterGreen)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 40),
          child: Padding(
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
                        Text('Select Bank', style: TextStyle(color: AppColors.lighterGreen, fontWeight: FontWeight.w600, fontSize: 14)),
                        SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: selectedBank,
                          hint: Text('Choose Bank', style: TextStyle(fontSize: 14, color: AppColors.lighterGreen),),
                          items: banks.map((bank) => DropdownMenuItem(value: bank, child: Text(bank))).toList(),
                          onChanged: (value) => setState(() => selectedBank = value),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: AppColors.lighterGreen, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: AppColors.lighterGreen, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.green,
                          ),
                          dropdownColor: AppColors.green,
                          style: TextStyle(color: AppColors.lighterGreen),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: accountNumberController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            hintText: 'Account No.',
                            hintStyle: TextStyle(
                              color: AppColors.lighterGreen,
                              fontFamily: 'WorkSans',
                              fontSize: 14,
                            ),
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
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: amountController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(20),
                            hintText: 'Amount',
                            hintStyle: TextStyle(
                              color: AppColors.lighterGreen,
                              fontFamily: 'WorkSans',
                              fontSize: 14,
                            ),
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
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Transfer Fee: ₱${transferFee.toStringAsFixed(2)}',
                          style: TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.w600),
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
                          backgroundColor: AppColors.lightGreen,
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
                        onPressed: _startTransfer,
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
        ),
      ),
    );
  }
}