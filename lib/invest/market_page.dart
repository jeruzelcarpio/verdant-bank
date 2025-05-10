// lib/market_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/theme/colors.dart'; 
import 'package:verdantbank/components/marketAsset_card.dart'; 

class MarketPage extends StatefulWidget {
  final Account account; 
  final List<MarketAsset> marketData;
  final VoidCallback onUpdate;

  const MarketPage({
    Key? key,
    required this.account,
    required this.marketData,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _MarketPageState createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  final NumberFormat quantityFormatter = NumberFormat("0.######");

  // --- Buy Logic ---
  void _showBuyDialog(MarketAsset assetToBuy) {
     final buyController = TextEditingController();

     showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('Buy ${assetToBuy.symbol}', style: TextStyle(color: AppColors.milk)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text(
                    'Current Price: ${currencyFormatter.format(assetToBuy.currentPrice)}\nAvailable Balance: ${currencyFormatter.format(widget.account.accBalance)}',
                    style: TextStyle(color: AppColors.lighterGreen)),
                SizedBox(height: 15),
                TextField(
                  controller: buyController,
                  style: TextStyle(color: AppColors.milk),
                  decoration: InputDecoration(
                    labelText: 'Quantity to Buy',
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
              child: Text('Confirm Buy', style: TextStyle(color: AppColors.yellowGold)),
              onPressed: () {
                double? quantityToBuy = double.tryParse(buyController.text);
                if (quantityToBuy == null || quantityToBuy <= 0) {
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid positive quantity.')),
                  );
                  return;
                }
                _performBuy(assetToBuy, quantityToBuy);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    ).then((_) => buyController.dispose());
  }

  void _performBuy(MarketAsset asset, double quantityToBuy) {
     double totalCost = quantityToBuy * asset.currentPrice;

     if (widget.account.accBalance >= totalCost) {
        // --- Update "Shared" (Temporary) State ---
        widget.account.accBalance -= totalCost; // Deduct cost

        // --- Add to Portfolio (in Temporary Account) ---
        widget.account.addToPortfolio(PortfolioItem(
          symbol: asset.symbol,
          name: asset.name,
          quantity: quantityToBuy,
          type: asset.type,
        ));

        // --- Record Transaction (in Temporary Account) ---
        widget.account.addTransaction(Transaction(
           type: 'Bought Asset',
           recipient: '${quantityFormatter.format(quantityToBuy)} ${asset.symbol}',
           dateTime: DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.now()),
           amount: totalCost,
           isAdded: false,
        ));
        // --- End State Update ---

        // widget.onUpdate(); // <-- REMOVED for independent version

        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Successfully bought ${quantityFormatter.format(quantityToBuy)} ${asset.symbol}')),
        );
        // Update UI of this screen if needed (e.g., if balance was displayed)
        if(mounted) {
            setState(() {});
        }
         print("[MarketPage] Balance after buy: ${widget.account.accBalance}");

     } else {
        ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('Buy failed: Insufficient funds.')),
        );
        print("[MarketPage] Buy failed: Insufficient funds.");
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: const Text('Market'),
        backgroundColor: AppColors.green,
        foregroundColor: AppColors.milk,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15.0),
        itemCount: widget.marketData.length,
        itemBuilder: (context, index) {
          final asset = widget.marketData[index];
          // Use the reusable card widget
          return MarketAssetCard(
            asset: asset,
            currencyFormatter: currencyFormatter,
            onBuyPressed: () => _showBuyDialog(asset),
          );
        },
      ),
    );
  }
}