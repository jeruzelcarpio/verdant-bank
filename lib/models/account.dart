import 'package:cloud_firestore/cloud_firestore.dart' as firestore;

class Transaction {
    String type; // e.g., "Sent", "Received", "Bought"
    String sourceAccount; // Source account number
    String destinationAccount; // Destination account number
    String dateTime; // Formatted date string
    double amount; // Amount of money

    Transaction({
        required this.type,
        required this.sourceAccount,
        required this.destinationAccount,
        required this.dateTime,
        required this.amount,
    });
}

class Account {
    final String accFirstName;
    final String accLastName;
    final String accNumber;
    double accBalance;
    final String accPhoneNum;
    final String accEmail;
    List<Transaction> transactions = [];

    Account({
        required this.accFirstName,
        required this.accLastName,
        required this.accNumber,
        required this.accBalance,
        required this.accPhoneNum,
        required this.accEmail,
    });

    factory Account.fromMap(Map<String, dynamic> map) {
        return Account(
            accFirstName: map['accFirstName'] ?? '',
            accLastName: map['accLastName'] ?? '',
            accNumber: map['accNumber'] ?? '',
            accBalance: (map['accBalance'] ?? 0).toDouble(),
            accPhoneNum: map['accPhoneNum'] ?? '',
            accEmail: map['accEmail'] ?? '',
        );
    }

    // Fetch transactions from Firestore
    Future<void> fetchTransactions() async {
        final sourceSnapshot = await firestore.FirebaseFirestore.instance
            .collection('transactions')
            .where('sourceAccount', isEqualTo: accNumber)
            .get();

        final destinationSnapshot = await firestore.FirebaseFirestore.instance
            .collection('transactions')
            .where('destinationAccount', isEqualTo: accNumber)
            .get();

        transactions = [
            ...sourceSnapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Transaction(
                    type: data['type'],
                    sourceAccount: data['sourceAccount'],
                    destinationAccount: data['destinationAccount'],
                    dateTime: data['dateTime'],
                    amount: data['amount'],
                );
            }),
            ...destinationSnapshot.docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return Transaction(
                    type: data['type'],
                    sourceAccount: data['sourceAccount'],
                    destinationAccount: data['destinationAccount'],
                    dateTime: data['dateTime'],
                    amount: data['amount'],
                );
            }),
        ];
    }

    // Add a transaction to Firestore
    Future<void> addTransaction(Transaction transaction) async {
        await firestore.FirebaseFirestore.instance.collection('transactions').add({
            'type': transaction.type,
            'sourceAccount': transaction.sourceAccount,
            'destinationAccount': transaction.destinationAccount,
            'dateTime': transaction.dateTime,
            'amount': transaction.amount,
        });

        // Update local list
        transactions.add(transaction);
        if (transaction.sourceAccount == accNumber) {
            accBalance -= transaction.amount;
        } else if (transaction.destinationAccount == accNumber) {
            accBalance += transaction.amount;
        }
    }
}