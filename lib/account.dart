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
    String accFirstName;
    String accLastName;
    String accNumber;
    double accBalance;
    String accPhoneNum;
    List<Transaction> transactions = [];

    Account({
        required this.accFirstName,
        required this.accLastName,
        required this.accNumber,
        required this.accBalance,
        required this.accPhoneNum,
    });

    void addTransaction(Transaction transaction) {
        transactions.add(transaction);
        accBalance += transaction.isAdded ? transaction.amount : -transaction.amount;
    }
}
