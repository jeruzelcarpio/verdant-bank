import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/transactions.dart';
import 'alixScreens/onboarding_screen.dart';
import 'alixScreens/signIn_screen.dart';
import 'transfer.dart';
import 'paybills.dart';
import 'buyload.dart';
import 'invest.dart';
import 'savings.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'account.dart';
import 'alixScreens/login_screen.dart';

Account userAccount = Account(
  accFirstName: "Jeff",
  accLastName: "Mendez",
  accNumber: "1553 456 1234",
  accBalance: 50000.00,
  accPhoneNum: "09458746633"
);

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
      home: const SignInScreen(),
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
          builder: (context) => TransferPage(
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
        MaterialPageRoute(builder: (context) => TransactionsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body:
      Expanded(
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
                      icon: FontAwesomeIcons.creditCard,
                      onPressColor: AppColors.lightGreen,
                      onPressed: () => _handleButtonPress('Transfer', context),
                    ),
                    MenuButton(
                      bgColor: AppColors.lighterGreen,
                      buttonName: "Pay Bills",
                      icon: FontAwesomeIcons.creditCard,
                      onPressColor: AppColors.lightGreen,
                      onPressed: () => _handleButtonPress('Pay Bills', context),
                    ),
                    MenuButton(
                      bgColor: AppColors.lighterGreen,
                      buttonName: "Buy Load",
                      icon: FontAwesomeIcons.creditCard,
                      onPressColor: AppColors.lightGreen,
                      onPressed: () => _handleButtonPress('Buy Load', context),
                    ),
                    MenuButton(
                      bgColor: AppColors.lighterGreen,
                      buttonName: "Invest",
                      icon: FontAwesomeIcons.creditCard,
                      onPressColor: AppColors.lightGreen,
                      onPressed: () => _handleButtonPress('Invest', context),
                    ),
                    MenuButton(
                      bgColor: AppColors.lighterGreen,
                      buttonName: "Savings",
                      icon: FontAwesomeIcons.creditCard,
                      onPressColor: AppColors.lightGreen,
                      onPressed: () => _handleButtonPress('Savings', context),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ),
    );
  }
}