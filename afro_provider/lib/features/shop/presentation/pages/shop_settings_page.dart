import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/shop_settings_provider.dart';
import '../../../../core/utils/app_theme.dart';
import '../../../../core/models/provider_models.dart';

class ShopSettingsPage extends ConsumerStatefulWidget {
  const ShopSettingsPage({super.key});

  @override
  ConsumerState<ShopSettingsPage> createState() => _ShopSettingsPageState();
}

class _ShopSettingsPageState extends ConsumerState<ShopSettingsPage> {
  @override
  void initState() {
    super.initState();
    // Load settings for a default shop (in real app, this would be passed as parameter)
    Future.microtask(() => ref
        .read(shopSettingsProvider.notifier)
        .loadShopSettings('default_shop_id'));
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(shopSettingsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('SHOP SETTINGS'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: settingsState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow))
          : settingsState.error != null
              ? _buildErrorState(settingsState.error ?? 'Unknown error')
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // General Settings
                      _buildGeneralSettings(settingsState),
                      const SizedBox(height: 24),

                      // Working Hours
                      _buildWorkingHoursSection(settingsState),
                      const SizedBox(height: 24),

                      // Social Media Links
                      _buildSocialMediaSection(settingsState),
                      const SizedBox(height: 24),

                      // Payment Settings
                      _buildPaymentSettings(settingsState),
                      const SizedBox(height: 24),

                      // Notification Settings
                      _buildNotificationSettings(settingsState),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 80, color: Colors.red.withOpacity(0.3)),
          const SizedBox(height: 16),
          const Text(
            'Error Loading Settings',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.black),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: AppTheme.greyMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(shopSettingsProvider.notifier).clearError();
              ref
                  .read(shopSettingsProvider.notifier)
                  .loadShopSettings('default_shop_id');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('RETRY'),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings(ShopSettingsState settingsState) {
    final settings = settingsState.settings;
    if (settings == null) return const SizedBox.shrink();

    return _buildSettingsCard(
      title: 'General Settings',
      icon: Icons.settings,
      children: [
        _buildSwitchTile(
          title: 'Allow Online Booking',
          subtitle: 'Enable customers to book appointments online',
          value: settings.allowOnlineBooking,
          onChanged: (value) {
            final updatedSettings = ShopSettings(
              allowOnlineBooking: value,
              requireDeposit: settings.requireDeposit,
              depositAmount: settings.depositAmount,
              cancellationPolicy: settings.cancellationPolicy,
              advanceBookingDays: settings.advanceBookingDays,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateShopSettings(updatedSettings);
          },
        ),
        _buildSwitchTile(
          title: 'Require Deposit',
          subtitle: 'Require customers to pay a deposit for bookings',
          value: settings.requireDeposit,
          onChanged: (value) {
            final updatedSettings = ShopSettings(
              allowOnlineBooking: settings.allowOnlineBooking,
              requireDeposit: value,
              depositAmount: settings.depositAmount,
              cancellationPolicy: settings.cancellationPolicy,
              advanceBookingDays: settings.advanceBookingDays,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateShopSettings(updatedSettings);
          },
        ),
        _buildTextFieldTile(
          title: 'Deposit Amount',
          subtitle: 'Amount required for deposit',
          value: settings.depositAmount.toString(),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0.0;
            final updatedSettings = ShopSettings(
              allowOnlineBooking: settings.allowOnlineBooking,
              requireDeposit: settings.requireDeposit,
              depositAmount: amount,
              cancellationPolicy: settings.cancellationPolicy,
              advanceBookingDays: settings.advanceBookingDays,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateShopSettings(updatedSettings);
          },
          keyboardType: TextInputType.number,
        ),
        _buildTextFieldTile(
          title: 'Cancellation Policy',
          subtitle: 'Policy for appointment cancellations',
          value: settings.cancellationPolicy,
          onChanged: (value) {
            final updatedSettings = ShopSettings(
              allowOnlineBooking: settings.allowOnlineBooking,
              requireDeposit: settings.requireDeposit,
              depositAmount: settings.depositAmount,
              cancellationPolicy: value,
              advanceBookingDays: settings.advanceBookingDays,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateShopSettings(updatedSettings);
          },
          maxLines: 3,
        ),
        _buildTextFieldTile(
          title: 'Advance Booking Days',
          subtitle: 'Maximum days in advance customers can book',
          value: settings.advanceBookingDays.toString(),
          onChanged: (value) {
            final days = int.tryParse(value) ?? 30;
            final updatedSettings = ShopSettings(
              allowOnlineBooking: settings.allowOnlineBooking,
              requireDeposit: settings.requireDeposit,
              depositAmount: settings.depositAmount,
              cancellationPolicy: settings.cancellationPolicy,
              advanceBookingDays: days,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateShopSettings(updatedSettings);
          },
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildWorkingHoursSection(ShopSettingsState settingsState) {
    final workingHours = settingsState.workingHours;
    if (workingHours == null) return const SizedBox.shrink();

    return _buildSettingsCard(
      title: 'Working Hours',
      icon: Icons.access_time,
      action: TextButton.icon(
        onPressed: () => _showWorkingHoursDialog(context, workingHours),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
      children: [
        ...[
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ].map((day) {
          final daySchedule = _getDaySchedule(workingHours, day);
          return _buildWorkingHoursTile(day, daySchedule);
        }).toList(),
      ],
    );
  }

  Widget _buildSocialMediaSection(ShopSettingsState settingsState) {
    final socialMedia = settingsState.socialMediaLinks;
    if (socialMedia == null) return const SizedBox.shrink();

    return _buildSettingsCard(
      title: 'Social Media Links',
      icon: Icons.share,
      action: TextButton.icon(
        onPressed: () => _showSocialMediaDialog(context, socialMedia),
        icon: const Icon(Icons.edit),
        label: const Text('Edit'),
      ),
      children: [
        _buildTextFieldTile(
          title: 'Facebook',
          subtitle: 'Facebook page URL',
          value: socialMedia.facebook ?? '',
          onChanged: (value) {
            final updatedLinks = SocialMediaLinks(
              facebook: value.isEmpty ? null : value,
              instagram: socialMedia.instagram,
              twitter: socialMedia.twitter,
              youtube: socialMedia.youtube,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateSocialMediaLinks(updatedLinks);
          },
        ),
        _buildTextFieldTile(
          title: 'Instagram',
          subtitle: 'Instagram profile URL',
          value: socialMedia.instagram ?? '',
          onChanged: (value) {
            final updatedLinks = SocialMediaLinks(
              facebook: socialMedia.facebook,
              instagram: value.isEmpty ? null : value,
              twitter: socialMedia.twitter,
              youtube: socialMedia.youtube,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateSocialMediaLinks(updatedLinks);
          },
        ),
        _buildTextFieldTile(
          title: 'Twitter',
          subtitle: 'Twitter profile URL',
          value: socialMedia.twitter ?? '',
          onChanged: (value) {
            final updatedLinks = SocialMediaLinks(
              facebook: socialMedia.facebook,
              instagram: socialMedia.instagram,
              twitter: value.isEmpty ? null : value,
              youtube: socialMedia.youtube,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateSocialMediaLinks(updatedLinks);
          },
        ),
        _buildTextFieldTile(
          title: 'YouTube',
          subtitle: 'YouTube channel URL',
          value: socialMedia.youtube ?? '',
          onChanged: (value) {
            final updatedLinks = SocialMediaLinks(
              facebook: socialMedia.facebook,
              instagram: socialMedia.instagram,
              twitter: socialMedia.twitter,
              youtube: value.isEmpty ? null : value,
            );
            ref
                .read(shopSettingsProvider.notifier)
                .updateSocialMediaLinks(updatedLinks);
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSettings(ShopSettingsState settingsState) {
    return _buildSettingsCard(
      title: 'Payment Settings',
      icon: Icons.payment,
      children: [
        _buildActionTile(
          title: 'Payment Methods',
          subtitle: 'Configure payment options',
          icon: Icons.credit_card,
          onTap: () {
            // TODO: Navigate to payment methods
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Payment methods configuration coming soon')),
            );
          },
        ),
        _buildActionTile(
          title: 'Pricing Plans',
          subtitle: 'Manage service pricing',
          icon: Icons.monetization_on,
          onTap: () {
            // TODO: Navigate to pricing plans
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pricing plans coming soon')),
            );
          },
        ),
        _buildActionTile(
          title: 'Transaction History',
          subtitle: 'View payment transactions',
          icon: Icons.history,
          onTap: () {
            // TODO: Navigate to transaction history
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Transaction history coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(ShopSettingsState settingsState) {
    return _buildSettingsCard(
      title: 'Notification Settings',
      icon: Icons.notifications,
      children: [
        _buildSwitchTile(
          title: 'Push Notifications',
          subtitle: 'Receive push notifications for new bookings',
          value: settingsState.notificationsEnabled,
          onChanged: (value) {
            ref.read(shopSettingsProvider.notifier).toggleNotifications(value);
          },
        ),
        _buildActionTile(
          title: 'Email Notifications',
          subtitle: 'Configure email notification preferences',
          icon: Icons.email,
          onTap: () {
            // TODO: Navigate to email settings
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Email notification settings coming soon')),
            );
          },
        ),
        _buildActionTile(
          title: 'SMS Notifications',
          subtitle: 'Configure SMS notification preferences',
          icon: Icons.sms,
          onTap: () {
            // TODO: Navigate to SMS settings
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('SMS notification settings coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.greyMedium.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppTheme.black, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                if (action != null) action,
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.greyMedium,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldTile({
    required String title,
    required String subtitle,
    required String value,
    required ValueChanged<String> onChanged,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.greyMedium,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: TextEditingController(text: value),
            onChanged: onChanged,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppTheme.greyMedium.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryYellow),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.greyMedium.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.black, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.greyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 16, color: AppTheme.greyMedium),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkingHoursTile(String day, DaySchedule daySchedule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          if (daySchedule.closed)
            const Text(
              'CLOSED',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            )
          else
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daySchedule.open,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(' - '),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    daySchedule.close,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  DaySchedule _getDaySchedule(WorkingHours workingHours, String day) {
    switch (day) {
      case 'Monday':
        return workingHours.monday;
      case 'Tuesday':
        return workingHours.tuesday;
      case 'Wednesday':
        return workingHours.wednesday;
      case 'Thursday':
        return workingHours.thursday;
      case 'Friday':
        return workingHours.friday;
      case 'Saturday':
        return workingHours.saturday;
      case 'Sunday':
        return workingHours.sunday;
      default:
        return const DaySchedule(
            open: '9:00 AM', close: '5:00 PM', closed: true);
    }
  }

  void _showWorkingHoursDialog(
      BuildContext context, WorkingHours workingHours) {
    showDialog(
      context: context,
      builder: (context) => WorkingHoursDialog(
        workingHours: workingHours,
        onSave: (updatedHours) {
          ref
              .read(shopSettingsProvider.notifier)
              .updateWorkingHours(updatedHours);
        },
      ),
    );
  }

  void _showSocialMediaDialog(
      BuildContext context, SocialMediaLinks socialMedia) {
    showDialog(
      context: context,
      builder: (context) => SocialMediaDialog(
        socialMedia: socialMedia,
        onSave: (updatedLinks) {
          ref
              .read(shopSettingsProvider.notifier)
              .updateSocialMediaLinks(updatedLinks);
        },
      ),
    );
  }
}

class WorkingHoursDialog extends StatefulWidget {
  final WorkingHours workingHours;
  final Function(WorkingHours) onSave;

  const WorkingHoursDialog({
    super.key,
    required this.workingHours,
    required this.onSave,
  });

  @override
  State<WorkingHoursDialog> createState() => _WorkingHoursDialogState();
}

class _WorkingHoursDialogState extends State<WorkingHoursDialog> {
  late Map<String, DaySchedule> _hours;

  @override
  void initState() {
    super.initState();
    _hours = {
      'Monday': widget.workingHours.monday,
      'Tuesday': widget.workingHours.tuesday,
      'Wednesday': widget.workingHours.wednesday,
      'Thursday': widget.workingHours.thursday,
      'Friday': widget.workingHours.friday,
      'Saturday': widget.workingHours.saturday,
      'Sunday': widget.workingHours.sunday,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Working Hours'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _hours.entries.map((entry) {
              final day = entry.key;
              final schedule = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        day,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Checkbox(
                      value: !schedule.closed,
                      onChanged: (value) {
                        setState(() {
                          _hours[day] = DaySchedule(
                            open: schedule.open,
                            close: schedule.close,
                            closed: !(value ?? false),
                          );
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    if (!schedule.closed) ...[
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller:
                              TextEditingController(text: schedule.open),
                          decoration: const InputDecoration(
                            labelText: 'Open',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _hours[day] = DaySchedule(
                              open: value,
                              close: schedule.close,
                              closed: false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller:
                              TextEditingController(text: schedule.close),
                          decoration: const InputDecoration(
                            labelText: 'Close',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _hours[day] = DaySchedule(
                              open: schedule.open,
                              close: value,
                              closed: false,
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedHours = WorkingHours(
              monday: _hours['Monday'] ??
                  const DaySchedule(
                      open: '9:00 AM', close: '5:00 PM', closed: false),
              tuesday: _hours['Tuesday'] ??
                  const DaySchedule(
                      open: '9:00 AM', close: '5:00 PM', closed: false),
              wednesday: _hours['Wednesday'] ??
                  const DaySchedule(
                      open: '9:00 AM', close: '5:00 PM', closed: false),
              thursday: _hours['Thursday'] ??
                  const DaySchedule(
                      open: '9:00 AM', close: '5:00 PM', closed: false),
              friday: _hours['Friday'] ??
                  const DaySchedule(
                      open: '9:00 AM', close: '5:00 PM', closed: false),
              saturday: _hours['Saturday'] ??
                  const DaySchedule(
                      open: '9:00 AM', close: '5:00 PM', closed: false),
              sunday: _hours['Sunday'] ??
                  const DaySchedule(
                      open: '9:00 AM', close: '5:00 PM', closed: false),
            );
            widget.onSave(updatedHours);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class SocialMediaDialog extends StatefulWidget {
  final SocialMediaLinks socialMedia;
  final Function(SocialMediaLinks) onSave;

  const SocialMediaDialog({
    super.key,
    required this.socialMedia,
    required this.onSave,
  });

  @override
  State<SocialMediaDialog> createState() => _SocialMediaDialogState();
}

class _SocialMediaDialogState extends State<SocialMediaDialog> {
  late TextEditingController _facebookController;
  late TextEditingController _instagramController;
  late TextEditingController _twitterController;
  late TextEditingController _youtubeController;

  @override
  void initState() {
    super.initState();
    _facebookController =
        TextEditingController(text: widget.socialMedia.facebook ?? '');
    _instagramController =
        TextEditingController(text: widget.socialMedia.instagram ?? '');
    _twitterController =
        TextEditingController(text: widget.socialMedia.twitter ?? '');
    _youtubeController =
        TextEditingController(text: widget.socialMedia.youtube ?? '');
  }

  @override
  void dispose() {
    _facebookController.dispose();
    _instagramController.dispose();
    _twitterController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Social Media Links'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _facebookController,
            decoration: const InputDecoration(
              labelText: 'Facebook URL',
              hintText: 'https://facebook.com/yourpage',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _instagramController,
            decoration: const InputDecoration(
              labelText: 'Instagram URL',
              hintText: 'https://instagram.com/yourprofile',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _twitterController,
            decoration: const InputDecoration(
              labelText: 'Twitter URL',
              hintText: 'https://twitter.com/yourhandle',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _youtubeController,
            decoration: const InputDecoration(
              labelText: 'YouTube URL',
              hintText: 'https://youtube.com/yourchannel',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedLinks = SocialMediaLinks(
              facebook: _facebookController.text.isEmpty
                  ? null
                  : _facebookController.text,
              instagram: _instagramController.text.isEmpty
                  ? null
                  : _instagramController.text,
              twitter: _twitterController.text.isEmpty
                  ? null
                  : _twitterController.text,
              youtube: _youtubeController.text.isEmpty
                  ? null
                  : _youtubeController.text,
            );
            widget.onSave(updatedLinks);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
