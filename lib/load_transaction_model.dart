import 'package:cloud_firestore/cloud_firestore.dart';

class LoadTransaction {
  final String id;
  final String userId;
  final String mobileNumber;
  final String network;
  final double amount;
  final String transactionId;
  final DateTime timestamp;
  final String sourceAccount;
  final String status;
  final DateTime createdAt;

  LoadTransaction({
    required this.id,
    required this.userId,
    required this.mobileNumber,
    required this.network,
    required this.amount,
    required this.transactionId,
    required this.timestamp,
    required this.sourceAccount,
    required this.status,
    required this.createdAt,
  });

  // Create from Firestore document
  factory LoadTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return LoadTransaction(
      id: doc.id,
      userId: data['userId'] ?? '',
      mobileNumber: data['mobileNumber'] ?? '',
      network: data['network'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      transactionId: data['transactionId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      sourceAccount: data['sourceAccount'] ?? '',
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'mobileNumber': mobileNumber,
      'network': network,
      'amount': amount,
      'transactionId': transactionId,
      'timestamp': Timestamp.fromDate(timestamp),
      'sourceAccount': sourceAccount,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Create a copy with updated fields
  LoadTransaction copyWith({
    String? id,
    String? userId,
    String? mobileNumber,
    String? network,
    double? amount,
    String? transactionId,
    DateTime? timestamp,
    String? sourceAccount,
    String? status,
    DateTime? createdAt,
  }) {
    return LoadTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      network: network ?? this.network,
      amount: amount ?? this.amount,
      transactionId: transactionId ?? this.transactionId,
      timestamp: timestamp ?? this.timestamp,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}