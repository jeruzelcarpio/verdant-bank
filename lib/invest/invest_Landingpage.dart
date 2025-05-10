// lib/invest_landing_page.dart
import 'package:flutter/material.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/cryptoPortfolio_page.dart'; 
import 'package:verdantbank/stockPortfolio_page.dart'; 
import 'package:verdantbank/theme/colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InvestLandingPage extends StatelessWidget {
  final Account account; 
  final VoidCallback onUpdate;
  
  const InvestLandingPage({
    Key? key,
    required this.account,
    required this.onUpdate, 
    }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        leading: IconButton( 
             icon: Icon(Icons.arrow_back, color: AppColors.milk),
             onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('INVEST'),
        backgroundColor: AppColors.darkGreen, 
        foregroundColor: AppColors.milk,
        elevation: 0, 
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              Text(
                'INVEST WITH',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lighterGreen,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildInvestButton(
                    context: context,
                    label: 'Crypto',
                    icon: FontAwesomeIcons.bitcoin, 
                    targetPage: CryptoPortfolioPage(account: account),
                    onUpdate: onUpdate,
                   ), 
                  ),
                  const SizedBox(width: 20), 
                  _buildInvestButton(
                    context: context,
                    label: 'Stocks',
                    icon: FontAwesomeIcons.arrowTrendUp, 
                    targetPage: StockPortfolioPage(account: account),
                    onUpdate: onUpdate,
                   ), 
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Widget targetPage,
  }) {
    return ElevatedButton.icon(
      icon: FaIcon(icon, size: 24, color: AppColors.darkGreen),
      label: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lighterGreen, 
        foregroundColor: AppColors.darkGreen, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40), 
        minimumSize: Size(130, 100), 
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
    );
  }
}