import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verdantbank/invest_crypto.dart';

class CryptoBuyCheckoutPage extends StatefulWidget {
  final String symbol;
  final String name;
  final String price;

  const CryptoBuyCheckoutPage({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
  });

  @override
  State<CryptoBuyCheckoutPage> createState() => _CryptoBuyCheckoutPageState();
}

class _CryptoBuyCheckoutPageState extends State<CryptoBuyCheckoutPage> {
  final TextEditingController _phpController = TextEditingController();
  double cryptoAmount = 0.0;
  double accountBalance = 0.0;
  String? accountNumber;
  bool isLoading = true;

  final String accountDocId = 'iSeVBWRzAhNa10oWUlXd';

  @override
  void initState() {
    super.initState();
    fetchAccountData();
  }

  Future<void> fetchAccountData() async {
    final doc = await FirebaseFirestore.instance.collection('accounts').doc(accountDocId).get();
    if (doc.exists) {
      final Map<String, dynamic>? data = doc.data();
      if (data != null) {
        setState(() {
          accountBalance = data['accBalance']?.toDouble() ?? 0.0;
          accountNumber = data['accNumber'] ?? 'Unknown';
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account data not found')),
        );
      }
    }
  }

  void _updateCryptoAmount(String value) {
    final cleanedValue = value.replaceAll(',', '');
    final php = double.tryParse(cleanedValue) ?? 0.0;
    final rate = double.tryParse(widget.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 1.0;
    setState(() {
      cryptoAmount = php / rate;
    });
  }

  Future<void> _saveTransaction(double phpAmount) async {
    await FirebaseFirestore.instance.collection('crypto_transactions').add({
      'amount': phpAmount,
      'cryptoAmount': cryptoAmount,
      'destinationAccount': widget.symbol,
      'sourceAccount': accountNumber,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'buy crypto',
    });

    // Optionally deduct the amount from user balance
    await FirebaseFirestore.instance.collection('accounts').doc(accountDocId).update({
      'accBalance': FieldValue.increment(-phpAmount),
    });
  }

  String? validateInput(String input) {
    final cleaned = input.replaceAll(',', '');
    final amount = double.tryParse(cleaned);

    if (cleaned.isEmpty) return 'Please enter an amount.';
    if (amount == null) return 'Enter a valid number.';
    if (amount <= 0) return 'Amount must be greater than 0.';
    if (amount > accountBalance) return 'Insufficient balance.';

    return null;
  }

  @override
  void dispose() {
    _phpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.greenAccent))
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "BUY CRYPTO",
                  style: TextStyle(
                    color: Color(0xFFB6FF68),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("SOURCE", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF092D25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Savings Account", style: TextStyle(color: Colors.white, fontSize: 18)),
                    Text(accountNumber ?? 'Loading...', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: Colors.orange, size: 30),
                        const SizedBox(width: 12),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Available Balance", style: TextStyle(color: Colors.white54, fontSize: 14)),
                            Text(
                              'PHP ${accountBalance.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("YOU SPEND", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00392F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _phpController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: _updateCryptoAmount,
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'PHP 100,000.00',
                    hintStyle: const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.greenAccent),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.green),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("YOU BUY", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00392F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.symbol} ${cryptoAmount.toStringAsFixed(8)}',
                  style: const TextStyle(color: Color(0xFFB6FF68), fontSize: 24),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFB6FF68),
                        side: const BorderSide(color: Color(0xFFB6FF68)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB6FF68),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () async {
                        final input = _phpController.text.trim().replaceAll(',', '');
                        final amount = double.tryParse(input);

                        if (amount == null || amount <= 0 || amount > accountBalance) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid amount.')),
                          );
                          return;
                        }

                        try {
                          // Add transaction record first
                          await FirebaseFirestore.instance.collection('crypto_transactions').add({
                            'amount': amount,
                            'cryptoAmount': cryptoAmount,
                            'destinationAccount': widget.symbol,
                            'sourceAccount': accountNumber,
                            'timestamp': FieldValue.serverTimestamp(),
                            'type': 'Buy Crypto',
                          });

                          final DocumentReference accountRef = FirebaseFirestore.instance.collection('accounts').doc(accountDocId);

                          // Run Firestore transaction to update balance and BTC atomically
                            await FirebaseFirestore.instance.runTransaction((transaction) async {
                            final snapshot = await transaction.get(accountRef);
                            if (!snapshot.exists) {
                            throw Exception('Account document does not exist!');
                            }
                            final data = snapshot.data() as Map<String, dynamic>;

                            final currentBalance = (data['accBalance'] as num).toDouble();
                            final currentBTC = (data['accBTC'] as num?)?.toDouble() ?? 0.0;

                            if (amount > currentBalance) {
                            throw Exception('Insufficient balance for transaction.');
                            }

                            transaction.update(accountRef, {
                            'accBalance': currentBalance - amount,
                            'accBTC': currentBTC + cryptoAmount,
                            });
                            });

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction successful!')),
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InvestCryptoPage(),
                          ),
                        );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Transaction failed: $e')),
                          );
                        };
                      },
                      child: const Text("Buy"),
                    ),
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
