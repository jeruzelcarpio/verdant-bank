import 'package:flutter/material.dart';
import 'package:verdantbank/components/card.dart';
import 'theme/colors.dart';
const String savingAccount_num = "1039 4448 75";
double balance = 34895.091;



class TransferPageee extends StatefulWidget {
  @override
  _TransferPageeeState createState() => _TransferPageeeState();
}

class _TransferPageeeState extends State<TransferPageee> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        title: Text(
          'TRANSFER',
          style: TextStyle(
            color: AppColors.lighterGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.darkGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SOURCE',
              style: TextStyle(
                color: AppColors.yellowGold,
                fontWeight: FontWeight.w600,
                fontSize: 16, // Optional: Adjust font size
              ),
            ),
            SizedBox(height: 0.8), // Add spacing between the text and the card
            CardIcon(
              savingAccountNum: savingAccount_num,
              accountBalance: balance,
            ),
          ],
        ),
      ),
    );
  }
}