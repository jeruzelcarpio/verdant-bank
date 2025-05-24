import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:verdantbank/theme/colors.dart';


String formatAccountNumber(String input) {
  if (input.length < 10) return input;
  final part1 = input.substring(0, 4);
  final part2 = input.substring(4, 8);
  final part3 = input.substring(8, 10);
  return '$part1 $part2 $part3';
}

class CardIcon extends StatelessWidget {
  final String savingAccountNum;
  final double accountBalance;

  const CardIcon({
    Key? key,
    required this.savingAccountNum,
    required this.accountBalance,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedBalance = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: 2,
    ).format(accountBalance);

    return Stack(
      children: [
        // Gradient border
        Container(
          width: double.infinity,
          height: 185,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(255, 255, 255, 0.3),
                Color.fromRGBO(255, 255, 255, 0.05),
              ],
              stops: [0.0, 1.0],
            ),
          ),
        ),
        // Card content
        Container(
          width: double.infinity,
          height: 185,
          margin: const EdgeInsets.all(0.5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                // Chip at bottom left
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/card_chip.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                // Main card content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Savings Account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          formatAccountNumber(savingAccountNum),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    // Mastercard logo and balance row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Mastercard logo aligned right above balance
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Image.asset(
                                'assets/mastercard_logo.png',
                                width: 50,
                                height: 30,
                              ),
                            ),
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                color: AppColors.milk,
                                fontSize: 12,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'PHP ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  formattedBalance,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}