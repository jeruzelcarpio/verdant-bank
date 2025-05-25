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
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.lighterGreen),
          onPressed: () => Navigator.pop(context),
        ),
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

class _TransferWidgetState extends State<TransferWidget> with SingleTickerProviderStateMixin {
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  Map<String, String>? _confirmationInfo;
  String? _lastRecipientName;

  String? _numberErrorText;
  bool _showConfirmationSlider = false;
  double _sliderValue = 0.0;
  bool _isTransactionInProgress = false; // Flag to prevent double execution

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // Start off-screen (bottom)
      end: Offset(0, 0),   // End at original position
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }
  // Method to show the confirmation slider
  void _showSlideToConfirm() async {
    if (accountNumberController.text.isEmpty || amountController.text.isEmpty) {
      _showErrorDialog("Please enter both account number and amount.");
      return;
    }

    final recipientQuery = firestore.FirebaseFirestore.instance
        .collection('accounts')
        .where('accNumber', isEqualTo: accountNumberController.text);

    final recipientSnapshot = await recipientQuery.get();

    if (recipientSnapshot.docs.isEmpty) {
      _showErrorDialog("User not recognized.");
      return;
    }

    final recipientData = recipientSnapshot.docs.first.data();
    final recipientName = '${recipientData['accFirstName'] ?? ''} ${recipientData['accLastName'] ?? ''}';

    setState(() {
      _confirmationInfo = {
        'SOURCE': widget.account.accNumber,
        'DESTINATION': recipientName,
        'TRANSFER AMOUNT': '₱${amountController.text}',
      };
      _showConfirmationSlider = true;
      _sliderValue = 0.0;
    });
    _slideController.forward();
  }


  void _hideSlideToConfirm() {
    _slideController.reverse().then((_) {
      setState(() {
        _showConfirmationSlider = false;
      });
    });
  }

  // Execute transfer transaction
  void _executeTransferTransaction() async {
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

    if (accountNumberController.text.isEmpty) {
      _showErrorDialog("Please enter a valid account number.");
      setState(() {
        _isTransactionInProgress = false;
      });
      return;
    }

    if (accountNumberController.text == widget.account.accNumber) {
      _showErrorDialog("You cannot transfer to your own account.");
      setState(() {
        _isTransactionInProgress = false;
      });
      return;
    }

    try {
      final recipientQuery = firestore.FirebaseFirestore.instance
          .collection('accounts')
          .where('accNumber', isEqualTo: accountNumberController.text);

      final recipientSnapshot = await recipientQuery.get();

      if (recipientSnapshot.docs.isEmpty) {
        _showErrorDialog("User not recognized.");
        setState(() {
          _isTransactionInProgress = false;
          // Do NOT hide the slider here
        });
        return;
      }

      // Extract recipient details
      final recipientData = recipientSnapshot.docs.first.data();
      final recipientFirstName = recipientData['accFirstName'] ?? 'Unknown';
      final recipientLastName = recipientData['accLastName'] ?? 'Unknown';
      final recipientName = '$recipientFirstName $recipientLastName';
      _lastRecipientName = recipientName;

      if (recipientName.trim() == 'Unknown Unknown') {
        _showErrorDialog("Recipient name is missing in the account details.");
        setState(() {
          _isTransactionInProgress = false;
        });
        return;
      }
      // Navigate to OTP confirmation
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPConfirmationScreen(
            phoneNumber: widget.account.accPhoneNum,
            otpCode: "123456", // Example OTP code
              onConfirm: () async {
                try {
                  final recipientAccountRef = recipientSnapshot.docs.first.reference;

                  // Update balances atomically
                  await firestore.FirebaseFirestore.instance.runTransaction((transaction) async {
                    final senderAccountQuery = await firestore.FirebaseFirestore.instance
                        .collection('accounts')
                        .where('accNumber', isEqualTo: widget.account.accNumber)
                        .get();

                    if (senderAccountQuery.docs.isEmpty) {
                      throw Exception("Sender account not found.");
                    }

                    final senderAccountRef = senderAccountQuery.docs.first.reference;

                    transaction.update(senderAccountRef, {
                      'accBalance': firestore.FieldValue.increment(-amount),
                    });

                    transaction.update(recipientAccountRef, {
                      'accBalance': firestore.FieldValue.increment(amount),
                    });
                  });

                  // Now create the transaction document and get its reference
                  final transactionRef = await firestore.FirebaseFirestore.instance.collection('transactions').add({
                    'type': 'Transfer',
                    'sourceAccount': widget.account.accNumber,
                    'destinationAccount': accountNumberController.text,
                    'accounts': [widget.account.accNumber, accountNumberController.text],
                    'dateTime': firestore.FieldValue.serverTimestamp(),
                    'amount': amount,
                    'remarks': remarksController.text,
                  });

                  setState(() {
                    widget.account.accBalance -= amount;
                    _sliderValue = 0.0;
                    _showConfirmationSlider = false;
                    widget.onUpdate();
                  });

                  _navigateToReceipt(amount, transactionRef.id);
                } catch (e) {
                  _showErrorDialog("Failed to process transaction: $e");
                } finally {
                  setState(() {
                    _isTransactionInProgress = false;
                  });
                }
              },
            onResend: () {
              print("OTP Resent");
            },
          ),
        ),
      ).then((_) {
        setState(() {
          _isTransactionInProgress = false;
        });
      });
    } catch (e) {
      _showErrorDialog("Failed to process transaction: $e");
      setState(() {
        _isTransactionInProgress = false;
      });
    }
  }

  // Navigate to the transaction receipt screen
  void _navigateToReceipt(double amount, String transactionId) {
    final GlobalKey receiptKey = GlobalKey();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SafeArea(
          child: Scaffold(
            backgroundColor: AppColors.darkGreen,
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child:
                RepaintBoundary(
                  key: receiptKey, // Key for screenshot
                  child: TransactionReceipt(
                    transactionId: transactionId, // Use Firestore doc ID
                    transactionDateTime: DateTime.now(),
                    amountText: "₱${amount.toStringAsFixed(2)}",
                    selectedNetwork: null,
                    mobileNumber: null,
                    merchant: null,
                    sourceAccount: widget.account.accNumber,
                    sourceAccountName: "${widget.account.accFirstName} ${widget.account.accLastName}",
                    destinationAccount: accountNumberController.text,
                    destinationAccountName: _lastRecipientName,
                    onSave: () {
                      print("Receipt saved!");
                    },
                    onDone: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (route) => false,
                      );
                    },
                  ),
                )

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

  // Method to check recipient details
  Future<void> _checkRecipient(String accNumber) async {
    if (accNumber.isNotEmpty) {
      final recipientQuery = firestore.FirebaseFirestore.instance
          .collection('accounts')
          .where('accNumber', isEqualTo: accNumber);

      try {
        final recipientSnapshot = await recipientQuery.get();

        if (recipientSnapshot.docs.isNotEmpty) {
          // Recipient found, handle accordingly
        } else {
          // Recipient not found
        }
      } catch (e) {
        // Error handling
      }
    }
  }

  // Process the transfer - ensure this method is async
  Future<void> _processTransfer() async {
    double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      _showErrorDialog("Please enter a valid amount.");
      return;
    }
    if (amount > widget.account.accBalance) {
      _showErrorDialog("Amount exceeds available balance.");
      return;
    }

    if (accountNumberController.text.isEmpty) {
      _showErrorDialog("Please enter a valid account number.");
      return;
    }

    if (accountNumberController.text == widget.account.accNumber) {
      _showErrorDialog("You cannot transfer to your own account.");
      return;
    }

    try {
      final recipientQuery = firestore.FirebaseFirestore.instance
          .collection('accounts')
          .where('accNumber', isEqualTo: accountNumberController.text);

      final recipientSnapshot = await recipientQuery.get();

      if (recipientSnapshot.docs.isEmpty) {
        _showErrorDialog("User not recognized.");
        return;
      }

      // Extract recipient details
      final recipientData = recipientSnapshot.docs.first.data();
      final recipientFirstName = recipientData['accFirstName'] ?? 'Unknown';
      final recipientLastName = recipientData['accLastName'] ?? 'Unknown';
      final recipientName = '$recipientFirstName $recipientLastName';
      _lastRecipientName = recipientName;

      if (recipientName.trim() == 'Unknown Unknown') {
        _showErrorDialog("Recipient name is missing in the account details.");
        return;
      }

      // Proceed with the transaction
      final recipientAccountRef = recipientSnapshot.docs.first.reference;

      // Update balances atomically
      await firestore.FirebaseFirestore.instance.runTransaction((transaction) async {
        final senderAccountQuery = await firestore.FirebaseFirestore.instance
            .collection('accounts')
            .where('accNumber', isEqualTo: widget.account.accNumber)
            .get();

        if (senderAccountQuery.docs.isEmpty) {
          throw Exception("Sender account not found.");
        }

        final senderAccountRef = senderAccountQuery.docs.first.reference;

        transaction.update(senderAccountRef, {
          'accBalance': firestore.FieldValue.increment(-amount),
        });

        transaction.update(recipientAccountRef, {
          'accBalance': firestore.FieldValue.increment(amount),
        });
      });

      // Now create the transaction document and get its reference
      final transactionRef = await firestore.FirebaseFirestore.instance.collection('transactions').add({
        'type': 'Transfer',
        'sourceAccount': widget.account.accNumber,
        'destinationAccount': accountNumberController.text,
        'accounts': [widget.account.accNumber, accountNumberController.text],
        'dateTime': firestore.FieldValue.serverTimestamp(),
        'amount': amount,
        'remarks': remarksController.text,
      });

      setState(() {
        widget.account.accBalance -= amount;
        _sliderValue = 0.0;
        _showConfirmationSlider = false;
        widget.onUpdate();
      });

      _navigateToReceipt(amount, transactionRef.id);
    } catch (e) {
      _showErrorDialog("Failed to process transaction: $e");
    }
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
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (_showConfirmationSlider) {
              _hideSlideToConfirm();
            }
          },
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 180),
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
              ),
              if (_showConfirmationSlider)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: AnimatedBuilder(
                    animation: _slideController,
                    builder: (context, child) {
                      return SlideTransition(
                        position: _slideAnimation,
                        child: Material(
                          color: Colors.transparent,
                          elevation: 8,
                          child: SlideToConfirm(
                            sliderValue: _sliderValue,
                            onChanged: (value) {
                              setState(() {
                                _sliderValue = value;
                              });
                              if (value >= 0.99) {
                                _executeTransferTransaction();
                                _hideSlideToConfirm();
                              }
                            },
                            info: _confirmationInfo ?? {},
                          ),
                        ),
                      );
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