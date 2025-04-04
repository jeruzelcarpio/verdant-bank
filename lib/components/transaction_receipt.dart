import 'package:flutter/material.dart';

class TransactionReceipt extends StatelessWidget {
  final String transactionId;
  final DateTime transactionDateTime;
  final String? selectedNetwork;
  final String mobileNumber;
  final String amountText;
  final VoidCallback onSave;
  final VoidCallback onDone;

  const TransactionReceipt({
    Key? key,
    required this.transactionId,
    required this.transactionDateTime,
    required this.selectedNetwork,
    required this.mobileNumber,
    required this.amountText,
    required this.onSave,
    required this.onDone,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              _receiptInfoRow("Transaction ID", transactionId),
              _receiptInfoRow("Date & Time", 
                "${transactionDateTime.day}/${transactionDateTime.month}/${transactionDateTime.year} ${transactionDateTime.hour}:${transactionDateTime.minute.toString().padLeft(2, '0')}"),
              _receiptInfoRow("Network", selectedNetwork ?? ""),
              _receiptInfoRow("Mobile Number", mobileNumber),
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
                onPressed: onSave,
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
          onPressed: onDone,
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
}
