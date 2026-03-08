import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_theme.dart';

class ProviderProfilePage extends ConsumerWidget {
  const ProviderProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryGreen,
      ),
      body: const Center(
        child: Text('Provider Profile Page - Coming Soon'),
      ),
    );
  }
}
