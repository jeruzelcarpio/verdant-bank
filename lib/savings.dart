// main.dart
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

void main() {
  runApp(const SavingsPage());
}

class SavingsPage extends StatelessWidget {
  const SavingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alkansya',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF002019),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFB8FF5C),
          secondary: const Color(0xFFB8FF5C),
        ),
      ),
      home: const AlkansyaScreen(),
    );
  }
}

class Plan {
  final String name;
  final double goalAmount;
  double currentAmount;
  bool isCollected;
  final List<FlSpot> savingsHistory;

  Plan({
    required this.name,
    required this.goalAmount,
    this.currentAmount = 0,
    this.isCollected = false,
    List<FlSpot>? savingsHistory,
  }) : savingsHistory = savingsHistory ?? [const FlSpot(0, 0)];
}
class AlkansyaScreen extends StatefulWidget {
  const AlkansyaScreen({super.key});

  @override
  State<AlkansyaScreen> createState() => _AlkansyaScreenState();
}

class _AlkansyaScreenState extends State<AlkansyaScreen> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final List<Plan> _plans = [];

  void _addNewPlan(String name, double goalAmount) {
    final upperName = name.toUpperCase();
    bool alreadyExists = _plans.any((plan) => plan.name == upperName);

    if (alreadyExists || goalAmount > 100000) {
      return; // Don't add invalid plans
    }

    setState(() {
      final newPlan = Plan(name: upperName, goalAmount: goalAmount);
      _plans.insert(0, newPlan);
      _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 400));
    });
  }

  void _confirmDeletePlan(int index) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFD73F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Are you sure you want to delete the selected savings?',
            style: TextStyle(color: Color(0xFF004D3C), fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _plans.removeAt(index);
                  _listKey.currentState?.removeItem(
                    index,
                        (context, animation) => SizeTransition(
                      sizeFactor: animation,
                      child: Container(),
                    ),
                    duration: const Duration(milliseconds: 300),
                  );
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004D3C),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('Yes'),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB8FF5C),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: const Text('No'),
            ),
          ],
        );
      },
    );
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFD73F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'WARNING!',
            style: TextStyle(
              color: Color(0xFF004D3C),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
          content: const Text(
            'CANNOT BE DELETED DUE TO ONE OF THE SAVING SELECTED HAS MONEY INSIDE',
            style: TextStyle(
              color: Color(0xFF004D3C),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  void _deletePlan(int index) {
    final plan = _plans[index];
    if (plan.currentAmount > 0) {
      _showWarningDialog();
    } else {
      _confirmDeletePlan(index);
    }
  }
  void _openPlanDetails(Plan plan, int index) {
    final TextEditingController amountController = TextEditingController();
    String? errorText;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF002019),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return Padding(
          padding: MediaQuery.of(ctx).viewInsets.add(const EdgeInsets.all(20)),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              double percent = (plan.currentAmount / plan.goalAmount).clamp(0, 1);
              bool goalReached = plan.currentAmount >= plan.goalAmount;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current plan', style: TextStyle(color: Colors.white)),
                          Text('${plan.name} ${(percent * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(fontSize: 18, color: Colors.white)),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _deletePlan(index);
                        },
                        icon: const Icon(Icons.delete_outline, color: Color(0xFFE5F0C0)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: plan.savingsHistory,
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.greenAccent,
                            belowBarData: BarAreaData(show: false),
                          )
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 60,
                              interval: _getYAxisInterval(plan),
                              getTitlesWidget: (value, meta) {
                                return Text('₱${value.toInt()}',
                                    style: const TextStyle(color: Colors.white, fontSize: 12));
                              },
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _getYAxisInterval(plan),
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.white,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plan.currentAmount == 0
                        ? 'This Savings is Empty!'
                        : 'You have saved: PHP ${plan.currentAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text('Today is ${DateTime.now().toLocal().toString().split(" ")[0]}',
                      style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 16),
                  if (goalReached)
                    const Text('Congratulations! You achieved it!',
                        style: TextStyle(color: Color(0xFFB8FF5C), fontWeight: FontWeight.bold))
                  else
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Enter amount to save',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF00392D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorText: errorText,
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: goalReached
                        ? () {
                      setState(() => plan.isCollected = true);
                      Navigator.of(ctx).pop();
                    }
                        : () {
                      final input = amountController.text;
                      final amount = double.tryParse(input);

                      if (input.isEmpty) {
                        setModalState(() => errorText = 'Please input desired amount.');
                      } else if (amount == null || amount <= 0) {
                        setModalState(() => errorText = 'Amount must be greater than zero.');
                      } else if ((plan.currentAmount + amount) > plan.goalAmount) {
                        setModalState(() =>
                        errorText = 'Goal amount limit is PHP 100,000.');
                      } else {
                        setState(() {
                          plan.currentAmount += amount;
                          plan.savingsHistory.add(FlSpot(
                            plan.savingsHistory.length.toDouble(),
                            plan.currentAmount,
                          ));
                        });
                        setModalState(() {
                          errorText = null;
                          amountController.clear();
                        });
                      }
                    },
                    child: Text(goalReached ? 'COLLECT SAVINGS' : 'SAVE NOW!'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  double _getYAxisInterval(Plan plan) {
    double maxY = plan.savingsHistory.map((e) => e.y).reduce(max);
    if (maxY <= 200) return 20;
    if (maxY <= 1000) return 100;
    if (maxY <= 5000) return 500;
    if (maxY <= 10000) return 1000;
    if (maxY <= 20000) return 2000;
    return 5000;
  }

  Widget _buildPlanTile(Plan plan, int index) {
    double percent = (plan.currentAmount / plan.goalAmount).clamp(0, 1);
    String initials = plan.name.split(" ").map((e) => e[0]).take(2).join().toUpperCase();

    return Opacity(
      opacity: plan.isCollected ? 0.4 : 1,
      child: IgnorePointer(
        ignoring: plan.isCollected,
        child: GestureDetector(
          onTap: () => _openPlanDetails(plan, index),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFB8FF5C),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF002019),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Color(0xFFB8FF5C),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'PHP ${plan.goalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF002019),
                      ),
                    ),
                  ],
                ),
                CircularPercentIndicator(
                  radius: 28,
                  lineWidth: 6,
                  percent: percent,
                  animation: true,
                  center: Text(
                    '${(percent * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.black),
                  ),
                  backgroundColor: const Color(0xFFE5F0C0),
                  progressColor: const Color(0xFF004D3C),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _openNewPlanDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        String name = '';
        String goal = '';
        String? nameError;
        String? goalError;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFF002019),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFFB8FF5C)),
              ),
              title: const Text('+ New plan', style: TextStyle(color: Color(0xFFB8FF5C))),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      hintStyle: const TextStyle(color: Color(0xFFB8FF5C)),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFB8FF5C)),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      errorText: nameError,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    onChanged: (val) {
                      setStateDialog(() {
                        name = val.toUpperCase();
                        nameError = null;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Goal amount',
                      hintStyle: const TextStyle(color: Color(0xFFB8FF5C)),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFB8FF5C)),
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      errorText: goalError,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    onChanged: (val) {
                      setStateDialog(() {
                        goal = val;
                        goalError = null;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8FF5C),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    final goalAmount = double.tryParse(goal);
                    bool nameExists = _plans.any((plan) => plan.name == name);

                    if (name.isEmpty) {
                      setStateDialog(() => nameError = 'Name cannot be empty.');
                    } else if (nameExists) {
                      setStateDialog(() => nameError = 'Please use another name.');
                    } else if (goalAmount == null || goalAmount <= 0) {
                      setStateDialog(() => goalError = 'Enter a valid goal amount.');
                    } else if (goalAmount > 100000) {
                      setStateDialog(() => goalError = 'The goal amount limit is P100000.');
                    } else {
                      _addNewPlan(name, goalAmount);
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
  void _showReminderDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF003319), // Dark green background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white24),
          ),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Center(
                child: Text(
                  'REMINDER',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFC107), // Yellow title
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                '1. Once an ‘Alkansya’ is created, it can only be deleted if and only if it has no money inside it.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                '2. After moving money into the ‘Alkansya’, the only way to retrieve the money is to reach its goal.',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              Text(
                '3. Think carefully before putting money inside the ‘Alkansya’ to avoid any mistakes.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back, color: Color(0xFFB8FF5C)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('ALKANSYA', style: TextStyle(color: Color(0xFFB8FF5C))),
        actions: [
          const Icon(Icons.receipt_long, color: Color(0xFFE5F0C0)),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Color(0xFFE5F0C0)),
            onPressed: _showReminderDialog,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: AnimatedList(
        key: _listKey,
        initialItemCount: _plans.length,
        itemBuilder: (context, index, animation) {
          return SlideTransition(
            position: animation.drive(
              Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOut)),
            ),
            child: _buildPlanTile(_plans[index], index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewPlanDialog,
        backgroundColor: const Color(0xFF00A868),
        child: const Icon(Icons.add),
      ),
    );
  }
}
