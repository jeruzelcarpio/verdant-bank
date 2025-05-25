import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// Change this import - AccountLoader is in main.dart
import 'package:verdantbank/main.dart';

class UserSession {
  static final UserSession _instance = UserSession._internal();
  
  factory UserSession() {
    return _instance;
  }
  
  UserSession._internal();
  
  // Store user email in SharedPreferences
  Future<void> saveUserEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email);
    await prefs.setBool('is_logged_in', true);
  }
  
  // Get user email from SharedPreferences
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email');
  }
  
  // Check if the user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }
  
  // Combined logout method with all functionality
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Sign out from Firebase Auth if needed
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  // Clear specific user data
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    await prefs.remove('is_logged_in');
    // Remove any other user-related data you might be storing
  }
}

// Add this where your logout button is handled
void handleLogout(BuildContext context) async {
  await UserSession().logout();
  
  // Remove the 'const' keyword here
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => AccountLoader()),
    (route) => false,
  );
}