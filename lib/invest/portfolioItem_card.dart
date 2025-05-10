// lib/components/portfolioItem_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/investment_data.dart'; 
import 'package:verdantbank/theme/colors.dart';

class PortfolioItemCard extends StatelessWidget {
  final PortfolioItem item;
  // Removed currentValue - calculate it inside based on market data
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: 'PHP '); // Use PHP
  final NumberFormat quantityFormatter = NumberFormat("0.######"); // Allow more decimals
  final VoidCallback onSellPressed;
  final VoidCallback onBuyPressed; // Added Buy action

  PortfolioItemCard({
    Key? key,
    required this.item,
    required this.onSellPressed,
    required this.onBuyPressed, // Added
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find corresponding market data to get logo, price, % change
    MarketAsset? marketInfo = findMarketAsset(item.symbol, item.type);

    // Handle case where market data might be missing
    if (marketInfo == null) {
      return Card( // Display a simplified card or error message
          color: AppColors.green,
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          child: ListTile(title: Text('Error loading data for ${item.symbol}', style: TextStyle(color: Colors.red)))
      );
    }

    double currentValue = item.quantity * marketInfo.currentPrice;
    Color changeColor = marketInfo.percentChange >= 0 ? AppColors.lightGreen : Colors.redAccent;
    String changePrefix = marketInfo.percentChange >= 0 ? '+' : '';

    return Card(
      color: AppColors.green,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row( // Top section: Logo, Name, Value, Change
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(marketInfo.logoUrl), // Assumes local asset
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name, // Use item name
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.milk),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text( // Display quantity
                        'Qty: ${quantityFormatter.format(item.quantity)}',
                        style: TextStyle(fontSize: 12, color: AppColors.lighterGreen.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column( // Value and Change Column
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text( // Current Holding Value
                      currencyFormatter.format(currentValue),
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.milk),
                    ),
                    Text( // Percentage Change
                      '$changePrefix${marketInfo.percentChange.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 12, color: changeColor, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(color: AppColors.lighterGreen.withOpacity(0.2), height: 1),
            const SizedBox(height: 6),
            Row( // Bottom section: Buy/Sell Buttons
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out buttons
              children: [
                TextButton(
                  onPressed: onBuyPressed,
                  child: Text('BUY', style: TextStyle(color: AppColors.lightGreen, fontWeight: FontWeight.bold)),
                ),
                SizedBox( // Vertical divider
                  height: 20,
                  child: VerticalDivider(color: AppColors.lighterGreen.withOpacity(0.2), width: 1),
                ),
                TextButton(
                  onPressed: onSellPressed,
                  child: Text('SELL', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}