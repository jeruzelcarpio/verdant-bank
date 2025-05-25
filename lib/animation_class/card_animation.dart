import 'package:flutter/material.dart';

class RotationYTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const RotationYTransition({
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = animation.value * 3.1415926535897932; // Convert to radians
        final isFlipped = angle > 3.1415926535897932 / 2;

        return Transform(
          transform: Matrix4.rotationY(angle),
          alignment: Alignment.center,
          child: isFlipped
              ? Opacity(opacity: 0, child: child) // Hide the back side
              : child,
        );
      },
      child: child,
    );
  }
}