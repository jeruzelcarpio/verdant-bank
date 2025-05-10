// lib/stockPortfolio_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/investment_data.dart';
import 'package:verdantbank/stockMarket_page.dart'; 
import 'package:verdantbank/stock_Detailpage.dart'; 
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/components/portfolioItem_card.dart';

class StockPortfolioPage extends StatefulWidget {
  final Account account;
  final VoidCallback onUpdate;

  const StockPortfolioPage({
    Key? key,
    required this.account,
    required this.onUpdate, 
    }) : super(key: key);


  @override
  _StockPortfolioPageState createState() => _StockPortfolioPageState();
}

class _StockPortfolioPageState extends State<StockPortfolioPage> {
  late double _totalStockValue;
  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: 'PHP ');

  @override
  void initState() {
    super.initState();
    _calculateValue();
  }

  void _refreshData() {
    if (mounted) {
      setState(() {
        _calculateValue();
      });
      widget.onUpdate();
    }
  }

  void _calculateValue() {
    final stockPortfolio = widget.account.portfolio.where((item) => item.type == AssetType.stock).toList();
    _totalStockValue = stockPortfolio.fold(0.0, (sum, item) {
       MarketAsset? marketInfo = findMarketAsset(item.symbol, item.type);
       return sum + (item.quantity * (marketInfo?.currentPrice ?? 0));
    });
    print("[StockPortfolioPage] Calculated Value: $_totalStockValue");
  }
  }

  void _navigateToStockDetail(PortfolioItem item) {
     MarketAsset? marketInfo = findMarketAsset(item.symbol, item.type);
     if(marketInfo != null) {
       Navigator.push(context, MaterialPageRoute(builder: (context) => StockDetailPage(
         account: widget.account,
         asset: marketInfo, 
         portfolioItem: item, 
         onUpdate: widget.onUpdate,
       ))).then((_) => _refreshData()); 
     } else {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Could not load details for ${item.symbol}")));
     }
  }


  @override
  Widget build(BuildContext context) {
    final List<PortfolioItem> stockPortfolio = widget.account.portfolio
        .where((item) => item.type == AssetType.stock)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        leading: IconButton( 
             icon: Icon(Icons.arrow_back, color: AppColors.milk),
             onPressed: () => Navigator.of(context).pop(),
         ),
        title: const Text('STOCK PORTFOLIO'),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.milk,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.storefront),
            tooltip: 'Stock Market',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StockMarketPage(
                  account: widget.account,
                  onUpdate: widget.onUpdate,
              ))).then((_) => _refreshData()); 
            },
          ),
        ],
      ),
      body: RefreshIndicator( 
        onRefresh: () async => _refreshData(),
        color: AppColors.yellowGold,
        backgroundColor: AppColors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Value Display
              Text(
                'Total Value',
                style: TextStyle(fontSize: 16, color: AppColors.lighterGreen),
              ),
              Text(
                currencyFormatter.format(_totalStockValue),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.milk),
              ),
              const SizedBox(height: 25),

              // Portfolio List
              Text(
                'Your Stock Portfolio',
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.milk),
              ),
              const SizedBox(height: 10),
              stockPortfolio.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'You hold no stock assets.',
                          style: TextStyle(fontSize: 16, color: AppColors.lighterGreen),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: stockPortfolio.length,
                      itemBuilder: (context, index) {
                        final item = stockPortfolio[index];
                        return PortfolioItemCard(
                          item: item,
                          onSellPressed: () => _navigateToStockDetail(item), // Go to detail
                          onBuyPressed: () => _navigateToStockDetail(item), // Go to detail
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}