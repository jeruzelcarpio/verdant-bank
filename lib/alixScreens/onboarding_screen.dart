import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import '../theme/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          Container(
            color: AppColors.darkGreen,
          ),
          Container(
            color: AppColors.milk
          ),
          Container(
            color: AppColors.lighterGreen,
          ),
        ],
      ),
    );
  }
}
