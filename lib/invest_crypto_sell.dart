import 'package:flutter/material.dart';
import 'package:verdantbank/components/slide_to_confirm.dart';

class SellCryptoPage extends StatefulWidget {
  const SellCryptoPage({super.key});

  @override
  State<SellCryptoPage> createState() => _SellCryptoPageState();
}

class _SellCryptoPageState extends State<SellCryptoPage> {
  final TextEditingController _btcController = TextEditingController();
  final double btcRate = 854022.19;
  double phpAmount = 0.0;
  double sliderValue = 0.0;

  final String userName = 'JEFF MENDEZ';
  final String accountNumber = '1039 8548 75';
  final String merchant = 'VERDANT BANK';

  void _updatePhpAmount(String value) {
    setState(() {
      final btc = double.tryParse(value) ?? 0.0;
      phpAmount = btc * btcRate;
    });
  }

  void _showSlideToConfirmBottomSheet() {
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
            color: Color(0xFF0F2633),
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Transaction Details',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              _buildDetailRow('Merchant', merchant),
              _buildDetailRow(
                  'Destination', '$userName\nSavings Account: $accountNumber'),
              _buildDetailRow('Amount', 'PHP ${phpAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Crypto Amount', '${_btcController.text} BTC'),
              Spacer(),
              SlideToConfirm(
                sliderValue: sliderValue,
                onChanged: (val) {
                  setState(() {
                    sliderValue = val;
                  });
                },
                onConfirm: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transaction Confirmed!')),
                  );
                },
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
              style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(color: Colors.white, fontSize: 16)),
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
      backgroundColor: Color(0xFF001F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "SELL CRYPTO",
                  style: TextStyle(
                    color: Color(0xFFB6FF68),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 24),
              Text("DESTINATION",
                  style: TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF092D25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Savings Account", style: TextStyle(color: Colors.white)),
                    Text(accountNumber, style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.credit_card, color: Colors.orange),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text("Available Balance",
                                style: TextStyle(color: Colors.white54)),
                            Text("PHP 45,267.91",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        )
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text("YOU SELL",
                  style: TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF00392F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _btcController,
                      onChanged: _updatePhpAmount,
                      keyboardType:
                      TextInputType.numberWithOptions(decimal: true),
                      style:
                      TextStyle(color: Colors.greenAccent, fontSize: 18),
                      decoration: InputDecoration(
                        labelText: "BTC Amount",
                        labelStyle: TextStyle(color: Colors.greenAccent),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.greenAccent),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text("1 BTC = 854,022.19",
                        style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text("YOU BUY",
                  style: TextStyle(
                      color: Colors.amber, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF00392F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "PHP ${phpAmount.toStringAsFixed(2)}",
                  style:
                  TextStyle(color: Color(0xFFB6FF68), fontSize: 24),
                ),
              ),
              Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFFB6FF68),
                        side: BorderSide(color: Color(0xFFB6FF68)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Cancel"),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFB6FF68),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      onPressed: () {
                        _showSlideToConfirmBottomSheet();
                      },
                      child: Text("Confirm"),
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
