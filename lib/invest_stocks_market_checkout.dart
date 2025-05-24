import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StockMarketCheckoutPage extends StatelessWidget {
  final String name;
  final String symbol;
  final String price;
  final String change;
  final String logoUrl;
  final bool isUp;

  const StockMarketCheckoutPage({
    super.key,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change,
    required this.logoUrl,
    required this.isUp,
  });

  List<FlSpot> generateRandomChartData() {
    final random = Random();
    List<FlSpot> spots = [];
    double value = 50 + random.nextDouble() * 50;
    for (int i = 0; i < 20; i++) {
      value += random.nextDouble() * 4 - 2;
      spots.add(FlSpot(i.toDouble(), value));
    }
    return spots;
  }

  String getRandomChange() {
    final random = Random();
    final percent = (random.nextDouble() * 2 - 1) * 5;
    final parsedPrice =
        double.tryParse(price.replaceAll(RegExp(r'[^\d.]'), '').replaceAll(',', '.')) ?? 1;
    final changeAmount = (parsedPrice * percent / 100).toStringAsFixed(2);
    return "${percent > 0 ? '+' : ''}PHP $changeAmount (${percent.toStringAsFixed(2)}%)";
  }

  @override
  Widget build(BuildContext context) {
    final chartData = generateRandomChartData();
    final fluctuation = getRandomChange();

    return Scaffold(
      backgroundColor: const Color(0xFF002019),
      body: CustomScrollView(
        slivers: [
          // Sticky Header
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: Container(
                color: const Color(0xFF002019),
                margin: const EdgeInsets.only(top: 30), // increased from 8 to 16
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.lightGreenAccent),
                      onPressed: () => Navigator.pop(context),
                    ),
                    CircleAvatar(
                      backgroundImage: NetworkImage(logoUrl),
                      backgroundColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(symbol, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(price,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text(
                          change,
                          style: TextStyle(
                              color: isUp ? Colors.greenAccent : Colors.red, fontSize: 12),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              maxHeight: 96,
              minHeight: 96,
            ),
          ),

          // Main content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Chart
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF012C22),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(price,
                          style: const TextStyle(
                              fontSize: 28, color: Colors.amber, fontWeight: FontWeight.bold)),
                      Text(fluctuation,
                          style: const TextStyle(color: Colors.lightGreenAccent, fontSize: 14)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 120,
                        child: LineChart(LineChartData(
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              spots: chartData,
                              color: Colors.greenAccent,
                              barWidth: 2,
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        )),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Text("1D", style: TextStyle(color: Colors.greenAccent)),
                          Text("1W", style: TextStyle(color: Colors.white70)),
                          Text("1M", style: TextStyle(color: Colors.white70)),
                          Text("3M", style: TextStyle(color: Colors.white70)),
                          Text("1Y", style: TextStyle(color: Colors.white70)),
                          Text("ALL", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Overview
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3F584),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text("OVERVIEW",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          Spacer(),
                          Text("View All",
                              style: TextStyle(decoration: TextDecoration.underline)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 12,
                        childAspectRatio: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          _OverviewItem(label: "52 Week High", value: "PHP 294,34"),
                          _OverviewItem(label: "52 Week Low", value: "PHP 224,34"),
                          _OverviewItem(label: "EPS (Annual)", value: "PHP 24.32"),
                          _OverviewItem(label: "PE Ratio", value: "18.4"),
                          _OverviewItem(label: "EBITDA", value: "PHP 12.6B"),
                          _OverviewItem(label: "Profit", value: "PHP 345.4M"),
                          _OverviewItem(label: "Market Cap", value: "PHP 294.3B"),
                          _OverviewItem(label: "Avg Volume", value: "335K"),
                          _OverviewItem(label: "Exchange", value: "NYSE"),
                          _OverviewItem(label: "Dividend", value: "-"),
                        ],
                      )
                    ],
                  ),
                ),

                // Buy Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB3F584),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        print("Buying $name");
                      },
                      child: const Text("Buy",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Sticky Header Delegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    required this.minHeight,
    required this.maxHeight,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}

// Overview Item Widget
class _OverviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
