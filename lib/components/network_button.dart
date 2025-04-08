import 'package:flutter/material.dart';

class NetworkButton extends StatelessWidget {
  final String network;
  final String imagePath;
  final Color bgColor;
  final bool isSelected;
  final VoidCallback onTap;

  const NetworkButton({
    Key? key,
    required this.network,
    required this.imagePath,
    required this.bgColor,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF54291) : bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sim_card,
              color: isSelected ? Colors.white : Colors.black,
              size: 24,
            ),
            SizedBox(height: 5),
            Text(
              network,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
