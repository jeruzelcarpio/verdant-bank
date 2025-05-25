import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:verdantbank/theme/colors.dart';
import 'models/account.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;




class TransactionsPage extends StatelessWidget {
final Account account;

TransactionsPage({required this.account});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Transactions'),
    ),
    body: StreamBuilder<firestore.QuerySnapshot>(
      stream: firestore.FirebaseFirestore.instance
          .collection('transactions')
          .where('accounts', arrayContains: account.accNumber)
          .orderBy('dateTime', descending: true)
          .limit(4) // or remove limit for full list
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading transactions.'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No transactions yet.'));
        }

        final transactions = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Format dateTime
          String dateString = '';
          final dateTime = data['dateTime'];
          if (dateTime is Timestamp) {
            dateString = DateFormat('yyyy-MM-dd HH:mm').format(dateTime.toDate());
          } else if (dateTime is String) {
            dateString = dateTime;
          }
          // Format amount
          double amount = 0.0;
          if (data['amount'] is int) {
            amount = (data['amount'] as int).toDouble();
          } else if (data['amount'] is double) {
            amount = data['amount'];
          }
          return {
            'type': data['type'] ?? '',
            'sourceAccount': data['sourceAccount'] ?? '',
            'destinationAccount': data['destinationAccount'] ?? '',
            'dateTime': dateString,
            'amount': amount,
          };
        }).toList();

        // Optional: print for debugging
        for (var tx in transactions) {
          print('Transaction: $tx');
        }

        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final tx = transactions[index];
            return TransactionRow(
              transactionType: tx['type'],
              sourceAccount: tx['sourceAccount'],
              destinationAccount: tx['destinationAccount'],
              dateTime: tx['dateTime'],
              amount: tx['amount'],
              currentAccount: account.accNumber,
              textColor: AppColors.darkGreen,
            );
          },
        );
      },
    ),
  );
}
}

class TransactionRow extends StatelessWidget {
  final String transactionType;
  final String sourceAccount;
  final String destinationAccount;
  final String dateTime;
  final double amount;
  final String currentAccount; // The account viewing the transaction
  final Color textColor;

  TransactionRow({
    required this.transactionType,
    required this.sourceAccount,
    required this.destinationAccount,
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

    return Container(
      padding: EdgeInsets.all(12),
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
                  isAdded ? sourceAccount : destinationAccount,
                  style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w700),
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