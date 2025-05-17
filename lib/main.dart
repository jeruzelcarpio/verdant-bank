import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/transactions.dart';
import 'alixScreens/signIn_screen.dart';
import 'transfer.dart';
import 'paybills.dart';
import 'buyload.dart';
import 'invest.dart';
import 'savings.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/components/menu_button.dart';
import 'account.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // Aliased import
import 'package:verdantbank/api/firestore.dart';

const userAccountNumber = '1234567890'; // Example account number



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    print('Firebase connected successfully');
  } catch (e) {
    print('Failed to connect to Firebase: $e');
  }

  final firestoreInstance = firestore.FirebaseFirestore.instance;



  // Fetch the account from Firestore
  Account userAccount = await fetchAccount(userAccountNumber) ??
      Account(
        accFirstName: 'Default',
        accLastName: 'User',
        accNumber: '0000000000',
        accBalance: 0.0,
        accPhoneNum: '0000000000',
      );

  runApp(MyApp(userAccount: userAccount));
}


class RotationYTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const RotationYTransition({
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 3.1415926535897932; // Convert to radians
        final isFlipped = angle > 3.1415926535897932 / 2;

        return Transform(
          transform: Matrix4.rotationY(angle),
          alignment: Alignment.center,
          child: isFlipped
              ? Opacity(opacity: 0, child: child) // Hide the back side
              : child,
        );
      },
      child: child,
    );
  }
}

class MyApp extends StatelessWidget {
  final Account userAccount;

  const MyApp({super.key, required this.userAccount});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VerdantBank Mobile Banking',
      theme: ThemeData(
        fontFamily: 'WorkSans',
        primarySwatch: Colors.green,
      ),
      home: const SignInScreen(), // Initial screen
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => HomePage(userAccount: userAccount), // Pass userAccount
            settings: const RouteSettings(name: '/home'),
          );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatefulWidget {
  final Account userAccount;

  const HomePage({super.key, required this.userAccount});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isFlipped = false;

  void _toggleCardFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

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
            account: widget.userAccount,
            onUpdate: _updateAccount, // Pass the callback
          ),
        ),
      );
    }

    if (action == 'Pay Bills') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaybillsPage(
            userAccount: widget.userAccount, // Pass userAccount
            onUpdate: _updateAccount,
          ),
        ),
      );
    }

    if (action == 'Buy Load') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuyLoadPage(
            userAccount: widget.userAccount, // Pass userAccount
            onUpdate: _updateAccount,
          ),
        ),
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
          builder: (context) => TransactionsPage(account: widget.userAccount),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Transaction> latestTransactions =
    widget.userAccount.transactions.take(4).toList();
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SingleChildScrollView(
        child: Padding(
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
                      SizedBox(
                        width: 12,
                      ),
                      Text(
                        "Welcome, ${widget.userAccount.accFirstName}!",
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
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          FontAwesomeIcons.user,
                          size: 16,
                          color: AppColors.lighterGreen,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          FontAwesomeIcons.bell,
                          size: 16,
                          color: AppColors.lighterGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 38,
              ),
              GestureDetector(
                onTap: _toggleCardFlip, // Flip the card on tap
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final angle = animation.value * 3.1415926535897932; // Convert to radians
                        final isFlipped = angle > 3.1415926535897932 / 2;

                        return Transform(
                          transform: Matrix4.rotationY(angle),
                          alignment: Alignment.center,
                          child: isFlipped
                              ? Transform(
                            transform: Matrix4.rotationY(3.1415926535897932),
                            alignment: Alignment.center,
                            child: child,
                          )
                              : child,
                        );
                      },
                      child: child,
                    );
                  },
                  child: _isFlipped
                      ? CardIcon(
                    key: ValueKey('flipped'),
                    savingAccountNum: "BACK OF CARD",
                    accountBalance: widget.userAccount.accBalance,
                  )
                      : CardIcon(
                    key: ValueKey('front'),
                    savingAccountNum: widget.userAccount.accNumber,
                    accountBalance: widget.userAccount.accBalance,
                  ),
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _toggleCardFlip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkGreen,
                ),
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isFlipped
                          ? FontAwesomeIcons.arrowRotateLeft
                          : FontAwesomeIcons.arrowRotateRight,
                      color: AppColors.lighterGreen,
                    ),
                    SizedBox(width: 8),
                    Text(
                      _isFlipped ? "Show Card" : "Show Account",
                      style: TextStyle(
                        color: AppColors.lighterGreen,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ),
              SizedBox(height: 21),
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
              SizedBox(
                height: 21,
              ),
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
                          textColor: Colors.white, // Override text color to white
                        )),
                      ],
                    ),
                    Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TransactionsPage(
                                    account: widget.userAccount)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.yellowGold,
                          backgroundColor:
                          AppColors.lighterGreen, // Button color
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
    );
  }
}

