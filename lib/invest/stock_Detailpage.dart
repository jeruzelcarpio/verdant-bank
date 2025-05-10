// lib/stock_Detailpage.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/buyStock_page.dart'; 
import 'package:verdantbank/sellStock_page.dart'; 

class StockDetailPage extends StatefulWidget {
  final Account account;
  final MarketAsset asset;
  final PortfolioItem? portfolioItem; 
  final VoidCallback onUpdate;

  const StockDetailPage({
    Key? key,
    required this.account,
    required this.asset,
    this.portfolioItem,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage> {
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: 'PHP ');
  final NumberFormat quantityFormatter = NumberFormat("0.######");

  void _refreshData() {
    if (mounted) {
      setState(() {}); 
      widget.onUpdate();
    }
  }

  void _navigateToBuy() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BuyStockQuantityPage(
      account: widget.account,
      assetToBuy: widget.asset,
      onUpdate: widget.onUpdate,
    ))).then((_) => _refreshData());
  }

   void _navigateToSell() {
     if (widget.portfolioItem != null && widget.portfolioItem!.quantity > 0) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SellStockQuantityPage(
          account: widget.account,
          itemToSell: widget.portfolioItem!,
          marketInfo: widget.asset, 
          onUpdate: widget.onUpdate,
        ))).then((_) => _refreshData());
     } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You do not own any ${widget.asset.symbol} to sell.")));
     }
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
        title: Text(widget.asset.symbol),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.milk,
        elevation: 0,
      ),
      body: Column( 
        children: [
          Expanded( 
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Logo, Name, Price, Change
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(widget.asset.logoUrl),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.asset.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.milk)),
                            Text(widget.asset.symbol, style: TextStyle(fontSize: 14, color: AppColors.lighterGreen.withOpacity(0.7))),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(widget.asset.currentPrice),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.milk),
                          ),
                          Text(
                            '${widget.asset.percentChange >= 0 ? '+' : ''}${widget.asset.percentChange.toStringAsFixed(2)}%',
                            style: TextStyle(fontSize: 14, color: widget.asset.percentChange >= 0 ? AppColors.lightGreen : Colors.redAccent),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- Graph Placeholder ---
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                       color: AppColors.green.withOpacity(0.5),
                       borderRadius: BorderRadius.circular(10)
                    ),
                    child: Center(child: Text('Graph Placeholder', style: TextStyle(color: AppColors.lighterGreen))),
                    
                  ),
                  const SizedBox(height: 10),
                  // --- Time Filters (Placeholder) ---
                  Row(
                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                     children: ['1D', '1W', '1M', '3M', '1Y', 'ALL'].map((label) => TextButton(
                        onPressed: () {},
                        child: Text(label, style: TextStyle(color: AppColors.lighterGreen)),
                     )).toList(),
                  ),
                  const SizedBox(height: 25),

                  // --- Overview Section ---
                  Text('OVERVIEW', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.yellowGold)),
                  const SizedBox(height: 10),
                  _buildOverviewRow('Day High', currencyFormatter.format(widget.asset.dayHigh ?? 0)),
                  _buildOverviewRow('Day Low', currencyFormatter.format(widget.asset.dayLow ?? 0)),
                  _buildOverviewRow('Volume', NumberFormat.compact().format(widget.asset.volume ?? 0)), // Compact format for volume
                  _buildOverviewRow('Market', widget.asset.exchange ?? 'N/A'),
                  const SizedBox(height: 20),

                  // --- Display Owned Quantity (if applicable) ---
                   if (widget.portfolioItem != null && widget.portfolioItem!.quantity > 0) ...[
                       Text('YOUR HOLDINGS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.yellowGold)),
                       const SizedBox(height: 10),
                       _buildOverviewRow('Quantity', quantityFormatter.format(widget.portfolioItem!.quantity)),
                       _buildOverviewRow('Current Value', currencyFormatter.format(widget.portfolioItem!.quantity * widget.asset.currentPrice)),
                       const SizedBox(height: 20),
                   ]

                ],
              ),
            ),
          ),
          // --- Buy/Sell Buttons Footer ---
          Padding(
             padding: const EdgeInsets.fromLTRB(15, 5, 15, 15),
             child: Row(
               children: [
                 Expanded(
                   child: ElevatedButton(
                     onPressed: _navigateToSell, 
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Colors.redAccent.withOpacity(0.8),
                       foregroundColor: Colors.white,
                       padding: EdgeInsets.symmetric(vertical: 15),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                     ),
                     child: Text('SELL', style: TextStyle(fontWeight: FontWeight.bold)),
                   ),
                 ),
                 const SizedBox(width: 15),
                 Expanded(
                   child: ElevatedButton(
                     onPressed: _navigateToBuy, 
                     style: ElevatedButton.styleFrom(
                       backgroundColor: AppColors.lightGreen.withOpacity(0.9),
                       foregroundColor: AppColors.darkGreen,
                       padding: EdgeInsets.symmetric(vertical: 15),
                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                     ),
                     child: Text('BUY', style: TextStyle(fontWeight: FontWeight.bold)),
                   ),
                 ),
               ],
             ),
          ),
        ],
      ),
    );
  }

  // Helper widget for overview details
  Widget _buildOverviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.lighterGreen.withOpacity(0.8), fontSize: 14)),
          Text(value, style: TextStyle(color: AppColors.milk, fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}