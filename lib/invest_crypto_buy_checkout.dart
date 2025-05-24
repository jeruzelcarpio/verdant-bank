import 'package:flutter/material.dart';

class CryptoBuyCheckoutPage extends StatefulWidget {
  final String symbol;
  final String name;
  final String price; // PHP price as String

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
  final String accountNumber = '1039 8548 75';
  final String balance = 'PHP 45,267.91';

  void _updateCryptoAmount(String value) {
    setState(() {
      final php = double.tryParse(value.replaceAll(',', '')) ?? 0.0;
      final rate = double.tryParse(widget.price.replaceAll(RegExp(r'[^\d.]'), '')) ?? 1.0;
      cryptoAmount = php / rate;
    });
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
        child: Padding(
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
              const Text(
                "SOURCE",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
              ),
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
                    const Text(
                      "Savings Account",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      accountNumber,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: Colors.orange, size: 30),
                        const SizedBox(width: 12),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Available Balance",
                              style: TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            Text(
                              balance,
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
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
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
                      onPressed: () {
                        // Transaction logic or confirmation sheet
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
