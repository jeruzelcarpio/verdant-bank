import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/transactions.dart';
import 'transfer.dart';
import 'paybills.dart';
import 'buyload.dart';
import 'invest.dart';
import 'savings.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'account.dart';

Account userAccount = Account(
  accFirstName: "Jeff",
  accLastName: "Mendez",
  accNumber: "1553 456 1234",
  accBalance: 50000.00,
  accPhoneNum: "09458746633"
);




void main() {
  runApp(VerdantBankApp());
  userAccount.addTransaction(
    Transaction(
      type: "Sent To",
      recipient: "JENNIFER MENDEZ",
      dateTime: "APR 20, 2025, 10:30 AM",
      amount: 1500.0,
      isAdded: false,
    ),
  );

  userAccount.addTransaction(
    Transaction(
      type: "Received From",
      recipient: "MICHAEL CRUZ",
      dateTime: "APR 21, 2025, 2:15 PM",
      amount: 3000.0,
      isAdded: true,
    ),
  );

  userAccount.addTransaction(
    Transaction(
      type: "Sent To",
      recipient: "MERALCO",
      dateTime: "APR 21, 2025, 2:15 PM",
      amount: 7231.70,
      isAdded: false,
    ),
  );

  userAccount.addTransaction(
    Transaction(
      type: "Sent To",
      recipient: "MAYNILAD",
      dateTime: "APR 21, 2025, 2:15 PM",
      amount: 513.87,
      isAdded: false,
    ),
  );

  userAccount.addTransaction(
    Transaction(
      type: "Received From",
      recipient: "BILL GATES",
      dateTime: "APR 21, 2025, 2:15 PM",
      amount: 300000.0,
      isAdded: true,
    ),
  );

  userAccount.addTransaction(
    Transaction(
      type: "Sent To",
      recipient: "MARIA FELIPE",
      dateTime: "APR 21, 2025, 2:15 PM",
      amount: 754.43,
      isAdded: false,
    ),
  );

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void _updateAccount() {
    setState(() {
      // Trigger a rebuild to reflect the updated balance
    });
  }

  void _handleButtonPress(String action, BuildContext context) {
    print('$action button pressed');

    // Navigate to the appropriate screen based on the action
    if (action == 'Transfer') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TransferPage(
                account: userAccount,
                onUpdate: _updateAccount, // Pass the callback
              ),
        ),
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
        MaterialPageRoute(
          builder: (context) => TransactionsPage(account: userAccount),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> latestTransactions = userAccount.transactions.take(4).toList();
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body:
      Expanded(
          child:
          SingleChildScrollView(
            child:
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.creditCard,
                            size: 16,
                            color: AppColors.milk,
                          ),
                          SizedBox(width: 12,),
                          Text(
                            "Welcome, ${userAccount.accFirstName}!",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.milk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Padding(padding: EdgeInsets.all(10),
                            child:
                            Icon(
                              FontAwesomeIcons.user,
                              size: 16,
                              color: AppColors.lighterGreen,
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10),
                            child:
                            Icon(
                              FontAwesomeIcons.bell,
                              size: 16,
                              color: AppColors.lighterGreen,
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 38,),

                  CardIcon(
                    savingAccountNum: userAccount.accNumber,
                    accountBalance: userAccount.accBalance,
                  ),
                  SizedBox(height: 70),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.start,
                    children: [
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Transfer",
                        icon: Icons.payment,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Transfer', context),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Pay Bills",
                        icon: Icons.receipt_rounded,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Pay Bills', context),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Buy Load",
                        icon: Icons.sim_card,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Buy Load', context),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Invest",
                        icon: Icons.trending_up_rounded,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Invest', context),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Savings",
                        icon: Icons.savings_rounded,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Savings', context),
                      ),
                    ],
                  ),
                  SizedBox(height: 21,),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.green, // Keep the container's color
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'TRANSACTION HISTORY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.yellowGold, // Set the title color to white (only here)
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            ...latestTransactions.map((tx) => TransactionRow(
                              transactionType: tx.type,
                              recipient: tx.recipient,
                              dateTime: tx.dateTime,
                              amount: tx.amount,
                              add: tx.isAdded,
                              // Set the transaction text to white here
                              textColor: Colors.white, // Override text color to white
                            )),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => TransactionsPage(account: userAccount)),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: AppColors.yellowGold,
                              backgroundColor: AppColors.lighterGreen,// Button color
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                            child: Text(
                              'See More',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.green, // Button text color
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          ),

      ),
    );
  }
}