import 'package:flutter/material.dart';

class SlideToConfirm extends StatefulWidget {
  final double sliderValue;
  final ValueChanged<double> onChanged;
  final VoidCallback? onConfirm;  // New callback for confirmation

  const SlideToConfirm({
    Key? key,
    required this.sliderValue,
    required this.onChanged,
    this.onConfirm,  // Optional callback when slide is completed
  }) : super(key: key);

  @override
  _SlideToConfirmState createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  late double _internalValue;
  bool _isSliding = false;

  @override
  void initState() {
    super.initState();
    _internalValue = widget.sliderValue;
  }

  @override
  void didUpdateWidget(covariant SlideToConfirm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sliderValue != widget.sliderValue) {
      _internalValue = widget.sliderValue;
    }
  }

  void _handleSliderChange(double value) {
    setState(() {
      _internalValue = value;
      _isSliding = true;
    });
    widget.onChanged(value);
  }

  void _handleSliderEnd(double value) {
    setState(() {
      _isSliding = false;
      if (value >= 0.95) {
        _internalValue = 1.0;
        // Call onConfirm callback when slider reaches the end
        if (widget.onConfirm != null) {
          widget.onConfirm!();
        }
      } else {
        // Only reset if not completed
        _internalValue = 0.0;
      }
    });
    widget.onChanged(_internalValue);
  }

  void _handleSliderStart(double value) {
    setState(() {
      _isSliding = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF0F2633),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _internalValue >= 0.95 ? 'Confirmed!' : 'Slide to confirm',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Stack(
            alignment: Alignment.center,
            children: [
              // Track background
              Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Color(0xFF0A1922),
                ),
              ),
              // Progress indicator
              Positioned(
                left: 0,
                child: Container(
                  height: 60,
                  width: MediaQuery.of(context).size.width * _internalValue * 0.7,  // Adjust width based on parent container
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    gradient: LinearGradient(
                      colors: [Color(0xFF0F2633), Color(0xFFC1FD52).withOpacity(0.3)],
                    ),
                  ),
                ),
              ),
              // Slider hint text
              Positioned(
                right: 50,
                child: AnimatedOpacity(
                  opacity: _internalValue < 0.7 ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    "Slide all the way >>>",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
              // Actual slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: Color(0xFFC1FD52),
                  overlayColor: Color(0xFFC1FD52).withOpacity(0.3),
                  trackHeight: 60.0,
                  thumbShape: _CustomThumbShape(),
                ),
                child: Slider(
                  value: _internalValue,
                  onChanged: _handleSliderChange,
                  onChangeEnd: _handleSliderEnd,
                  onChangeStart: _handleSliderStart,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  final double enabledThumbRadius = 20;
  final double disabledThumbRadius = 10;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? enabledThumbRadius : disabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final bool isCompleted = value >= 0.95;
    
    final Paint fillPaint = Paint()
      ..color = isCompleted ? Color(0xFFC1FD52) : sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw the thumb circle
    canvas.drawCircle(center, enabledThumbRadius, fillPaint);
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);

    // Draw different icons based on state
    if (isCompleted) {
      // Draw checkmark if confirmed
      final Paint checkPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      
      final Path checkPath = Path();
      final double checkSize = enabledThumbRadius * 0.9;
      
      checkPath.moveTo(center.dx - checkSize/2, center.dy);
      checkPath.lineTo(center.dx - checkSize/6, center.dy + checkSize/2);
      checkPath.lineTo(center.dx + checkSize/2, center.dy - checkSize/2);
      
      canvas.drawPath(checkPath, checkPaint);
    } else {
      // Draw an arrow for sliding
      final Paint arrowPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final double arrowSize = enabledThumbRadius * 0.7;
      final Path arrowPath = Path();
      arrowPath.moveTo(center.dx - arrowSize / 2, center.dy);
      arrowPath.lineTo(center.dx + arrowSize / 2, center.dy);
      arrowPath.moveTo(center.dx + arrowSize / 3, center.dy - arrowSize / 3);
      arrowPath.lineTo(center.dx + arrowSize / 2, center.dy);
      arrowPath.lineTo(center.dx + arrowSize / 3, center.dy + arrowSize / 3);

      canvas.drawPath(arrowPath, arrowPaint);
    }
  }
}
