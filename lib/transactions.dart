import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'models/account.dart'; // Import your Account class with Transaction model
import 'package:intl/intl.dart';  // Add this import

class TransactionsPage extends StatelessWidget {
  final Account account;

  TransactionsPage({required this.account});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: account.transactions.isEmpty
          ? Center(child: Text('No transactions yet.'))
          : ListView.builder(
        itemCount: account.transactions.length,
        itemBuilder: (context, index) {
          final tx = account.transactions[index];
          return TransactionRow(
            transactionType: tx.type,
            recipient: tx.recipient,
            dateTime: tx.dateTime,
            amount: tx.amount,
            add: tx.isAdded,
            textColor: AppColors.darkGreen,
          );
        },
      ),
    );
  }
}

class TransactionRow extends StatelessWidget {
  final String transactionType; // Sent, Received, Bought
  final String recipient;
  final String dateTime;
  final double amount;
  final bool add; // true = added amount, false = subtracted amount
  final Color textColor; // Text color parameter for customization

  TransactionRow({
    required this.transactionType,
    required this.recipient,
    required this.dateTime,
    required this.amount,
    required this.add,
    required this.textColor, // Accept textColor
  });

  @override
  Widget build(BuildContext context) {
    String symbol = add ? "+" : "-"; // Determine symbol dynamically
    Color amountColor = add ? Colors.green : Colors.red; // Green for add, red for subtract

    // Format the amount with commas
    String formattedAmount = NumberFormat("#,##0.00", "en_US").format(amount);

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Remove border line if needed
        border: Border(bottom: BorderSide(color: Colors.transparent)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transactionType,
                  style: TextStyle(
                    color: textColor, // Use the custom text color here
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  recipient,
                  style: TextStyle(
                    color: textColor, // Use the custom text color here
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dateTime,
                  style: TextStyle(
                    color: textColor, // Use the custom text color here
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$symbol PHP $formattedAmount",  // Use formatted amount with commas
            style: TextStyle(
              color: amountColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

