// lib/stockMarket_page.dart
import 'package:flutter/material.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/investment_data.dart';
import 'package:verdantbank/stock_Detailpage.dart'; 
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/components/marketAsset_card.dart';

class StockMarketPage extends StatefulWidget {
  final Account account;
  final VoidCallback onUpdate;

  const StockMarketPage({
    Key? key,
    required this.account,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _StockMarketPageState createState() => _StockMarketPageState();
}

class _StockMarketPageState extends State<StockMarketPage> {
  late List<MarketAsset> stockMarketData;

  @override
  void initState() {
    super.initState();
    stockMarketData = simulatedMarketData
        .where((asset) => asset.type == AssetType.stock)
        .toList();
  }

  void _refreshData() {
     if(mounted) {
       setState(() {});
       widget.onUpdate();
     }
   }

  void _navigateToStockDetail(MarketAsset asset) {
     PortfolioItem? ownedItem;
     try {
       ownedItem = widget.account.portfolio.firstWhere((p) => p.symbol == asset.symbol && p.type == AssetType.stock);
     } catch (e) {
       ownedItem = null; 
     }

     Navigator.push(context, MaterialPageRoute(builder: (context) => StockDetailPage(
       account: widget.account,
       asset: asset,
       portfolioItem: ownedItem, 
       onUpdate: widget.onUpdate,
     ))).then((_) => _refreshData()); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        leading: IconButton( 
             icon: Icon(Icons.arrow_back, color: AppColors.milk),
             onPressed: () => Navigator.of(context).pop(),
         ),
        title: const Text('MARKET'), 
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.milk,
        elevation: 0,
      ),
      body: stockMarketData.isEmpty
          ? Center(child: Text('No stock assets available.', style: TextStyle(color: AppColors.lighterGreen)))
          : ListView.builder(
              padding: const EdgeInsets.all(15.0),
              itemCount: stockMarketData.length,
              itemBuilder: (context, index) {
                final asset = stockMarketData[index];
                return MarketAssetCard(
                  asset: asset,
                  onTap: () => _navigateToStockDetail(asset), 
                );
              },
            ),
    );
  }
}