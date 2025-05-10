// lib/buyCrypto_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/components/card.dart'; 

class BuyCryptoAmountPage extends StatefulWidget {
  final Account account;
  final MarketAsset assetToBuy;
  final VoidCallback onUpdate;

  const BuyCryptoAmountPage({
    Key? key,
    required this.account,
    required this.assetToBuy,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _BuyCryptoAmountPageState createState() => _BuyCryptoAmountPageState();
}

class _BuyCryptoAmountPageState extends State<BuyCryptoAmountPage> {
  final TextEditingController _phpAmountController = TextEditingController();
  double _cryptoAmountToReceive = 0.0;
  String? _errorText;

  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: 'PHP ');
  final NumberFormat cryptoQuantityFormatter = NumberFormat("0.########"); // More decimals for crypto

  @override
  void initState() {
    super.initState();
    _phpAmountController.addListener(_calculateCryptoAmount);
  }

  @override
  void dispose() {
    _phpAmountController.removeListener(_calculateCryptoAmount);
    _phpAmountController.dispose();
    super.dispose();
  }

  // Calculate crypto amount based on PHP input and current price
  void _calculateCryptoAmount() {
    final double phpAmount = double.tryParse(_phpAmountController.text) ?? 0;
    if (phpAmount > 0 && widget.assetToBuy.currentPrice > 0) {
      setState(() {
        _cryptoAmountToReceive = phpAmount / widget.assetToBuy.currentPrice;
        _errorText = null; 
      });
    } else {
      setState(() {
        _cryptoAmountToReceive = 0.0;
      });
    }
     // Validate against balance dynamically
     if (phpAmount > widget.account.accBalance) {
        if(mounted) setState(() =>_errorText = "Amount exceeds available balance");
     };
       else if (_errorText == "Amount exceeds available balance") 
     {
         if(mounted) setState(() => _errortext = null);
     } else {
           if(mounted && _errorText != null && _errorText != "Please enter a valid amount") setState(() => _errorText = null); 
      }
  }
 

   void _proceedToConfirmation() {
    final double phpAmount = double.tryParse(_phpAmountController.text) ?? 0;

    // --- Validation ---
    if (phpAmount <= 0) {
      setState(() => _errorText = "Please enter a valid amount to spend");
      return;
    }
    if (phpAmount > widget.account.accBalance) {
      setState(() => _errorText = "Amount exceeds available balance");
      return;
    }
     if (_cryptoAmountToReceive <= 0) {
          setState(() => _errorText = "Cannot calculate amount to receive");
         return;
     }
     setState(() => _errorText = null); 

     // --- Navigate to Confirmation 
     print("Proceeding to Confirmation:");
     print("  Spend: ${currencyFormatter.format(phpAmount)}");
     print("  Receive: ${cryptoQuantityFormatter.format(_cryptoAmountToReceive)} ${widget.assetToBuy.symbol}");
     print("  From Account: ${widget.account.accNumber}");

     // Dialog for confirmation 
         context: context,
         builder: (ctx) => AlertDialog(
             title: Text("Confirm Buy"),
             content: Column(
                 mainAxisSize: MainAxisSize.min,
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                     Text("Spend: ${currencyFormatter.format(phpAmount)}"),
                     Text("Receive (approx): ${cryptoQuantityFormatter.format(_cryptoAmountToReceive)} ${widget.assetToBuy.symbol}"),
                     Text("From: ${widget.account.accNumber}"),
                     SizedBox(height: 10),
                     Text("Confirm transaction?", style: TextStyle(fontWeight: FontWeight.bold)),
                 ],
             ),
             actions: [
                 TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Cancel")),
                 TextButton(onPressed: () {
                      Navigator.of(ctx).pop(); // Close dialog
                      _performBuy(phpAmount, _cryptoAmountToReceive); // Execute the buy
                 }, child: Text("Confirm")),
             ],
         )
     );
   }

   // This function would be called AFTER confirmation 
  void _performBuy(double phpAmountSpent, double cryptoAmountReceived) {
     widget.account.accBalance -= phpAmountSpent;
     widget.account.addToPortfolio(PortfolioItem(
       symbol: widget.assetToBuy.symbol,
       name: widget.assetToBuy.name,
       quantity: cryptoAmountReceived, 
       type: widget.assetToBuy.type,
     ));
     widget.account.addTransaction(Transaction(
       type: 'Bought Crypto',
       recipient: '${cryptoQuantityFormatter.format(cryptoAmountReceived)} ${widget.assetToBuy.symbol}',
       dateTime: DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.now()),
       amount: phpAmountSpent,
       isAdded: false,
     ));
     // --- End State Update ---

     widget.onUpdate();

     
     print("[BuyCryptoAmountPage] Buy successful. Balance: ${widget.account.accBalance}");
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Successfully bought ${cryptoQuantityFormatter.format(cryptoAmountReceived)} ${widget.assetToBuy.symbol}')),
     );

     // For now, just pop back
     if(Navigator.canPop(context)) {
        Navigator.pop(context);
     }
   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text('BUY ${widget.assetToBuy.symbol}'),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.milk,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source Account Card
            Text('SOURCE', style: TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            CardIcon( // Use your CardIcon component
              savingAccountNum: widget.account.accNumber,
              accountBalance: widget.account.accBalance,
            ),
            const SizedBox(height: 30),

            // You Spend Section
            Text('YOU SPEND', style: TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _phpAmountController,
              style: TextStyle(color: AppColors.milk, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: 'PHP ',
                prefixStyle: TextStyle(color: AppColors.lighterGreen.withOpacity(0.7), fontSize: 24),
                hintText: '0.00',
                hintStyle: TextStyle(color: AppColors.lighterGreen.withOpacity(0.5), fontSize: 24),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.lighterGreen),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.yellowGold, width: 2),
                ),
                filled: true,
                fillColor: AppColors.green.withOpacity(0.5),
                errorText: _errorText,
                errorStyle: TextStyle(color: Colors.redAccent),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')), // Allow PHP format (2 decimal places)
              ],
            ),
            const SizedBox(height: 30),

             // You Buy Section
            Text('YOU BUY (Approx.)', style: TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
             Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.lighterGreen.withOpacity(0.5)),
                    color: AppColors.green.withOpacity(0.3)
                ),
                child: Text(
                   '${cryptoQuantityFormatter.format(_cryptoAmountToReceive)} ${widget.assetToBuy.symbol}',
                   style: TextStyle(color: AppColors.milk, fontSize: 24, fontWeight: FontWeight.bold),
                   textAlign: TextAlign.center,
                ),
             ),
            const SizedBox(height: 40),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkGreen, 
                      foregroundColor: AppColors.lighterGreen, 
                      side: BorderSide(color: AppColors.lighterGreen),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text("Back"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    // Disable button if error or amount is zero
                    onPressed: (_errorText != null || _cryptoAmountToReceive <= 0) ? null : _proceedToConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lighterGreen, // Light background
                      foregroundColor: AppColors.darkGreen, // Dark text
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      disabledBackgroundColor: AppColors.lighterGreen.withOpacity(0.5), 
                    ),
                    child: Text("Buy"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}