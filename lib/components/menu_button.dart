import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:verdantbank/theme/colors.dart';

class MenuButton extends StatefulWidget {
  final String buttonName;
  final IconData icon;
  final Color bgColor;
  final Color onPressColor;
  final double size; // parameter to control size
  final VoidCallback? onPressed;
  final bool isActive; // new parameter to control active state

  const MenuButton({
    Key? key,
    required this.buttonName,
    required this.icon,
    required this.bgColor,
    required this.onPressColor,
    this.size = 72, // default square size
    this.onPressed,
    this.isActive = true, // default to active
  }) : super(key: key);

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  void _handleTap() {
    if (widget.isActive && widget.onPressed != null) {
      widget.onPressed!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isActive ? _handleTap : null,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: widget.isActive ? widget.bgColor : AppColors.green,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.isActive ? Colors.black : Colors.white,
              size: 24,
            ),
            SizedBox(height: 2),
            Flexible(
              child: Text(
                widget.buttonName,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis, // trims overflow with "..."
                maxLines: 2,
                style: TextStyle(
                  color: widget.isActive ? Colors.black : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}