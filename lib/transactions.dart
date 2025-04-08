import 'package:flutter/material.dart';



class TransactionsPage extends StatefulWidget {
  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class TransactionRow extends StatelessWidget {
  final String transactionType; // Sent, Received, Bought
  final String recipient;
  final String dateTime;
  final double amount;
  final bool add; // true = added amount, false = subtracted amount

  TransactionRow({
    required this.transactionType,
    required this.recipient,
    required this.dateTime,
    required this.amount,
    required this.add,
  });

  @override
  Widget build(BuildContext context) {
    String symbol = add ? "+" : "-"; // Determine symbol dynamically
    Color amountColor = add ? Colors.green : Colors.red; // Green for add, red for subtract

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
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
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  recipient,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  dateTime,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "$symbol PHP${amount.toStringAsFixed(2)}",
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

class _TransactionPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          TransactionRow(
            transactionType: 'Sent By',
            recipient: 'JENNIFER MENDEZ',
            dateTime: 'FEB 09, 2025, 10:34 AM',
            amount: 1700,
            add: true,
          ),
          TransactionRow(
            transactionType: 'Bought From',
            recipient: 'MICHAEL SMITH',
            dateTime: 'MAR 12, 2025, 3:45 PM',
            amount: 1700,
            add: true,
          ),
        ],
      ),
    );
  }
}
