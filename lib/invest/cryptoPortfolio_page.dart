// lib/cryptoPortfolio_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/investment_data.dart';
import 'package:verdantbank/cryptoMarket_page.dart'; 
import 'package:verdantbank/buyCrypto_page.dart'; 
import 'package:verdantbank/sellCrypto_page.dart'; 
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/components/portfolioItem_card.dart';

class CryptoPortfolioPage extends StatefulWidget {
  final Account account;
  final VoidCallback onUpdate;

  const CryptoPortfolioPage({
    Key? key,
    required this.account,
    required this.onUpdate, 
    }) : super(key: key);


  @override
  _CryptoPortfolioPageState createState() => _CryptoPortfolioPageState();
}

class _CryptoPortfolioPageState extends State<CryptoPortfolioPage> {
  late double _totalCryptoValue;
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
    final cryptoPortfolio = widget.account.portfolio.where((item) => item.type == AssetType.crypto).toList();
    _totalCryptoValue = cryptoPortfolio.fold(0.0, (sum, item) {
       MarketAsset? marketInfo = findMarketAsset(item.symbol, item.type);
       return sum + (item.quantity * (marketInfo?.currentPrice ?? 0));
    });
  }

  void _navigateToBuy(PortfolioItem item) {
     MarketAsset? marketInfo = findMarketAsset(item.symbol, item.type);
     if(marketInfo != null) {
       Navigator.push(context, MaterialPageRoute(builder: (context) => BuyCryptoAmountPage(
         account: widget.account,
         assetToBuy: marketInfo,
        onUpdate: widget.onUpdate,
       ))).then((_) => _refreshData()); 
     }
  }

   void _navigateToSell(PortfolioItem item) {
     MarketAsset? marketInfo = findMarketAsset(item.symbol, item.type);
     if(marketInfo != null) {
       Navigator.push(context, MaterialPageRoute(builder: (context) => SellCryptoAmountPage(
         account: widget.account,
         itemToSell: item,
         marketInfo: marketInfo, 
         onUpdate: widget.onUpdate,
       ))).then((_) => _refreshData()); 
     }
  }

  @override
  Widget build(BuildContext context) {
    final List<PortfolioItem> cryptoPortfolio = widget.account.portfolio
        .where((item) => item.type == AssetType.crypto)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: const Text('CRYPTO PORTFOLIO'),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.milk,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.storefront),
            tooltip: 'Crypto Market',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CryptoMarketPage(
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
              Text(
                'Total Value',
                style: TextStyle(fontSize: 16, color: AppColors.lighterGreen),
              ),
              Text(
                currencyFormatter.format(_totalCryptoValue),
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.milk),
              ),
              const SizedBox(height: 25),

              // Portfolio List
              Text(
                'Your Crypto Portfolio',
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.milk),
              ),
              const SizedBox(height: 10),
              cryptoPortfolio.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'You hold no crypto assets.',
                          style: TextStyle(fontSize: 16, color: AppColors.lighterGreen),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: cryptoPortfolio.length,
                      itemBuilder: (context, index) {
                        final item = cryptoPortfolio[index];
                        return PortfolioItemCard( 
                          item: item,
                          onSellPressed: () => _navigateToSell(item), 
                          onBuyPressed: () => _navigateToBuy(item), 
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