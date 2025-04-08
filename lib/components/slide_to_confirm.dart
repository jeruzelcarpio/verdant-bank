import 'package:flutter/material.dart';

class SlideToConfirm extends StatefulWidget {
  final double sliderValue;
  final ValueChanged<double> onChanged;

  const SlideToConfirm({
    Key? key,
    required this.sliderValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  _SlideToConfirmState createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  late double _internalValue;

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
    });
    widget.onChanged(value);
  }

  void _handleSliderEnd(double value) {
    if (value < 0.95) {
      setState(() {
        _internalValue = 0.0;
      });
      widget.onChanged(0.0);
    }
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
            'Slide to confirm',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              color: Color(0xFF0A1922),
            ),
            child: SliderTheme(
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// Custom thumb shape for the slider
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

    final Paint fillPaint = Paint()
      ..color = sliderTheme.thumbColor!
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw the thumb circle
    canvas.drawCircle(center, enabledThumbRadius, fillPaint);
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);

    // Draw an arrow inside the thumb
    final Paint arrowPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

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
