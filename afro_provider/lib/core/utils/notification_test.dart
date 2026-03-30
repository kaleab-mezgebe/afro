import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationTestPage extends StatelessWidget {
  const NotificationTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Test'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Test Different Notification Types',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            ElevatedButton(
              onPressed: () => NotificationService.showSuccess(
                'Operation completed successfully!',
                title: 'Success',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Success Notification'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () => NotificationService.showError(
                'Something went wrong. Please try again.',
                title: 'Error',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Error Notification'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () => NotificationService.showWarning(
                'Please be careful with this action.',
                title: 'Warning',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Warning Notification'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () => NotificationService.showInfo(
                'Here is some useful information.',
                title: 'Info',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Show Info Notification'),
            ),
            
            const SizedBox(height: 20),
            
            const Text(
              'API Error Examples',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () => NotificationService.showError(
                'No internet connection. Please check your network and try again.',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Network Error'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () => NotificationService.showWarning(
                'Session expired. Please login again.',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Auth Error'),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: () => NotificationService.showError(
                'Server error. Please try again later.',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Server Error'),
            ),
          ],
        ),
      ),
    );
  }
}
