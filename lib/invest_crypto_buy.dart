import 'package:flutter/material.dart';
import 'invest_crypto_buy_checkout.dart';

class BuyCryptoPage extends StatelessWidget {
  const BuyCryptoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cryptos = [
      {'symbol': 'BTC', 'name': 'Bitcoin', 'price': 'PHP 854,022.19', 'change': '+4.92%', 'icon': Icons.currency_bitcoin, 'color': Colors.amber},
      {'symbol': 'ETH', 'name': 'Ethereum', 'price': 'PHP 325.87', 'change': '+4.92%', 'icon': Icons.token, 'color': Colors.blueGrey},
      for (int i = 0; i < 8; i++)
        {'symbol': 'RNG', 'name': 'Random', 'price': 'PHP 99999.99', 'change': '-4.92%', 'icon': Icons.all_inbox, 'color': Colors.orange},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF002015),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'BUY CRYPTO',
                style: TextStyle(
                  color: Color(0xFFA5FF4D),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: cryptos.length,
                itemBuilder: (context, index) {
                  final crypto = cryptos[index];
                  final isPositive = crypto['change'].toString().startsWith('+');
                  return GestureDetector(
                    onTap: () {
                      final symbol = crypto['symbol'];
                      if (symbol == 'BTC' || symbol == 'ETH') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CryptoBuyCheckoutPage(
                              symbol: symbol as String,
                              name: crypto['name'] as String,
                              price: crypto['price'] as String,
                            ),
                          ),
                        );
                      } else {
                        debugPrint('${crypto['name']} tapped');
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06513E),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: crypto['color'] as Color,
                            child: Icon(crypto['icon'] as IconData, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                crypto['symbol'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                crypto['name'] as String,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              Text(
                                '≈ ${crypto['price']}',
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              Icon(
                                isPositive ? Icons.trending_up : Icons.trending_down,
                                color: isPositive ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              Text(
                                crypto['change'] as String,
                                style: TextStyle(
                                  color: isPositive ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20, top: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFA5FF4D), width: 1.5),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                    child: Text(
                      'Back',
                      style: TextStyle(
                        color: Color(0xFFA5FF4D),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
