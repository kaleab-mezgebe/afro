import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern error state widget with user-friendly messages
class ModernErrorState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final VoidCallback? onRetry;
  final IconData? icon;

  const ModernErrorState({
    super.key,
    required this.message,
    this.subMessage,
    this.onRetry,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.error_outline,
                size: 44,
                color: AppTheme.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTheme.heading3.copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Try Again'),
                style: AppTheme.primaryButton,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern empty state widget with user-friendly messages
class ModernEmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData? icon;
  final Widget? action;

  const ModernEmptyState({
    super.key,
    required this.message,
    this.subMessage,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.inbox_outlined,
                size: 44,
                color: AppTheme.grey400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: AppTheme.heading3.copyWith(
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern success message widget
class ModernSuccessMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const ModernSuccessMessage({
    super.key,
    required this.message,
    this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.success,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle_rounded,
            color: AppTheme.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 20),
              color: AppTheme.success,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}

/// Modern warning message widget
class ModernWarningMessage extends StatelessWidget {
  final String message;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const ModernWarningMessage({
    super.key,
    required this.message,
    this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warning,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.warning_rounded,
            color: AppTheme.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close, size: 20),
              color: AppTheme.warning,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
