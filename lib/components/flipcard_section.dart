import 'package:flutter/material.dart';
import 'package:verdantbank/components/card.dart';
import 'package:verdantbank/flipping_animation.dart';
import '../models/account.dart';
import '../theme/colors.dart';

class FlipCardSection extends StatefulWidget {
  final Account accountData;
  const FlipCardSection({Key? key, required this.accountData}) : super(key: key);

  @override
  State<FlipCardSection> createState() => _FlipCardSectionState();
}

class _FlipCardSectionState extends State<FlipCardSection> {
  bool _isFlipped = false;

  void _toggleCardFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _toggleCardFlip,
          child: FlipCard(
            isFlipped: _isFlipped,
            front: CardIcon(
              key: const ValueKey('front'),
              savingAccountNum: widget.accountData.accNumber,
              accountBalance: widget.accountData.accBalance,
            ),
            back: CardIcon(
              key: const ValueKey('back'),
              savingAccountNum: widget.accountData.accNumber,
              accountBalance: widget.accountData.accBalance,
              showBack: true,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _toggleCardFlip,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkGreen,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isFlipped ? Icons.rotate_left : Icons.rotate_right,
                color: AppColors.lighterGreen,
              ),
              const SizedBox(width: 8),
              Text(
                _isFlipped ? "Show Card" : "Show Account",
                style: const TextStyle(
                  color: AppColors.lighterGreen,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}