// lib/sellCrypto_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/account.dart'; 
import 'package:verdantbank/invest_models.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/components/card.dart'; 
import 'package:verdantbank/authentication_otp.dart';

class SellCryptoAmountPage extends StatefulWidget {
  final Account account;
  final PortfolioItem itemToSell;
  final MarketAsset marketInfo; 
  final VoidCallback onUpdate;


  const SellCryptoAmountPage({
    Key? key,
    required this.account,
    required this.itemToSell,
    required this.marketInfo,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _SellCryptoAmountPageState createState() => _SellCryptoAmountPageState();
}

class _SellCryptoAmountPageState extends State<SellCryptoAmountPage> {
  final TextEditingController _cryptoAmountController = TextEditingController();
  double _phpAmountToReceive = 0.0;
  String? _errorText;

  final NumberFormat currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: 'PHP ');
  final NumberFormat cryptoQuantityFormatter = NumberFormat("0.########"); // More decimals for crypto

  @override
  void initState() {
    super.initState();
    _cryptoAmountController.addListener(_calculatePhpAmount);
  }

  @override
  void dispose() {
    _cryptoAmountController.removeListener(_calculatePhpAmount);
    _cryptoAmountController.dispose();
    super.dispose();
  }

  // Calculate PHP amount based on crypto input and current price
  void _calculatePhpAmount() {
     final double cryptoAmount = double.tryParse(_cryptoAmountController.text) ?? 0;
     if (cryptoAmount > 0 && widget.marketInfo.currentPrice > 0) {
       if(mounted) setState(() => _phpAmountToReceive = cryptoAmount * widget.marketInfo.currentPrice);
     } else {
        if(mounted) setState(() => _phpAmountToReceive = 0.0 );
     }
      // Dynamic quantity validation
      if (cryptoAmount > widget.itemToSell.quantity) {
          if(mounted) setState(() => _errorText = "Amount exceeds available quantity");
      } else if (_errorText == "Amount exceeds available quantity") {
          if(mounted) setState(() => _errorText = null);
      } else {
          if(mounted && _errorText != null && _errorText != "Please enter a valid amount") setState(() => _errorText = null); // Clear other errors
      }
  }


  void _proceedToConfirmation() {
    final double cryptoAmount = double.tryParse(_cryptoAmountController.text) ?? 0;

    // --- Validation ---
    if (cryptoAmount <= 0) {
      setState(() => _errorText = "Please enter a valid amount to sell");
      return;
    }
    if (cryptoAmount > widget.itemToSell.quantity) {
       setState(() => _errorText = "Amount exceeds available quantity");
      return;
    }
    if (_phpAmountToReceive <= 0 && cryptoAmount > 0) {
        // Price might be zero?
        setState(() => _errorText = "Cannot calculate amount to receive");
        return;
    }
    setState(() => _errorText = null); 

    // --- Navigate to Confirmation 
    print("Proceeding to Confirmation:");
    print("  Sell: ${cryptoQuantityFormatter.format(cryptoAmount)} ${widget.itemToSell.symbol}");
    print("  Receive (approx): ${currencyFormatter.format(_phpAmountToReceive)}");
    print("  To Account: ${widget.account.accNumber}"); // Destination is main account

     showDialog(
         context: context,
         builder: (ctx) => AlertDialog(
             backgroundColor: AppColors.green,
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
             title: Text("Confirm Sell", style: TextStyle(color: AppColors.milk)),
             content: Column( /* ... summary ... */),
             actions: [
                 TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text("Cancel", style: TextStyle(color: AppColors.lighterGreen))),
                 TextButton(onPressed: () {
                      Navigator.of(ctx).pop();
                      _navigateToOtp(cryptoAmount, _phpAmountToReceive); // Go to OTP next
                 }, child: Text("Confirm", style: TextStyle(color: AppColors.yellowGold))),
             ],
         )
     );
  }

  // This function called AFTER successful confirmation & OTP
  void _performSell(double cryptoAmountSold, double phpAmountReceived) {
    bool removalSuccess = widget.account.removeFromPortfolio(
      widget.itemToSell.symbol,
      widget.itemToSell.type,
      cryptoAmountSold
    );

    if (removalSuccess) {
        widget.account.accBalance += phpAmountReceived; // Add proceeds to main balance
        widget.account.addTransaction(Transaction(
          type: 'Sold Crypto',
          recipient: '${cryptoQuantityFormatter.format(cryptoAmountSold)} ${widget.itemToSell.symbol}',
          dateTime: DateFormat('MMM dd, yyyy, hh:mm a').format(DateTime.now()),
          amount: phpAmountReceived,
          isAdded: true, // Money received into main balance
        ));
        // --- End State Update ---

        // widget.onUpdate(); // Removed for independent version

        print("[SellCryptoPage] Sell successful. Balance: ${widget.account.accBalance}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully sold ${cryptoQuantityFormatter.format(cryptoAmountSold)} ${widget.itemToSell.symbol}')),
        );

         // For now, just pop back
        if(Navigator.canPop(context)) {
            Navigator.pop(context);
        }

    } else {
       print("[SellCryptoPage] Sell failed: Error removing from portfolio.");
       ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sell failed. Please try again.')),
        );
    }
  }


  @override
  Widget build(BuildContext context) {
    String availableQty = cryptoQuantityFormatter.format(widget.itemToSell.quantity);

    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        leading: IconButton( 
             icon: Icon(Icons.arrow_back, color: AppColors.milk),
             onPressed: () => Navigator.of(context).pop(),
         ),
        title: Text('SELL ${widget.itemToSell.symbol}'),
        backgroundColor: AppColors.darkGreen,
        foregroundColor: AppColors.milk,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Account Card 
            Text('DESTINATION', style: TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            CardIcon( 
              savingAccountNum: widget.account.accNumber,
              accountBalance: widget.account.accBalance, // Show current main balance
            ),
            const SizedBox(height: 30),

            // You Sell Section
            Text('YOU SELL', style: TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
             Text('Available: $availableQty ${widget.itemToSell.symbol}', style: TextStyle(color: AppColors.lighterGreen.withOpacity(0.7), fontSize: 12)),
             const SizedBox(height: 4),
            TextField(
              controller: _cryptoAmountController,
              style: TextStyle(color: AppColors.milk, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                suffixText: ' ${widget.itemToSell.symbol}', // Show unit
                suffixStyle: TextStyle(color: AppColors.lighterGreen.withOpacity(0.7), fontSize: 24),
                hintText: '0.00000000',
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
                 FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d*')), // Allow decimals
              ],
            ),
            const SizedBox(height: 30),

             // You Buy (Receive) Section
            Text('YOU BUY (Receive Approx.)', style: TextStyle(color: AppColors.yellowGold, fontWeight: FontWeight.bold, fontSize: 16)),
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
                   currencyFormatter.format(_phpAmountToReceive), // Display calculated PHP
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
                    child: Text("Cancel"), // Figma shows Cancel
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_errorText != null || _phpAmountToReceive <= 0) ? null : _proceedToConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lighterGreen,
                      foregroundColor: AppColors.darkGreen,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                       disabledBackgroundColor: AppColors.lighterGreen.withOpacity(0.5),
                    ),
                    child: Text("Confirm"), 
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