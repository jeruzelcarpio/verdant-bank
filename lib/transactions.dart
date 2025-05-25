import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:verdantbank/theme/colors.dart';
import 'models/account.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:verdantbank/utils/date_utils.dart';





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
    child: StreamBuilder<firestore.QuerySnapshot>(
      stream: firestore.FirebaseFirestore.instance
          .collection('transactions')
          .where('accounts', arrayContains: account.accNumber)
          .orderBy('dateTime', descending: true) // or remove limit for full list
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
          String destinationName = '';
          if (data['type'] == 'Transfer to Other Bank') {
            destinationName = data['bank'] ?? '';
          } else {
            final firstName = data['destinationFirstName'] ?? '';
            final lastName = data['destinationLastName'] ?? '';
            destinationName = (firstName + ' ' + lastName).trim();
          }
          // Format dateTime
          String dateString = '';
          final dateTime = data['dateTime'];
          if (dateTime is Timestamp) {
            print('Raw Timestamp: $dateTime');
            print('UTC DateTime: ${dateTime.toDate()}');
            print('Local DateTime: ${dateTime.toDate().toLocal()}');
            dateString = formatToLocal(dateTime.toDate());
          }else if (dateTime is String) {
            dateString = dateTime;
          }
          // Use totalAmount for "Transfer to Other Bank", else use amount
          double amount = 0.0;
          if (data['type'] == 'Transfer to Other Bank' && data['totalAmount'] != null) {
            amount = (data['totalAmount'] as num).toDouble();
          } else if (data['amount'] is int) {
            amount = (data['amount'] as int).toDouble();
          } else if (data['amount'] is double) {
            amount = data['amount'];
          }
          return {
            'type': data['type'] ?? '',
            'sourceAccount': data['sourceAccount'] ?? '',
            'destinationAccount': data['destinationAccount'] ?? '',
            'destinationName': destinationName,
            'dateTime': dateString,
            'amount': amount,
            'bank': data['bank'] ?? '',
          };
        }).toList();

        // Optional: print for debugging
        for (var tx in transactions) {
          print('Transaction: $tx');
        }

        final Map<String, List<Map<String, dynamic>>> grouped = {};
        for (var tx in transactions) {
          final date = DateFormat('yyyy-MM').format(DateFormat('MMM dd, yyyy, hh:mm a').parse(tx['dateTime']));
          grouped.putIfAbsent(date, () => []).add(tx);
        }

        final List<Map<String, dynamic>> items = [];
        grouped.forEach((key, txs) {
          final header = DateFormat('MMMM yyyy').format(DateFormat('yyyy-MM').parse(key));
          if (header.trim().isNotEmpty) {
            items.add({'header': header});
          }
          items.addAll(txs);
        });

        return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              if (item.containsKey('header') && (item['header']?.toString().trim().isNotEmpty ?? false)) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 2.0, left: 16.0, right: 16.0),
                  child: Text(
                    item['header'].toUpperCase(),
                    style: TextStyle(fontSize: 16, color: AppColors.green),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final tx = item;
              return FutureBuilder<firestore.QuerySnapshot>(
                  future: firestore.FirebaseFirestore.instance
                      .collection('accounts')
                      .where('accNumber', isEqualTo: tx['destinationAccount'])
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

                    // Logic for transfer type
                    String displayType = tx['type'];
                    if (tx['type'] == 'Transfer') {
                      if (tx['destinationAccount'] == account.accNumber) {
                        displayType = 'Received From';
                      } else {
                        displayType = 'Sent To';
                      }
                    }

                    return TransactionRow(
                      transactionType: displayType,
                      sourceAccount: tx['sourceAccount'],
                      destinationAccount: tx['destinationAccount'],
                      destinationName: displayName,
                      dateTime: tx['dateTime'],
                      amount: tx['amount'],
                      currentAccount: account.accNumber,
                      textColor: AppColors.darkGreen,
                    );
                  }
              );
            }
        );
      },
    ),
    )
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

