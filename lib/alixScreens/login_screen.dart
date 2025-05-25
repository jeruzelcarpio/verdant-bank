import 'package:flutter/material.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:verdantbank/main.dart'; // To access global variable
import 'package:cloud_firestore/cloud_firestore.dart'; // Add Firestore
import 'dart:convert';
import 'package:crypto/crypto.dart'; // For password hashing
import 'package:shared_preferences/shared_preferences.dart'; // For storing login session
import 'package:verdantbank/services/user_session.dart'; // Add this import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isBiometricEnabled = false;
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  // Hash the password using the same method as registration
  String _secureHash(String password) {
    final bytes = utf8.encode(password + "verdant_salt_123");
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Method to authenticate user
  Future<void> _login() async {
    // Reset error message
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;
      
      // Validate inputs
      if (email.isEmpty) {
        _setErrorMessage('Please enter your email');
        return;
      }
      
      if (password.isEmpty) {
        _setErrorMessage('Please enter your password');
        return;
      }

      // Check if user exists in Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(email)
          .get();

      if (!userDoc.exists) {
        _setErrorMessage('No account found with this email');
        return;
      }

      // Get the stored hashed password
      final userData = userDoc.data();
      final securityData = userData?['security'];
      
      if (securityData == null) {
        _setErrorMessage('Account setup incomplete. Please register again.');
        return;
      }
      
      final storedPassword = securityData['password'];
      
      // Hash the entered password and compare
      final hashedEnteredPassword = _secureHash(password);
      
      if (storedPassword != hashedEnteredPassword) {
        _setErrorMessage('Incorrect password');
        return;
      }

      // If we get here, login is successful
      
      // Save user info to shared preferences for session management
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString('user_first_name', userData?['firstName'] ?? '');
      await prefs.setString('user_last_name', userData?['lastName'] ?? '');
      
      // Save biometric preference if selected
      if (_isBiometricEnabled) {
        await prefs.setBool('biometric_enabled', true);
      }

      // Use the UserSession class:
      await UserSession().saveUserEmail(email);
      
      // Replace this navigation code:
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   '/home',
      //   (route) => false,
      // );
      
      // With this to force a complete app rebuild:
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AccountLoader()),
          (route) => false,
        );
      }
    } catch (e) {
      _setErrorMessage('Authentication failed: ${e.toString()}');
      print('Login error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 150),
              Center(
                child: Image.asset(
                  'assets/logo_horizontal.png',
                  height: 60,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: AppColors.lighterGreen),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white.withOpacity(0.8)),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: AppColors.lighterGreen),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.white.withOpacity(0.8)),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              
              // Display error message if there is one
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Handle forgot password
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
              CheckboxListTile(
                value: _isBiometricEnabled,
                onChanged: (value) {
                  setState(() {
                    _isBiometricEnabled = value ?? false;
                  });
                },
                title: Text(
                  'Enable Biometric Login to quickly and securely access the app using your fingerprint or face ID next time you open it.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                checkColor: AppColors.darkGreen,
                activeColor: AppColors.lighterGreen,
                side: BorderSide(color: Colors.white.withOpacity(0.4)),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lighterGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: _isLoading ? null : _login,
                child: _isLoading 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.darkGreen,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Log In',
                      style: TextStyle(fontSize: 16),
                    ),
              ),
              const SizedBox(height: 24),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: "Don't have an account? ",
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    children: [
                      TextSpan(
                        text: 'Create an account',
                        style: const TextStyle(
                          color: AppColors.lighterGreen,
                          decoration: TextDecoration.underline,
                        ),
                        mouseCursor: SystemMouseCursors.click,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushNamed(context, '/register');
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}