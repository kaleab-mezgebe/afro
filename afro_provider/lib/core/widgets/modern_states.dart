import 'package:flutter/material.dart';
import '../utils/modern_theme.dart';
import 'modern_card.dart';
import 'modern_loading.dart';

class ModernEmptyState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsets? padding;

  const ModernEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
    this.iconSize,
    this.iconColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize ?? 48,
                  color: iconColor ?? context.textSecondary,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.5,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 16),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ModernErrorState extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? retryText;
  final EdgeInsets? padding;

  const ModernErrorState({
    super.key,
    required this.title,
    this.subtitle,
    this.onRetry,
    this.icon,
    this.retryText,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      margin: padding ?? const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? Icons.error_outline,
                size: 48,
                color: context.error,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                ),
              ],
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryText ?? 'Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primary,
                    foregroundColor: context.textPrimary,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ModernLoadingState extends StatelessWidget {
  final String? message;
  final bool showProgress;
  final double? progress;
  final EdgeInsets? padding;

  const ModernLoadingState({
    super.key,
    this.message,
    this.showProgress = false,
    this.progress,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress && progress != null)
                ModernProgressIndicator(
                  value: progress!,
                )
              else
                const ModernLoadingSpinner(),
              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                        fontSize: 14,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ModernNetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ModernNetworkErrorState({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ModernErrorState(
      title: 'No Internet Connection',
      subtitle: customMessage ??
          'Please check your internet connection and try again.',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: 'Retry',
    );
  }
}

class ModernServerErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ModernServerErrorState({
    super.key,
    this.onRetry,
    this.customMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ModernErrorState(
      title: 'Server Error',
      subtitle: customMessage ??
          'Something went wrong on our end. Please try again later.',
      icon: Icons.cloud_off,
      onRetry: onRetry,
      retryText: 'Try Again',
    );
  }
}

class ModernNoDataState extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const ModernNoDataState({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return ModernEmptyState(
      title: title ?? 'No Data Available',
      subtitle: subtitle ?? 'There\'s nothing to show here right now.',
      icon: icon ?? Icons.inbox_outlined,
      action: action,
    );
  }
}

class ModernPermissionDeniedState extends StatelessWidget {
  final VoidCallback? onRequestPermission;
  final String? permission;

  const ModernPermissionDeniedState({
    super.key,
    this.onRequestPermission,
    this.permission,
  });

  @override
  Widget build(BuildContext context) {
    return ModernErrorState(
      title: 'Permission Required',
      subtitle: permission != null
          ? 'This app needs ${permission!} permission to work properly.'
          : 'This app needs certain permissions to work properly.',
      icon: Icons.lock,
      onRetry: onRequestPermission,
      retryText: 'Grant Permission',
    );
  }
}

class ModernMaintenanceState extends StatelessWidget {
  final String? message;

  const ModernMaintenanceState({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ModernEmptyState(
      title: 'Under Maintenance',
      subtitle: message ??
          'We\'re currently making improvements. Please check back soon.',
      icon: Icons.build,
      iconColor: context.warning,
    );
  }
}

class ModernStateWrapper extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final bool isEmpty;
  final Widget? child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final String? errorMessage;
  final String? emptyMessage;
  final VoidCallback? onRetry;

  const ModernStateWrapper({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    this.child,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.errorMessage,
    this.emptyMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ?? const ModernLoadingState();
    }

    if (hasError) {
      return errorWidget ??
          ModernErrorState(
            title: 'Something went wrong',
            subtitle: errorMessage,
            onRetry: onRetry,
          );
    }

    if (isEmpty) {
      return emptyWidget ??
          ModernNoDataState(
            subtitle: emptyMessage,
          );
    }

    return child ?? const SizedBox.shrink();
  }
}

class ModernAnimatedState extends StatefulWidget {
  final bool isLoading;
  final bool hasError;
  final bool isEmpty;
  final Widget? child;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final Duration? duration;

  const ModernAnimatedState({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.isEmpty,
    this.child,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.duration,
  });

  @override
  State<ModernAnimatedState> createState() => _ModernAnimatedStateState();
}

class _ModernAnimatedStateState extends State<ModernAnimatedState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration ?? const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    if (widget.isLoading) {
      currentWidget = widget.loadingWidget ?? const ModernLoadingState();
    } else if (widget.hasError) {
      currentWidget = widget.errorWidget ??
          const ModernErrorState(
            title: 'Something went wrong',
          );
    } else if (widget.isEmpty) {
      currentWidget = widget.emptyWidget ?? const ModernNoDataState();
    } else {
      currentWidget = widget.child ?? const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: currentWidget,
        );
      },
    );
  }
}
