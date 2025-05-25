import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'invest_stocks_market.dart';
import 'package:google_fonts/google_fonts.dart';

class InvestStocksPage extends StatelessWidget {
  const InvestStocksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF032B24),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Clickable back button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 48), // spacer to balance layout
                ],
              ),
              const SizedBox(height: 12),

              // Right-aligned greeting
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, Jeff!",
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      color: Colors.lightGreenAccent.shade100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Invest your money with small risk",
                    style: GoogleFonts.poppins(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF001F1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "PHP 200.00",
                      style: GoogleFonts.poppins(color: Colors.orangeAccent, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "+PHP 0.00 (+0.00%)",
                      style: GoogleFonts.poppins(color: Colors.greenAccent),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 100,
                      child: LineChart(
                        LineChartData(
                          borderData: FlBorderData(show: false),
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 1),
                                FlSpot(1, 1.5),
                                FlSpot(2, 1.2),
                                FlSpot(3, 1.3),
                                FlSpot(4, 3),
                                FlSpot(5, 2),
                                FlSpot(6, 2.2),
                              ],
                              isCurved: true,
                              color: Colors.greenAccent,
                              belowBarData: BarAreaData(show: false),
                              dotData: FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ["1D", "1W", "1M", "3M", "1Y", "ALL"]
                          .map((label) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: label == "1D" ? Colors.green : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          label,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _returnBox("Today's Return", "PHP 50.00"),
                  const SizedBox(width: 10),
                  _returnBox("Total Return", "PHP 150.00"),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                "Markets Are Up Today",
                style: GoogleFonts.poppins(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StockMarketPage()));
                },
                child: _marketBox("Top Companies", "+0.03%", "S&P 500", "PHP 5,360.13", false),
              ),
              const SizedBox(height: 10),
              _marketBox("Technology", "-7.03%", "Google. Inc", "PHP 5,360.13", true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _returnBox(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFB6F79C),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: GoogleFonts.poppins(fontSize: 12)),
            Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _marketBox(String title, String percent, String company, String price, bool isNegative) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFB6F79C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              Text(
                percent,
                style: GoogleFonts.poppins(color: isNegative ? Colors.red : Colors.green),
              ),
            ],
          ),
          Text(company, style: GoogleFonts.poppins(fontSize: 12)),
          Text(price, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }
}
