import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_theme.dart';

class ServiceManagementPage extends ConsumerWidget {
  const ServiceManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: const Center(
        child: Text('Service Management Page - Coming Soon'),
      ),
    );
  }
}
