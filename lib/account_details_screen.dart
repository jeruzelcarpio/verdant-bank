import 'package:flutter/material.dart';
import 'package:verdantbank/models/account.dart';
import 'package:verdantbank/theme/colors.dart';
import 'package:verdantbank/services/user_session.dart';
import 'package:verdantbank/alixScreens/signIn_screen.dart';

class AccountDetailsScreen extends StatelessWidget {
  final Account userAccount;

  const AccountDetailsScreen({Key? key, required this.userAccount}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkGreen,
      appBar: AppBar(
        backgroundColor: AppColors.green,
        title: const Text(
          'Account Details',
          style: TextStyle(color: AppColors.milk),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.milk),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 30),
            _buildDetailsList(),
            const SizedBox(height: 40),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.lighterGreen,
            child: Text(
              '${userAccount.accFirstName[0]}${userAccount.accLastName[0]}',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.green,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            '${userAccount.accFirstName} ${userAccount.accLastName}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.milk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Full Name', '${userAccount.accFirstName} ${userAccount.accLastName}'),
          _buildDivider(),
          _buildDetailItem('Email', userAccount.accEmail),
          _buildDivider(),
          _buildDetailItem('Account Number', userAccount.accNumber),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.milk.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.milk,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.milk.withOpacity(0.2),
      thickness: 1,
      height: 20,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _handleLogout(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lighterGreen,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.green,
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final userSession = UserSession();
    await userSession.clearUser();
    
    // Navigate to login screen and clear navigation stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SignInScreen()),
      (route) => false,
    );
  }
}