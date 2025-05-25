import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'invest_crypto_buy.dart';
import 'invest_crypto_sell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InvestCryptoPage extends StatefulWidget {
  const InvestCryptoPage({super.key});

  @override
  State<InvestCryptoPage> createState() => _InvestCryptoPageState();
}

class _InvestCryptoPageState extends State<InvestCryptoPage> {
  late String formattedDate;
  // Firestore document ID for the account
  final String accountDocId = 'iSeVBWRzAhNa10oWUlXd';

  // BTC to PHP conversion rate (hardcoded)
  double btcToPhpRate = 854022.19; // 1 BTC = PHP 854,022.19

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().toUtc().add(const Duration(hours: 8)); // UTC+8
    formattedDate = DateFormat("MMMM d, y h:mm:ss a").format(now).toUpperCase();
  }

  String formattedTotalValue(double btcAmount) {
    double total = btcAmount * btcToPhpRate;
    return NumberFormat.currency(locale: "en_PH", symbol: "PHP ").format(total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00110D),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('accounts')
              .doc(accountDocId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)));
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFA5FF4D),
                  ));
            }

            // Extract data from Firestore
            final data = snapshot.data!.data() as Map<String, dynamic>;
            final btcAmount = (data['accBTC'] as num?)?.toDouble() ?? 0.0;
            // Optionally, you can also get the available balance if needed
            // final accBalance = (data['accBalance'] as num?)?.toDouble() ?? 0.0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top bar
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon:
                          const Icon(Icons.arrow_back, color: Color(0xFFA5FF4D)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Center(
                        child: Text(
                          'INVEST',
                          style: TextStyle(
                            color: Color(0xFFA5FF4D),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                Text('AS OF $formattedDate',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 20),
                const Text('TOTAL VALUE',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  formattedTotalValue(btcAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 30),

                // Portfolio card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF003B2C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'YOUR CRYPTO PORTFOLIO',
                          style: TextStyle(
                            color: Color(0xFFFFB600),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C6C5A),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.amber,
                                child: Icon(Icons.currency_bitcoin,
                                    color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'BTC ${btcAmount.toStringAsFixed(10)}',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                  Text(
                                    'Bitcoin\n≈ ${formattedTotalValue(btcAmount)}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Column(
                                children: [
                                  Icon(Icons.arrow_upward,
                                      color: Colors.green, size: 16),
                                  Text(
                                    '+4.92%',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const BuyCryptoPage()),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA5FF4D),
                                  foregroundColor: Colors.black,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'BUY',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push<double>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SellCryptoPage(),
                                    ),
                                  );

                                  // Removed the old local update:
                                  // BTC amount comes from Firestore live now
                                  if (result != null /* && result < btcAmount */) {
                                    // We could force refresh or just rely on Firestore stream
                                    setState(() {});
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFA5FF4D),
                                  foregroundColor: Colors.black,
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'SELL',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
