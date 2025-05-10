// lib/invest_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/account.dart';
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/investment_data.dart';
import 'package:verdantbank/market_page.dart';
import 'package:verdantbank/theme/colors.dart'; 
import 'package:verdantbank/components/portfolioItem_card.dart'; 

class InvestPage extends StatefulWidget {
  final Account account; 
  final VoidCallback onUpdate;

  const InvestPage({
    Key? key,
    required this.account,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  late double _totalPortfolioValue;
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final NumberFormat quantityFormatter = NumberFormat("0.######");

  @override
  void initState() {
    super.initState();
    _calculateValue();
  }

  void _calculateValue() {
    // Uses the account object passed into the widget
    _totalPortfolioValue = widget.account.calculatePortfolioValue(simulatedMarketData);
    // Update the UI of *this* page
    if (mounted) { // Check if widget is still in the tree
       setState(() {});
    }
    print("[InvestPage] Portfolio Value Recalculated: $_totalPortfolioValue");
  }

  // --- Sell Logic ---
  void _showSellDialog(PortfolioItem itemToSell) {
    MarketAsset? marketInfo;
    try {
      marketInfo = simulatedMarketData.firstWhere((asset) =>
          asset.symbol == itemToSell.symbol && asset.type == itemToSell.type);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Market data not found.')),
      );
      return;
    }
    final currentPrice = marketInfo.currentPrice;
    final sellController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Sell ${itemToSell.symbol}', style: TextStyle(color: AppColors.milk)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                    'Available: ${quantityFormatter.format(itemToSell.quantity)}\nCurrent Price: ${currencyFormatter.format(currentPrice)}',
                    style: TextStyle(color: AppColors.lighterGreen)),
                SizedBox(height: 15),
                TextField(
                  controller: sellController,
                  style: TextStyle(color: AppColors.milk),
                  decoration: InputDecoration(
                    labelText: 'Quantity to Sell',
                    labelStyle: TextStyle(color: AppColors.lighterGreen),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.lighterGreen)),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColors.yellowGold)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                     FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')),
                  ],
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: AppColors.lighterGreen)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Confirm Sell', style: TextStyle(color: AppColors.yellowGold)),
              onPressed: () {
                double? quantityToSell = double.tryParse(sellController.text);
                if (quantityToSell == null || quantityToSell <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid positive quantity.')),
                  );
                  return;
                }
                _performSell(itemToSell, quantityToSell, currentPrice);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) => sellController.dispose());
  }

  void _performSell(PortfolioItem item, double quantityToSell, double price) {
    final bool success = widget.account.removeFromPortfolio(item.symbol, item.type, quantityToSell);

    if (success) {
      double proceeds = quantityToSell * price;
      // --- Update "Shared" (Temporary) State ---
      widget.account.accBalance += proceeds; // Add proceeds to temporary balance

      // --- Record Transaction (in Temporary Account) ---
      widget.account.addTransaction(Transaction(
          type: 'Sold Asset',
          recipient: '${quantityFormatter.format(quantityToSell)} ${item.symbol}',
          dateTime: DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.now()),
          amount: proceeds,
          isAdded: true,
       ));
      // --- End State Update ---

      _calculateValue(); // Recalculate portfolio value for local UI
      // widget.onUpdate(); // <-- REMOVED for independent version

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Successfully sold ${quantityFormatter.format(quantityToSell)} ${item.symbol}')),
      );
       print("[InvestPage] Balance after sell: ${widget.account.accBalance}");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sell failed: Insufficient quantity of ${item.symbol}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: const Text('Investments'),
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.milk,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Portfolio Summary Card ---
            Container(
               width: double.infinity,
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AppColors.green,
                 borderRadius: BorderRadius.circular(15)
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                    Text(
                      'Total Portfolio Value',
                      style: TextStyle(fontSize: 16, color: AppColors.lighterGreen),
                    ),
                    SizedBox(height: 5),
                    Text(
                      currencyFormatter.format(_totalPortfolioValue),
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.milk),
                    ),
                    // Optionally display main balance for context (using temp account)
                    SizedBox(height: 10),
                    Text(
                      'Main Acc Balance: ${currencyFormatter.format(widget.account.accBalance)}',
                      style: TextStyle(fontSize: 14, color: AppColors.lighterGreen.withOpacity(0.8)),
                    ),
                 ],
               ),
            ),
            const SizedBox(height: 30),

            // --- My Holdings Section ---
            Text(
              'My Holdings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.milk),
            ),
            const SizedBox(height: 15),

            widget.account.portfolio.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0),
                      child: Text(
                        'You have no investments yet.',
                        style: TextStyle(fontSize: 16, color: AppColors.lighterGreen),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: widget.account.portfolio.length,
                    itemBuilder: (context, index) {
                      final item = widget.account.portfolio[index];
                      double currentValue = 0;
                      // Find current market price to calculate value
                      try {
                        MarketAsset marketInfo = simulatedMarketData.firstWhere((asset) =>
                            asset.symbol == item.symbol && asset.type == item.type);
                        currentValue = item.quantity * marketInfo.currentPrice;
                      } catch (e) { /* ignore */ }

                      return PortfolioItemCard( // Use the component
                        item: item,
                        currentValue: currentValue,
                        currencyFormatter: currencyFormatter,
                        quantityFormatter: quantityFormatter,
                        onSellPressed: () => _showSellDialog(item),
                      );
                    },
                  ),
            const SizedBox(height: 30),

            // --- Browse Market Button ---
            Center(
              child: ElevatedButton.icon(
                 icon: const Icon(Icons.store, color: AppColors.darkGreen),
                 label: Text('Browse Market (Buy)', style: TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.bold)),
                 style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.yellowGold,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                 ),
                 onPressed: () async {
                     // Navigate to MarketPage
                     // Use 'await' to recalculate value after returning from MarketPage
                     await Navigator.push(
                       context,
                       MaterialPageRoute(
                         builder: (context) => MarketPage(
                           account: widget.account, // Pass the SAME account object
                           marketData: simulatedMarketData,
                           // onUpdate: () {} // REMOVED for independent version
                         ),
                       ),
                     );
                     // Recalculate value when returning to this screen
                     _calculateValue();
                 },
              ),
            ),
             const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}