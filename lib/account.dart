import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
    String type;        // e.g., "Sent", "Received", "Bought"
    String recipient;   // Name of the recipient
    String dateTime;    // Formatted date string
    double amount;      // Amount of money
    bool isAdded;       // true if it adds to balance, false if subtracts

    Transaction({
        required this.type,
        required this.recipient,
        required this.dateTime,
        required this.amount,
        required this.isAdded,
    });
}

class Account {
    final String accFirstName;
    final String accLastName;
    final String accNumber;
    double accBalance;
    final String accPhoneNum;
    List<Transaction> transactions = [];

    Account({
        required this.accFirstName,
        required this.accLastName,
        required this.accNumber,
        required this.accBalance,
        required this.accPhoneNum,
    });

    // Fetch transactions from Firestore
    Future<void> fetchTransactions() async {
        final snapshot = await FirebaseFirestore.instance
            .collection('transactions')
            .where('accountNumber', isEqualTo: accNumber)
            .get();

        transactions = snapshot.docs.map((doc) {
            final data = doc.data();
            return Transaction(
                type: data['type'],
                recipient: data['recipient'],
                dateTime: data['dateTime'],
                amount: data['amount'],
                isAdded: data['isAdded'],
            );
        }).toList();
    }

    // Add a transaction to Firestore
    Future<void> addTransaction(Transaction transaction) async {
        await FirebaseFirestore.instance.collection('transactions').add({
            'accountNumber': accNumber,
            'type': transaction.type,
            'recipient': transaction.recipient,
            'dateTime': transaction.dateTime,
            'amount': transaction.amount,
            'isAdded': transaction.isAdded,
        });

        // Update local list
        transactions.add(transaction);
        accBalance += transaction.isAdded ? transaction.amount : -transaction.amount;
    }
}
