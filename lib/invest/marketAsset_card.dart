// lib/components/marketAsset_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/theme/colors.dart'; 

class MarketAssetCard extends StatelessWidget {
  final MarketAsset asset;
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: 'PHP '); // Use PHP
  final VoidCallback onTap; // Renamed from onBuyPressed for more general use

  MarketAssetCard({
    Key? key,
    required this.asset,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color changeColor = asset.percentChange >= 0 ? AppColors.lightGreen : Colors.redAccent;
    String changePrefix = asset.percentChange >= 0 ? '+' : '';

    return Card(
      color: AppColors.green, // Use theme color
      margin: const EdgeInsets.symmetric(vertical: 5.0), // Figma seems to have less margin
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // More subtle rounding
      elevation: 1,
      child: InkWell( // Make the whole card tappable
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
          child: Row(
            children: [
              // Logo
              CircleAvatar(
                radius: 20,
                // Use Image.asset for local assets, Image.network for URLs
                // Add error handling for missing images
                backgroundImage: AssetImage(asset.logoUrl), // Assumes local asset
                backgroundColor: Colors.transparent, // Make background transparent
              ),
              const SizedBox(width: 12),
              // Name and Symbol Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.milk),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${asset.exchange ?? asset.type.name.toUpperCase()}: ${asset.symbol}", // Show exchange or type
                      style: TextStyle(fontSize: 12, color: AppColors.lighterGreen.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Price and Change Column
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormatter.format(asset.currentPrice),
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.milk),
                  ),
                  Text(
                    '$changePrefix${asset.percentChange.toStringAsFixed(2)}%',
                    style: TextStyle(fontSize: 12, color: changeColor, fontWeight: FontWeight.w500),
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
