import 'dart:math';
import 'package:flutter/material.dart';

class FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;
  final bool isFlipped;
  final Duration duration;

  const FlipCard({
    Key? key,
    required this.front,
    required this.back,
    required this.isFlipped,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
      value: widget.isFlipped ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _controller.value * pi;
        return Stack(
          children: [
            // Front
            Opacity(
              opacity: angle <= pi / 2 ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: angle > pi / 2,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(angle),
                  child: widget.front,
                ),
              ),
            ),
            // Back
            Opacity(
              opacity: angle > pi / 2 ? 1.0 : 0.0,
              child: IgnorePointer(
                ignoring: angle <= pi / 2,
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(angle - pi),
                  child: widget.back,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}