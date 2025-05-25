import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verdantbank/models/account.dart';

Future<String?> fetchAccount(String accountEmail) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .where('accEmail', isEqualTo: accountEmail)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id; // Return the document ID
    }
  } catch (e) {
    print('Error fetching account: $e');
  }
  return null; // Return null if no account is found or an error occurs
}