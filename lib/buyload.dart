import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class BuyLoadPage extends StatefulWidget {
  @override
  _BuyLoadPageState createState() => _BuyLoadPageState();
}

class _BuyLoadPageState extends State<BuyLoadPage> {
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _customAmountController = TextEditingController();
  String? selectedNetwork;
  int currentStep = 0;
  String? selectedAmount;
  String? _numberErrorText;
  bool _showConfirmationSlider = false; // New variable to control slider visibility
  double _sliderValue = 0.0; // New variable to track slider position
  bool _showReceipt = false;
  String _transactionId = "";
  DateTime _transactionDateTime = DateTime.now();

  // Philippine mobile number validation
  bool _isValidPhilippineNumber(String? number) {
    if (number == null || number.isEmpty) return false;

    // Remove any spaces, dashes, or parentheses
    String cleanNumber = number.replaceAll(RegExp(r'[\s\-()]'), '');

    // Check for +63 format or local format (starts with 09)
    bool isValidFormat = RegExp(r'^(\+63|0)9\d{9}$').hasMatch(cleanNumber);

    return isValidFormat;
  }

  // Method to show the confirmation slider
  void _showSlideToConfirm() {
    setState(() {
      _showConfirmationSlider = true;
      _sliderValue = 0.0; // Reset slider value when showing
    });
  }

  // Helper method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Helper method to show success snackbar
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Execute load transaction
  void _executeLoadTransaction() {
    // Reset slider
    setState(() {
      _sliderValue = 0.0;
      _showConfirmationSlider = false;
    });
    
    // Generate transaction ID (simple implementation)
    _transactionId = "LD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";
    _transactionDateTime = DateTime.now();
    
    // Show receipt instead of just a success message
    setState(() {
      _showReceipt = true;
    });
    
    // You would replace this with actual SMS sending code
    // _sendLoadSMS();
  }

  // Method to close receipt and navigate back to main page
  void _closeReceiptAndReturn() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1922),
      appBar: AppBar(
        backgroundColor: Color(0xFF0A1922),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFC1FD52)),
          onPressed: () {
            if (_showReceipt) {
              setState(() {
                _showReceipt = false;
              });
            } else if (_showConfirmationSlider) {
              setState(() {
                _showConfirmationSlider = false;
              });
            } else if (currentStep > 0) {
              setState(() {
                currentStep--;
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'LOAD',
          style: TextStyle(
            color: Color(0xFFC1FD52),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: _showReceipt ? _buildReceipt() : _buildCurrentStep(),
              ),
            ),
            // Show slider confirmation when needed
            if (_showConfirmationSlider) _buildSlideToConfirm(),
          ],
        ),
      ),
      floatingActionButton: _buildActionButton(),
    );
  }

  Widget? _buildActionButton() {
    if (_showReceipt) {
      return null; // No FAB when showing receipt
    } else if (currentStep == 1 && !_showConfirmationSlider) {
      return FloatingActionButton.extended(
        onPressed: _showSlideToConfirm,
        backgroundColor: Color(0xFFC1FD52),
        label: Text(
          'Send Load',
          style: TextStyle(color: Colors.black),
        ),
        icon: Icon(Icons.send, color: Colors.black),
      );
    }
    return null;
  }

  // New method to build the receipt
  Widget _buildReceipt() {
    // Format transaction amount
    String amountText = selectedAmount ?? "₱${_customAmountController.text}";
    if (amountText.isEmpty || (!amountText.startsWith("₱") && selectedAmount == null)) {
      amountText = "₱${_customAmountController.text}";
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF0F2633),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Color(0xFFC1FD52), width: 2),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFFC1FD52),
                size: 60,
              ),
              SizedBox(height: 10),
              Text(
                "Transaction Complete!",
                style: TextStyle(
                  color: Color(0xFFC1FD52),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30),
              _receiptInfoRow("Transaction ID", _transactionId),
              _receiptInfoRow("Date & Time", 
                "${_transactionDateTime.day}/${_transactionDateTime.month}/${_transactionDateTime.year} ${_transactionDateTime.hour}:${_transactionDateTime.minute.toString().padLeft(2, '0')}"),
              _receiptInfoRow("Network", selectedNetwork ?? ""),
              _receiptInfoRow("Mobile Number", _mobileNumberController.text),
              _receiptInfoRow("Amount", amountText),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF0A1922),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Status",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Color(0xFFC1FD52).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        "SUCCESS",
                        style: TextStyle(
                          color: Color(0xFFC1FD52),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.save_alt, color: Colors.black),
                label: Text("Save Receipt"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC1FD52),
                  foregroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Placeholder for save functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Receipt saved"), backgroundColor: Colors.green)
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 15),
        ElevatedButton(
          child: Text("Done"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0F2633),
            foregroundColor: Color(0xFFC1FD52),
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Color(0xFFC1FD52)),
            ),
          ),
          onPressed: _closeReceiptAndReturn,
        ),
      ],
    );
  }

  // Helper method for receipt info rows
  Widget _receiptInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildNetworkSelectionStep();
      case 1:
        return _buildAmountSelectionStep();
      default:
        return Container();
    }
  }

  Widget _buildNetworkSelectionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 15),
        TextField(
          controller: _mobileNumberController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Mobile No. (e.g., 09171234567 or +639171234567)',
            hintStyle: TextStyle(color: Color(0xFFFFD700)),
            errorText: _numberErrorText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Color(0xFFC1FD52)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(color: Color(0xFFC1FD52)),
            ),
            filled: true,
            fillColor: Color(0xFF0A1922),
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+]')),
          ],
          onChanged: (value) {
            setState(() {
              // Validate number on each change
              if (_isValidPhilippineNumber(value)) {
                _numberErrorText = null;
              } else {
                _numberErrorText = 'Invalid Philippine mobile number';
              }
            });
          },
        ),
        SizedBox(height: 30),
        Text(
          'Choose Network',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 15),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.2,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _networkButton('SMART', 'assets/smart_logo.png', Color(0xFFC1FD52)),
            _networkButton('TNT', 'assets/tnt_logo.png', Color(0xFFC1FD52)),
            _networkButton('GLOBE', 'assets/globe_logo.png', Color(0xFFC1FD52)),
            _networkButton('DITO', 'assets/dito_logo.png', Color(0xFFC1FD52)),
            _networkButton('TM', 'assets/tm_logo.png', Color(0xFFC1FD52)),
            _networkButton('CHERRY\nPREPAID', 'assets/cherry_logo.png', Color(0xFFC1FD52)),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSelectionStep() {
    // Proceed to amount selection only if number is valid
    if (!_isValidPhilippineNumber(_mobileNumberController.text)) {
      // If somehow reached without valid number, go back
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          currentStep = 0;
        });
      });
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Color(0xFFC1FD52)),
                ),
                child: Text(
                  _mobileNumberController.text.isNotEmpty ? _mobileNumberController.text : 'No number entered',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(width: 10),
            Container(
              width: 80,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFFC1FD52),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      selectedNetwork ?? 'Network',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Text(
          'Choose Amount',
          style: TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 16,
          ),
        ),
        SizedBox(height: 15),
        Container(
          margin: EdgeInsets.only(bottom: 15),
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Color(0xFFC1FD52)),
          ),
          child: TextField(
            controller: _customAmountController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Custom Amount',
              hintStyle: TextStyle(color: Colors.white38),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
          physics: NeverScrollableScrollPhysics(),
          children: [
            _amountButton('₱10'),
            _amountButton('₱15'),
            _amountButton('₱20'),
            _amountButton('₱30'),
            _amountButton('₱40'),
            _amountButton('₱50'),
            _amountButton('₱100'),
            _amountButton('₱150'),
            _amountButton('₱200'),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget _networkButton(String network, String imagePath, Color bgColor, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () {
        // Only proceed if mobile number is valid
        if (_isValidPhilippineNumber(_mobileNumberController.text)) {
          setState(() {
            selectedNetwork = network;
            currentStep = 1; // Go directly to amount selection step
          });
        } else {
          // Show an error or prevent network selection
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter a valid Philippine mobile number first'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
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

  Widget _amountButton(String amount) {
    bool isSelected = selectedAmount == amount;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAmount = amount;
          // Clear custom amount if a preset amount is selected
          _customAmountController.clear();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFF54291) : Color(0xFFC1FD52),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            amount,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }

  // New method to build the slide-to-confirm widget
  Widget _buildSlideToConfirm() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
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
                  value: _sliderValue,
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                    
                    // When slider reaches the end, process transaction
                    if (value >= 0.99) {
                      _executeLoadTransaction();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mobileNumberController.dispose();
    _customAmountController.dispose();
    super.dispose();
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

