import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verdantbank/components/slide_to_confirm.dart';
import 'package:flutter/services.dart';

class SellCryptoPage extends StatefulWidget {
  const SellCryptoPage({super.key});

  @override
  State<SellCryptoPage> createState() => _SellCryptoPageState();
}

class _SellCryptoPageState extends State<SellCryptoPage> {
  final TextEditingController _btcController = TextEditingController();
  final double btcRate = 854022.19;
  double userBTC = 0.0; // User's current BTC balance, can be fetched from Firestore
  double phpAmount = 0.0;
  double sliderValue = 0.0;
  bool _transactionInProgress = false;

  // Firebase document ID of the user account
  final String accountDocId = 'iSeVBWRzAhNa10oWUlXd';

  // User data from Firestore
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchAccountDetails();
  }

  Future<void> _fetchAccountDetails() async {
    final doc = await FirebaseFirestore.instance.collection('accounts').doc(accountDocId).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
        userBTC = (userData?['accBTC'] ?? 0.0).toDouble();
      });
    }
  }

  void _updatePhpAmount(String value) {
    setState(() {
      final btc = double.tryParse(value) ?? 0.0;
      phpAmount = btc * btcRate;
    });
  }

  Future<void> _saveTransaction() async {
    if (userData == null) return;

    final cryptoAmount = double.tryParse(_btcController.text) ?? 0.0;

    if (cryptoAmount <= 0 || cryptoAmount > 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid crypto amount.')),
      );
      return;
    }

    if (cryptoAmount > userBTC) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient crypto balance.')),
      );
      return;
    }

    final now = Timestamp.now();
    final transactionData = {
      'type': 'Sell Crypto',
      'destinationAccount': '${userData!['accNumber']}',
      'sourceAccount': 'VERDANT BANK',
      'timestamp': now,
      'amount': phpAmount,
      'cryptoAmount': cryptoAmount,
    };

    // Save transaction to Firestore
    await FirebaseFirestore.instance.collection('crypto_transactions').add(transactionData);

    // Update the account balance
    final newBalance = (userData!['accBalance'] as double) + phpAmount;
    final newBTCBalance = (userData!['accBTC'] as double) - cryptoAmount;

    // Update user's BTC balance
    await FirebaseFirestore.instance.collection('accounts').doc(accountDocId).update({
      'accBalance': newBalance,
      'accBTC': newBTCBalance,
    });

    // Update local state too to reflect balance change in UI
    setState(() {
      userData!['accBalance'] = newBalance;
      userData!['accBTC'] = newBTCBalance;
    });
  }

  void _showSlideToConfirmBottomSheet() {
    _transactionInProgress = false; // Reset transaction state
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.75,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F2633),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Transaction Details',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDetailRow('Merchant', 'VERDANT BANK'),
              _buildDetailRow(
                'Destination',
                userData != null
                    ? '${userData!['accFirstName']} ${userData!['accLastName']}\nSavings Account: ${userData!['accNumber']}'
                    : 'Loading...',
              ),
              _buildDetailRow('Amount', 'PHP ${phpAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Crypto Amount', '${_btcController.text} BTC'),
              const Spacer(),
              SlideToConfirm(
                sliderValue: sliderValue,
                onChanged: (val) async {
                  if (_transactionInProgress) return; // Prevent multiple submissions

                  setState(() {
                    sliderValue = val;
                  });
                  if (val == 1.0) {
                    _transactionInProgress = true; // Prevent multiple submissions
                    await _saveTransaction();
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaction completed successfully.')),
                      );
                    }
                  },
                info: {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _btcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "SELL CRYPTO",
                  style: TextStyle(
                    color: Color(0xFFB6FF68),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text("DESTINATION",
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF092D25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: userData == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Savings Account", style: TextStyle(color: Colors.white)),
                    Text(userData!['accNumber'], style: const TextStyle(color: Colors.white70)),
                    Text("BTC Balance: ${userBTC.toStringAsFixed(8)} BTC", style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.credit_card, color: Colors.orange),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Available Balance",
                                style: TextStyle(color: Colors.white54)),
                            Text("PHP ${userData!['accBalance'].toStringAsFixed(2)}",
                                style: const TextStyle(color: Colors.white, fontSize: 16)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("YOU SELL",
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00392F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _btcController,
                      onChanged: _updatePhpAmount,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,8}')), // Allows decimals, no letters
                      ],
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: "BTC Amount",
                        labelStyle: const TextStyle(color: Colors.greenAccent),
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

                    const SizedBox(height: 8),
                    const Text("1 BTC = 854,022.19", style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text("YOU BUY",
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00392F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "PHP ${phpAmount.toStringAsFixed(2)}",
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
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
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
                      onPressed: () {
                        final btc = double.tryParse(_btcController.text) ?? 0.0;

                        if (btc <= 0 || btc > 10) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Min. of 1 and Max. of 10 BTC only')),
                          );
                          return;
                        }
                        if (btc > userBTC) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Insufficient crypto balance.')),
                          );
                          return;
                        }
                        _showSlideToConfirmBottomSheet();
                      },
                      child: const Text("Confirm"),
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
