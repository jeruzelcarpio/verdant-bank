import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:verdantbank/theme/colors.dart';
import 'models/account.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:verdantbank/utils/date_utils.dart';
import 'package:async/async.dart';





class TransactionsPage extends StatelessWidget {
final Account account;

TransactionsPage({required this.account});



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
    body: Container(
      margin: const EdgeInsets.all(40), // Optional: space between border and screen edge
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.green,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(16), // Optional: rounded corners
        color: Colors.white, // Or your preferred background
      ),
      child: StreamBuilder<List<firestore.QuerySnapshot>>(
        stream: StreamZip([
          firestore.FirebaseFirestore.instance
              .collection('transactions')
              .where('accounts', arrayContains: account.accNumber)
              .orderBy('dateTime', descending: true)
              .snapshots(),
          firestore.FirebaseFirestore.instance
              .collection('crypto_transactions')
              .where('accounts', arrayContains: account.accNumber)
              .orderBy('timestamp', descending: true)
              .snapshots(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading transactions.'));
          }
          final regularDocs = snapshot.data![0].docs;
          final cryptoDocs = snapshot.data![1].docs;
          print('Crypto docs data: ${cryptoDocs.map((d) => d.data())}');
          print('Regular docs: ${regularDocs.length}');
          print('Crypto docs: ${cryptoDocs.length}');

          final allDocs = [
            ...regularDocs.map((doc) => {'data': doc.data() as Map<String, dynamic>, 'isCrypto': false}),
            ...cryptoDocs.map((doc) => {'data': doc.data() as Map<String, dynamic>, 'isCrypto': true}),
          ];

          // Sort allDocs by timestamp/dateTime descending
          allDocs.sort((a, b) {
            final aIsCrypto = a['isCrypto'] == true;
            final bIsCrypto = b['isCrypto'] == true;
            final Map<String, dynamic> aData = a['data'] as Map<String, dynamic>;
            final Map<String, dynamic> bData = b['data'] as Map<String, dynamic>;
            final aTime = aIsCrypto
                ? (aData['timestamp'] as Timestamp?)?.toDate()
                : (aData['dateTime'] as Timestamp?)?.toDate();
            final bTime = bIsCrypto
                ? (bData['timestamp'] as Timestamp?)?.toDate()
                : (bData['dateTime'] as Timestamp?)?.toDate();
            return (bTime ?? DateTime(0)).compareTo(aTime ?? DateTime(0));
          });

          if (allDocs.isEmpty) {
            return Center(child: Text('No transactions found.'));
          }

          return ListView.builder(
            itemCount: allDocs.length,
            itemBuilder: (context, index) {
              final tx = allDocs[index];
              final data = tx['data'] as Map<String, dynamic>;
              final isCrypto = tx['isCrypto'] as bool;

              if (isCrypto) {
                final DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                final double amount = (data['amount'] is num) ? (data['amount'] as num).toDouble() : 0.0;
                final double cryptoAmount = (data['cryptoAmount'] is num) ? (data['cryptoAmount'] as num).toDouble() : 0.0;
                return ListTile(
                  leading: Icon(Icons.currency_bitcoin, color: AppColors.green),
                  title: Text(
                    data['type']?.toString() ?? 'Crypto Transaction',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'From: ${data['sourceAccount']?.toString() ?? ""} To: ${data['destinationAccount']?.toString() ?? ""}\n'
                        'Amount: PHP ${amount.toStringAsFixed(2)} | Crypto: $cryptoAmount',
                  ),
                  trailing: Text(
                    DateFormat('MMM dd, yyyy, hh:mm a').format(date),
                    style: TextStyle(fontSize: 12),
                  ),
                );
              } else {
                // Regular transaction display (reuse your TransactionRow)
                String destinationName = '';
                if (data['type'] == 'Transfer to Other Bank') {
                  destinationName = data['bank'] ?? '';
                } else {
                  final firstName = data['destinationFirstName'] ?? '';
                  final lastName = data['destinationLastName'] ?? '';
                  destinationName = (firstName + ' ' + lastName).trim();
                }
                String dateString = '';
                final dateTime = data['dateTime'];
                if (dateTime is Timestamp) {
                  dateString = formatToLocal(dateTime.toDate());
                } else if (dateTime is String) {
                  dateString = dateTime;
                }
                double amount = 0.0;
                if (data['type'] == 'Transfer to Other Bank' && data['totalAmount'] != null) {
                  amount = (data['totalAmount'] as num).toDouble();
                } else if (data['amount'] is int) {
                  amount = (data['amount'] as int).toDouble();
                } else if (data['amount'] is double) {
                  amount = data['amount'];
                }
                return FutureBuilder<firestore.QuerySnapshot>(
                  future: firestore.FirebaseFirestore.instance
                      .collection('accounts')
                      .where('accNumber', isEqualTo: data['destinationAccount'])
                      .get(),
                  builder: (context, snapshot) {
                    String destName = "Unknown Account";
                    if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                      final accData = snapshot.data!.docs.first.data() as Map<String, dynamic>;
                      final first = accData['accFirstName'] ?? '';
                      final last = accData['accLastName'] ?? '';
                      final combined = (first + ' ' + last).trim();
                      if (combined.isNotEmpty) {
                        destName = combined;
                      }
                    }
                    final displayName = "$destName";
                    String displayType = data['type']?.toString() ?? '';
                    String sourceAccount = data['sourceAccount']?.toString() ?? '';
                    String destinationAccount = data['destinationAccount']?.toString() ?? '';
                    if (data['type'] == 'Transfer') {
                      if (data['destinationAccount'] == account.accNumber) {
                        displayType = 'Received From';
                      } else {
                        displayType = 'Sent To';
                      }
                    }
                    return TransactionRow(
                      transactionType: displayType,
                      sourceAccount: sourceAccount,
                      destinationAccount: destinationAccount,
                      destinationName: displayName,
                      dateTime: dateString,
                      amount: amount,
                      currentAccount: account.accNumber,
                      textColor: AppColors.darkGreen,
                    );
                  },
                );
              }
            },
          );
        },
      ),
    ),
  );
}
}

class TransactionRow extends StatelessWidget {
  final String transactionType;
  final String sourceAccount;
  final String destinationAccount;
  final String destinationName;
  final String dateTime;
  final double amount;
  final String currentAccount;
  final Color textColor;

  TransactionRow({
    required this.transactionType,
    required this.sourceAccount,
    required this.destinationAccount,
    required this.destinationName,
    required this.dateTime,
    required this.amount,
    required this.currentAccount,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    bool isAdded = destinationAccount == currentAccount;
    String symbol = isAdded ? "+" : "-";
    Color amountColor = isAdded ? Colors.green : Colors.red;
    String formattedAmount = NumberFormat("#,##0.00", "en_US").format(amount);

    // Show account number only for Transfer, else blank but same space
    String accountNumberDisplay =
    (transactionType == "Transfer" || transactionType == "Sent To" || transactionType == "Received From")
        ? destinationAccount
        : "";

    return Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionType,
                  style: TextStyle(color: textColor, fontSize: 10),
                ),
                Text(
                  destinationName.isNotEmpty ? destinationName : (isAdded ? sourceAccount : destinationAccount),
                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
                ),
                if (accountNumberDisplay.isNotEmpty)
                  Padding(
                    padding:EdgeInsets.only(top: 0),
                    child: Text(
                      accountNumberDisplay,
                      style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 10),
                    ),
                  ),
                Text(
                  dateTime,
                  style: TextStyle(color: textColor, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            "$symbol PHP $formattedAmount",
            style: TextStyle(color: amountColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}