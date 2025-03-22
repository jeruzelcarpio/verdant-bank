import 'package:flutter/material.dart';

class InvestPage extends StatefulWidget {
  @override
  _InvestPageState createState() => _InvestPageState();
}

class _InvestPageState extends State<InvestPage> {
  // Your buy load page state and logic goes here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invest'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your buy load UI elements go here
            Text('Invest Page'),
          ],
        ),
      ),
    );
  }
}