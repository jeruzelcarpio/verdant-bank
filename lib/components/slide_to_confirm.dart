import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';

class SlideToConfirm extends StatefulWidget {
  final double sliderValue;
  final ValueChanged<double> onChanged;
  final VoidCallback? onConfirm;
  final Map<String, String> info;


  const SlideToConfirm({
    Key? key,
    required this.sliderValue,
    required this.onChanged,
    this.onConfirm,
    required this.info,
  }) : super(key: key);

  @override
  _SlideToConfirmState createState() => _SlideToConfirmState();
}

class _SlideToConfirmState extends State<SlideToConfirm> {
  late double _internalValue;
  bool _isSliding = false;
  ui.Image? _arrowImage;
  ui.Image? _checkImage;


  @override
  void initState() {
    super.initState();
    _internalValue = widget.sliderValue;
    _loadImages();
  }

  Future<void> _loadImages() async {
    final arrow = await _loadAssetImage('assets/arrow_slide.png');
    final check = await _loadAssetImage('assets/check_slide.png');
    setState(() {
      _arrowImage = arrow;
      _checkImage = check;
    });
  }

  Future<ui.Image> _loadAssetImage(String asset) async {
    final data = await DefaultAssetBundle.of(context).load(asset);
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    return frame.image;
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
    final info = widget.info ?? {};
    final double trackWidth = MediaQuery.of(context).size.width * 0.92;
    final double thumbRadius = 32.0;
    final double progressWidth = (_internalValue * (trackWidth - thumbRadius)) + thumbRadius / 2;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 48),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
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
          SizedBox(height: 24),
          Text(
            _internalValue >= 0.95 ? 'CONFIRMED' : 'CONFIRMATION',
            style: TextStyle(
              color: AppColors.lighterGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 15),
          if (info.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ConfirmationInfo(info: info),
            ),
          Stack(
            alignment: Alignment.center,
            children: [
              // Track background
              Container(
                height: 78,
                width: trackWidth,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0x99999999),
                      Color(0xFF999999),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
              ),
              // Progress indicator
              // Slider hint text
              Positioned(
                right: 75,
                child: AnimatedOpacity(
                  opacity: _internalValue < 0.5 ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: Text(
                    "Swipe to Confirm ",
                    style: TextStyle(color: AppColors.milk, fontSize: 20, fontWeight: FontWeight.w600),
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
                  trackHeight: 31,
                  thumbShape: _CustomThumbShape(
                    arrowImage: _arrowImage,
                    checkImage: _checkImage,
                  ),
                ),
                child: Slider(
                  value: _internalValue,
                  onChanged: _arrowImage == null ? null : _handleSliderChange,
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
  final double enabledThumbRadius = 30.0;
  final ui.Image? arrowImage;
  final ui.Image? checkImage;

  _CustomThumbShape({this.arrowImage, this.checkImage});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(PaintingContext context,
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
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawCircle(center.translate(0, 4), enabledThumbRadius * 0.85, shadowPaint);

    canvas.drawCircle(center, enabledThumbRadius, fillPaint);
    canvas.drawCircle(center, enabledThumbRadius, borderPaint);

    final image = isCompleted ? checkImage : arrowImage;
    if (image != null) {
      final double imageSize = enabledThumbRadius * .65;
      final Rect dst = Rect.fromCenter(
        center: center,
        width: imageSize,
        height: imageSize,
      );
      canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        dst,
        Paint(),
      );
    }
  }
}

class ConfirmationInfo extends StatelessWidget {
  final Map<String, String> info;

  const ConfirmationInfo({Key? key, required this.info}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (info.isEmpty) {
      return SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(info.length, (index) {
          final entry = info.entries.elementAt(index);
          final bool isAmount = entry.key == 'TRANSFER AMOUNT';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.normal, color: AppColors.milk, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.milk,
                      fontSize: isAmount ? 20 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
