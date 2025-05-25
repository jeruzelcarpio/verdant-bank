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
import 'models/account.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore; // Aliased import
import 'package:verdantbank/api/firestore.dart';
import 'package:verdantbank/animation_class/card_animation.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'dart:math';
import 'package:verdantbank/components/flipcard_section.dart';

const userAccountNumber = '1234567891';
const userAccountEmail = 'franzperez1073@gmail.com';


Future<void> createAccount({
  required String accFirstName,
  required String accLastName,
  required String accNumber,
  required double accBalance,
  required String accPhoneNum,
  required String accEmail,
}) async {
  try {
    final accountData = {
      'accFirstName': accFirstName,
      'accLastName': accLastName,
      'accNumber': accNumber,
      'accBalance': accBalance,
      'accPhoneNum': accPhoneNum,
      'accEmail': accEmail,
    };

    await firestore.FirebaseFirestore.instance
        .collection('accounts')
        .add(accountData);

    print('Account created successfully!');
  } catch (e) {
    print('Error creating account: $e');
  }

}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(AccountLoader());
}

class AccountLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Account?>(
      future: fetchAccount(userAccountEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: AppColors.darkGreen,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: AppColors.darkGreen,
              body: Center(
                child: Text(
                  'Wahoo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          );
        }
        return MyApp(userAccount: snapshot.data!);
      },
    );
  }
}

Future<Account?> fetchAccount(String userAccountEmail) async {
  try {
    final snapshot = await firestore.FirebaseFirestore.instance
        .collection('accounts')
        .where('accEmail', isEqualTo: userAccountEmail)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      return Account.fromMap(data);
    }
  } catch (e) {
    print('Error fetching account: $e');
  }
  return null;
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
      home: HomePage(userAccount: userAccount), // change to SignInScreen() or (userAccount: userAccount) if you want to start with the sign-in screen
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          return MaterialPageRoute(
            builder: (context) => HomePage(userAccount: userAccount),
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
  Account? _currentAccount;

  void initState() {
    super.initState();
    _currentAccount = widget.userAccount;
  }

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

  void _handleButtonPress(String action, BuildContext context, Account account) {
    if (action == 'Transfer') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransferPage(
            account: account,
            onUpdate: _updateAccount,
          ),
        ),
      );
    } else if (action == 'Pay Bills') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaybillsPage(
            userAccount: account,
            onUpdate: _updateAccount,
          ),
        ),
      );
    } else if (action == 'Buy Load') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BuyLoadPage(
            userAccount: account,
            onUpdate: _updateAccount,
          ),
        ),
      );
    } else if (action == 'Invest') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InvestPage()),
      );
    } else if (action == 'Savings') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SavingsPage()),
      );
    } else if (action == 'Transactions') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionsPage(account: account),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firestore.QuerySnapshot>(
      stream: firestore.FirebaseFirestore.instance
          .collection('accounts')
          .where('accEmail', isEqualTo: widget.userAccount.accEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          // Show loading while waiting for stream
          return Scaffold(
            backgroundColor: AppColors.darkGreen,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(), // Show loading instead of "Account not found."
          );
        }

        final accountData = Account.fromMap(
          snapshot.data!.docs.first.data() as Map<String, dynamic>,
        );

        return Scaffold(
          backgroundColor: AppColors.darkGreen,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: Image.asset(
                              'assets/homepage_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Welcome, ${accountData.accFirstName}!",
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.milk,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: AppColors.lighterGreen,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.notifications,
                              size: 16,
                              color: AppColors.lighterGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                  FlipCardSection(accountData: accountData),
                  const SizedBox(height: 21),
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
                        onPressed: () => _handleButtonPress('Transfer', context, accountData),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Pay Bills",
                        icon: Icons.receipt_rounded,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Pay Bills', context, accountData),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Buy Load",
                        icon: Icons.sim_card,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Buy Load', context, accountData),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Invest",
                        icon: Icons.trending_up_rounded,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Invest', context, accountData),
                      ),
                      MenuButton(
                        bgColor: AppColors.lighterGreen,
                        buttonName: "Savings",
                        icon: Icons.savings_rounded,
                        onPressColor: AppColors.lightGreen,
                        onPressed: () => _handleButtonPress('Savings', context, accountData),
                      ),
                    ],
                  ),
                  const SizedBox(height: 21),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                  Container(
                    width: double.infinity, // Make it as wide as possible
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppColors.green,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Less padding for more width
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'TRANSACTION HISTORY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.yellowGold,
                            ),
                          ),
                        ),
                        StreamBuilder<firestore.QuerySnapshot>(
                          stream: firestore.FirebaseFirestore.instance
                              .collection('transactions')
                              .where('accounts', arrayContains: accountData.accNumber)
                              .orderBy('dateTime', descending: true)
                              .limit(4)
                              .snapshots(),
                          builder: (context, snapshot) {
                            List<Widget> transactionWidgets = [];
                            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                              final docs = snapshot.data!.docs;
                              for (int i = 0; i < 4; i++) {
                                if (i < docs.length) {
                                  final data = docs[i].data() as Map<String, dynamic>;
                                  // Format dateTime
                                  String dateString = '';
                                  final dateTime = data['dateTime'];
                                  if (dateTime is Timestamp) {
                                    dateString = DateFormat('yyyy-MM-dd HH:mm').format(dateTime.toDate());
                                  } else if (dateTime is String) {
                                    dateString = dateTime;
                                  }
                                  // Format amount
                                  double amount = 0.0;
                                  if (data['amount'] is int) {
                                    amount = (data['amount'] as int).toDouble();
                                  } else if (data['amount'] is double) {
                                    amount = data['amount'];
                                  }
                                  String formattedAmount = NumberFormat("#,##0.00", "en_US").format(amount);

                                  transactionWidgets.add(
                                    ListTile(
                                      title: Text(
                                        data['type'] ?? 'Transaction',
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        dateString,
                                        style: const TextStyle(color: Colors.white70),
                                      ),
                                      trailing: Text(
                                        '₱$formattedAmount',
                                        style: const TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  );
                                } else {
                                  // Placeholder for empty slots
                                  transactionWidgets.add(
                                    ListTile(
                                      title: Text(
                                        'No transaction',
                                        style: const TextStyle(color: AppColors.green),
                                      ),
                                      subtitle: const Text('—', style: TextStyle(color: AppColors.green)),
                                      trailing: const Text('₱0.00', style: TextStyle(color: AppColors.green)),
                                    ),
                                  );
                                }
                              }
                            } else {
                              // No data, show 4 placeholders
                              for (int i = 0; i < 4; i++) {
                                transactionWidgets.add(
                                  ListTile(
                                    title: Text(
                                      'No transaction',
                                      style: const TextStyle(color: AppColors.green),
                                    ),
                                    subtitle: const Text('—', style: TextStyle(color: AppColors.green)),
                                    trailing: const Text('₱0.00', style: TextStyle(color: AppColors.green)),
                                  ),
                                );
                              }
                            }
                            return Column(children: transactionWidgets);
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                    Positioned(
                      left: 90,
                      right: 90,
                      bottom: -20, // Negative value to make it peek out
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionsPage(account: accountData),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppColors.yellowGold,
                          backgroundColor: AppColors.lighterGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        child: const Text(
                          'See More',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                  SizedBox(height: 60,),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

