import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class Plan {
  String? id;
  final String name;
  final double goalAmount;
  double currentAmount;
  bool isCollected;
  List<Map<String, dynamic>> savingsHistoryData;
  final DateTime createdAt;
  
  // List for chart display - not stored directly in Firestore
  List<FlSpot> get savingsHistory {
    List<FlSpot> spots = [];
    for (var i = 0; i < savingsHistoryData.length; i++) {
      spots.add(FlSpot(
        savingsHistoryData[i]['x'].toDouble(),
        savingsHistoryData[i]['y'].toDouble(),
      ));
    }
    return spots;
  }

  Plan({
    this.id,
    required this.name,
    required this.goalAmount,
    this.currentAmount = 0,
    this.isCollected = false,
    List<FlSpot>? savingsHistory,
    DateTime? createdAt,
  }) : savingsHistoryData = savingsHistory != null 
            ? savingsHistory.map((spot) => {'x': spot.x, 'y': spot.y}).toList()
            : [{'x': 0, 'y': 0}],
       createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'goalAmount': goalAmount,
      'currentAmount': currentAmount,
      'isCollected': isCollected,
      'savingsHistoryData': savingsHistoryData,
      'createdAt': createdAt,
    };
  }

  // Create from Firestore document
  factory Plan.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    return Plan(
      id: doc.id,
      name: data['name'] ?? '',
      goalAmount: (data['goalAmount'] ?? 0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0).toDouble(),
      isCollected: data['isCollected'] ?? false,
      savingsHistory: (data['savingsHistoryData'] as List?)
          ?.map((item) => FlSpot(
                (item['x'] ?? 0).toDouble(),
                (item['y'] ?? 0).toDouble(),
              ))
          .toList() ?? [const FlSpot(0, 0)],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Add savings to history
  void addSaving(double amount) {
    currentAmount += amount;
    savingsHistoryData.add({
      'x': savingsHistoryData.length.toDouble(),
      'y': currentAmount,
    });
  }
}
