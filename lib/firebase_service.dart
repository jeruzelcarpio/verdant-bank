import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  // Collection reference for load transactions
  static CollectionReference loadTransactions() {
    return _firestore.collection('loadTransactions');
  }

  // Save load transaction to Firestore
  static Future<String> saveLoadTransaction({
    required String userId,
    required String mobileNumber,
    required String network,
    required double amount,
    required String transactionId,
    required DateTime timestamp,
    required String sourceAccount,
  }) async {
    try {
      await loadTransactions().doc(transactionId).set({
        'userId': userId,
        'mobileNumber': mobileNumber,
        'network': network,
        'amount': amount,
        'transactionId': transactionId,
        'timestamp': timestamp,
        'sourceAccount': sourceAccount,
        'status': 'completed',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return transactionId;
    } catch (e) {
      print('Error saving load transaction: $e');
      throw e;
    }
  }

  // Get user's load transaction history
  static Future<List<Map<String, dynamic>>> getUserLoadTransactions(String userId) async {
    try {
      QuerySnapshot querySnapshot = await loadTransactions()
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print('Error getting load transactions: $e');
      return [];
    }
  }
}
