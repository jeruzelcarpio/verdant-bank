import 'package:flutter/material.dart';
import 'invest_stocks_market_checkout.dart';

class StockMarketPage extends StatelessWidget {
  const StockMarketPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> companies = [
      {
        "name": "Spotify",
        "symbol": "NYSE: SPOT",
        "price": "PHP 507,35",
        "change": "0.62%",
        "up": true,
        "logo":
        "https://cdn-icons-png.flaticon.com/512/174/174872.png"
      },
      {
        "name": "Amazon",
        "symbol": "NASDAQ: AMZN",
        "price": "PHP 507,35",
        "change": "6.83%",
        "up": true,
        "logo":
        "https://cdn-icons-png.flaticon.com/128/10096/10096351.png"
      },
      {
        "name": "Coca Cola",
        "symbol": "NYSE: KO",
        "price": "PHP 200,15",
        "change": "0.97%",
        "up": false,
        "logo":
        "https://cdn-icons-png.flaticon.com/128/16183/16183588.png"
      },
      {
        "name": "PepsiCo",
        "symbol": "NASDAQ: PEP",
        "price": "PHP 200,15",
        "change": "0.97%",
        "up": false,
        "logo":
        "https://cdn-icons-png.flaticon.com/128/732/732236.png"
      },
      {
        "name": "Meta",
        "symbol": "NASDAQ: META",
        "price": "PHP 507,35",
        "change": "0.62%",
        "up": true,
        "logo":
        "https://cdn-icons-png.flaticon.com/128/6033/6033716.png"
      },
      {
        "name": "Uber",
        "symbol": "NYSE: UBER",
        "price": "PHP 507,35",
        "change": "0.62%",
        "up": true,
        "logo":
        "https://cdn-icons-png.flaticon.com/128/5969/5969323.png"
      },
      {
        "name": "Apple",
        "symbol": "NASDAQ: AAPL",
        "price": "PHP 507,35",
        "change": "0.62%",
        "up": true,
        "logo":
        "https://cdn-icons-png.flaticon.com/128/2175/2175370.png"
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF04261C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.limeAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        title: const Text(
          "MARKET",
          style: TextStyle(
            color: Colors.limeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.lime[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StockMarketCheckoutPage(
                        name: company["name"] as String,
                        symbol: company["symbol"] as String,
                        price: company["price"] as String,
                        change: company["change"] as String,
                        isUp: company["up"] as bool,
                        logoUrl: company["logo"] as String,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                        NetworkImage(company["logo"] as String),
                        radius: 20,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              company["name"] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              company["symbol"] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            company["price"] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              Text(
                                company["change"] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: (company["up"] as bool)
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              Icon(
                                (company["up"] as bool)
                                    ? Icons.arrow_upward
                                    : Icons.arrow_downward,
                                color: (company["up"] as bool)
                                    ? Colors.green
                                    : Colors.red,
                                size: 16,
                              ),
                            ],
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
      ),
    );
  }
}
