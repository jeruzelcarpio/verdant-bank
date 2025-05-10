// lib/invest_models.dart
import 'package:flutter/foundation.dart'; // Only needed for @required in older Flutter versions

// Define the types of assets
enum AssetType { stock, crypto }

// Represents an asset available in the market
class MarketAsset {
  final String symbol;
  final String name;
  final String logoUrl; 
  final double currentPrice;
  final double percentChange; 
  final AssetType type;
  final String? exchange;
  final double? dayHigh;
  final double? dayLow;
  final double? volume; 

  const MarketAsset({
    required this.symbol,
    required this.name,
    required this.logoUrl, // Added
    required this.currentPrice,
    required this.percentChange, // Added
    required this.type,
    this.exchange,
    this.dayHigh,
    this.dayLow,
    this.volume,
  });
}

class PortfolioItem {
  final String symbol;
  final String name;
  double quantity;
  final AssetType type;
  

  PortfolioItem({
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.type,
  });
}