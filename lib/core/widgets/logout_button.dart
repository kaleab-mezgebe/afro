import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../theme/afro_theme.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
    this.text = 'Logout',
    this.icon = Icons.logout,
    this.backgroundColor,
    this.textColor,
  });

  final String text;
  final IconData icon;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: backgroundColor ?? AfroTheme.errorColor,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _showLogoutDialog,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor ?? AfroTheme.errorColor, size: 20),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? AfroTheme.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AfroTheme.primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (AuthController.isInitialized) {
                AuthController.to.logout();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Authentication system not available'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AfroTheme.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
