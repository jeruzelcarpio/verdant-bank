import 'package:flutter/material.dart';
import 'package:verdantbank/transactions.dart';
import 'transfer.dart';
import 'paybills.dart';
import 'buyload.dart';
import 'invest.dart';
import 'savings.dart';

void main() {
  runApp(VerdantBankApp());
}

class VerdantBankApp extends StatelessWidget {
  const VerdantBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VerdantBank Mobile Banking',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _handleButtonPress(String action, BuildContext context) {
    print('$action button pressed');

    // Navigate to the appropriate screen based on the action
    if (action == 'Transfer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TransferPage()),
      );
    }

    if (action == 'Pay Bills') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaybillsPage()),
      );
    }

    if (action == 'Buy Load') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BuyLoadPage()),
      );
    }

    if (action == 'Invest') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvestPage()),
      );
    }

    if (action == 'Savings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SavingsPage()),
      );
    }

    if (action == 'Transactions') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TransactionsPage()),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VerdantBank'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _handleButtonPress('Transfer', context),
              child: Text('Transfer'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleButtonPress('Pay Bills', context),
              child: Text('Pay Bills'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleButtonPress('Buy Load', context),
              child: Text('Buy Load'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleButtonPress('Invest', context),
              child: Text('Invest'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleButtonPress('Savings', context),
              child: Text('Savings'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _handleButtonPress('Transactions', context),
              child: Text('Transactions'),
            ),
          ],
        ),
      ),
    );
  }
}