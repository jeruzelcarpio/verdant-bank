import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

int expiryMinutes = 5; // Default expiry time for OTP

String generateOtp([int length = 6]) {
  final rand = Random();
  return List.generate(length, (_) => rand.nextInt(10)).join();
}

Future<String> sendOtpToEmail(String email, String otp) async {
  await FirebaseFirestore.instance.collection('otp').doc(email).set({
    'otp': otp,
    'createdAt': FieldValue.serverTimestamp(),
  });
  return otp;
}

Future<bool> verifyOtp(String email, String inputOtp, expiryMinutes) async {
  final doc = await FirebaseFirestore.instance.collection('otp').doc(email).get();
  if (!doc.exists) return false;

  final data = doc.data()!;
  final storedOtp = data['otp'];
  final Timestamp createdAt = data['createdAt'];
  final now = DateTime.now();
  final created = createdAt.toDate();

  if (storedOtp != inputOtp) return false;
  if (now.difference(created).inMinutes > expiryMinutes) return false;

  // Optionally, delete OTP after successful verification
  await FirebaseFirestore.instance.collection('otp').doc(email).delete();

  return true;
}