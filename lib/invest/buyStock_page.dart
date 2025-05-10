import 'package:flutter/material.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:intl/intl.dart';

class BuyStockQuantityPage extends StatelessWidget {
    final Account account;
    final MarketAsset assetToBuy;
    final VoidCallback onUpdate;

    const BuyStockQuantityPage({
        Key? key,
        required this.account,
        required this.assetToBuy,
        required this.onUpdate,
        }) : super(key: key);

    @override
    _BuyStockQuantityPageState createState() => _BuyStockQuantityPageState();
}

class _BuyStockQuantityPageState extends State<BuyStockQuantityPage> {
     final TextEditingController _quantityController = TextEditingController();      
   
   
    @override
    Widget build(BuildContext context) {
        return Scaffold(
            backgroundColor: AppColors.darkGreen,
            appBar: AppBar(title: Text("Buy ${assetToBuy.symbol}"), backgroundColor: AppColors.green, foregroundColor: AppColors.milk,),
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text("Enter QUANTITY of ${assetToBuy.symbol} to buy", style: TextStyle(color: AppColors.milk, fontSize: 18), textAlign: TextAlign.center,),
                            SizedBox(height: 20),
                            Text("Available Balance: ${NumberFormat.currency(locale: 'en_US', symbol: 'PHP ').format(account.accBalance)}", style: TextStyle(color: AppColors.lighterGreen)),
                            SizedBox(height: 20),
                            // TODO: Add TextField for Quantity, validation, confirmation logic -> Frame 10 -> Swipe -> OTP -> performBuy -> Receipt
                            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Back (Placeholder)"))
                        ],
                    ),
                )
            ),
        );
    }
}