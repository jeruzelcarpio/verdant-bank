// lib/cryptoMarket_page.dart
import 'package:flutter/material.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/investment_data.dart';
import 'package:verdantbank/buyCrypto_page.dart'; 
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/components/marketAsset_card.dart'; 

class CryptoMarketPage extends StatefulWidget {
  final Account account;
  final VoidCallback onUpdate;

  const CryptoMarketPage({
    Key? key,
    required this.account,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _CryptoMarketPageState createState() => _CryptoMarketPageState();
}

class _CryptoMarketPageState extends State<CryptoMarketPage> {
  late List<MarketAsset> cryptoMarketData;

  @override
  void initState() {
    super.initState();
    cryptoMarketData = simulatedMarketData
        .where((asset) => asset.type == AssetType.crypto)
        .toList();
  }

   void _refreshData() {
    if(mounted) {
       setState(() {});
       widget.onUpdate();
    }
   }

  void _navigateToBuyCrypto(MarketAsset asset) {
     Navigator.push(context, MaterialPageRoute(builder: (context) => BuyCryptoAmountPage(
       account: widget.account,
       assetToBuy: asset,
       onUpdate: widget.onUpdate,
     ))).then((_) => _refreshData()); // Refresh after returning
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
        title: const Text('BUY CRYPTO'),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.milk,
        elevation: 0,
      ),
      body: cryptoMarketData.isEmpty
          ? Center(child: Text('No crypto assets available.', style: TextStyle(color: AppColors.lighterGreen)))
          : ListView.builder(
              padding: const EdgeInsets.all(15.0),
              itemCount: cryptoMarketData.length,
              itemBuilder: (context, index) {
                final asset = cryptoMarketData[index];
                return MarketAssetCard( 
                  asset: asset,
                  onTap: () => _navigateToBuyCrypto(asset), 
              },
            ),
    );
  }
}