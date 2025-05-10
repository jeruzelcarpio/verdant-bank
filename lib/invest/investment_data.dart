// lib/investment_data.dart
import 'invest_models.dart';

const List<MarketAsset> simulatedMarketData = [
  // Stocks
  MarketAsset(symbol: "SPOT", name: "Spotify Technology S.A.", logoUrl: 'logos/spotify.png', currentPrice: 507.35, percentChange: 0.82, type: AssetType.stock, exchange: "NYSE", dayHigh: 510.00, dayLow: 505.00, volume: 1500000),
  MarketAsset(symbol: "AMZN", name: "Amazon", logoUrl: 'logos/amazon.png', currentPrice: 140.35, percentChange: 0.62, type: AssetType.stock, exchange: "NASDAQ", dayHigh: 142.00, dayLow: 139.50, volume: 45000000),
  MarketAsset(symbol: "KO", name: "Coca Cola", logoUrl: 'logos/cocacola.png', currentPrice: 60.15, percentChange: -0.51, type: AssetType.stock, exchange: "NYSE", dayHigh: 60.50, dayLow: 60.00, volume: 12000000),
  MarketAsset(symbol: "PEP", name: "PepsiCo", logoUrl: 'logos/pepsi.png', currentPrice: 170.15, percentChange: -0.61, type: AssetType.stock, exchange: "NASDAQ", dayHigh: 171.00, dayLow: 169.50, volume: 4000000),
  MarketAsset(symbol: "META", name: "Meta", logoUrl: 'logos/meta.png', currentPrice: 330.35, percentChange: 1.52, type: AssetType.stock, exchange: "NASDAQ", dayHigh: 335.00, dayLow: 328.00, volume: 25000000),
  MarketAsset(symbol: "UBER", name: "Uber", logoUrl: 'logos/uber.png', currentPrice: 45.35, percentChange: 0.82, type: AssetType.stock, exchange: "NYSE", dayHigh: 46.00, dayLow: 45.00, volume: 18000000),
  MarketAsset(symbol: "AAPL", name: "Apple", logoUrl: 'logos/apple.png', currentPrice: 175.80, percentChange: -0.62, type: AssetType.stock, exchange: "NASDAQ", dayHigh: 177.00, dayLow: 174.50, volume: 50000000),

  // Crypto
  MarketAsset(symbol: "BTC", name: "Bitcoin", logoUrl: 'logoss/bitcoin.png', currentPrice: 48123.67, percentChange: 0.82, type: AssetType.crypto),
  MarketAsset(symbol: "ETH", name: "Ethereum", logoUrl: 'logos/etherum.png', currentPrice: 3525.87, percentChange: -4.92, type: AssetType.crypto),
  MarketAsset(symbol: "SOL", name: "Solana", logoUrl: 'logos/solana.png', currentPrice: 150.25, percentChange: 1.50, type: AssetType.crypto),
];

// Helper function to find market data easily 
MarketAsset? findMarketAsset(String symbol, AssetType type) {
  try {
    return simulatedMarketData.firstWhere((a) => a.symbol == symbol && a.type == type);
  } catch (e) {
    return null; // Not found
  }
}