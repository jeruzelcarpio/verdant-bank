import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verdantbank/account.dart';

Future<Account?> fetchAccount(String accountNumber) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('accounts')
        .where('accNumber', isEqualTo: accountNumber)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      return Account(
        accFirstName: data['accFirstName'],
        accLastName: data['accLastName'],
        accNumber: data['accNumber'],
        accBalance: data['accBalance'],
        accPhoneNum: data['accPhoneNum'],
      );
    }
  } catch (e) {
    print('Error fetching account: $e');
  }
  return null;
}