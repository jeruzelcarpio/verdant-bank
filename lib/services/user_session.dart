import 'package:flutter/foundation.dart';

class UserSession {
  static String? _loggedInUserEmail;
  
  static String? get loggedInUserEmail => _loggedInUserEmail;
  
  static void login(String email) {
    _loggedInUserEmail = email;
  }
  
  static void logout() {
    _loggedInUserEmail = null;
  }
}