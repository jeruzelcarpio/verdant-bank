import 'package:flutter/material.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:intl/intl.dart';


class SellStockQuantityPage extends StatelessWidget {
    final Account account;
    final PortfolioItem itemToSell;
    final MarketAsset marketInfo; 
    final VoidCallback onUpdate;

    const SellStockQuantityPage({
        Key? key,
        required this.account,
        required this.itemToSell,
        required this.marketInfo,
        required this.onUpdate,
        }) : super(key: key);

    @override
    _SellStockQuantityPageState createState() => _SellStockQuantityPageState();
}

class _SellStockQuantityPageState extends State<SellStockQuantityPage> {
     final TextEditingController _quantityController = TextEditingController();

    
    @override
    Widget build(BuildContext context) {
        return Scaffold(
             backgroundColor: AppColors.darkGreen,
            appBar: AppBar(title: Text("Sell ${itemToSell.symbol}"), backgroundColor: AppColors.green, foregroundColor: AppColors.milk,),
             body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            Text("Enter QUANTITY of ${itemToSell.symbol} to sell", style: TextStyle(color: AppColors.milk, fontSize: 18), textAlign: TextAlign.center,),
                            SizedBox(height: 20),
                            Text("Available Quantity: ${NumberFormat("0.######").format(itemToSell.quantity)}", style: TextStyle(color: AppColors.lighterGreen)),
                            SizedBox(height: 20),
                            ElevatedButton(onPressed: () => Navigator.pop(context), child: Text("Back (Placeholder)"))
                        ],
                    ),
                )
            ),
        );
    }
}