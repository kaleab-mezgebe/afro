import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/profile_controller.dart';
import '../../../core/theme/app_theme.dart';

// ─── Palette ────────────────────────────────────────────────────────────────
const _yellow = AppTheme.primaryYellow;
const _black = AppTheme.black;
const _bg = Color(0xFFF7F7F7);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final ProfileController _ctrl = Get.find<ProfileController>();
  final _formKey = GlobalKey<FormState>();
  bool _hasChanges = false;

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _dobCtrl;

  String? _selectedGender;
  List<String> _selectedPrefs = [];
  File? _pickedImage;
  DateTime? _selectedDob;

  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _allPrefs = [
    'Haircut',
    'Beard Trim',
    'Shave',
    'Hair Coloring',
    'Styling',
    'Treatment',
    'Massage',
    'Facial',
    'Manicure',
    'Pedicure',
    'Lashes',
    'Brows',
    'Waxing',
    'Threading',
  ];

  @override
  void initState() {
    super.initState();
    final p = _ctrl.profile;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _phoneCtrl = TextEditingController(text: p?.phoneNumber ?? '');
    _bioCtrl = TextEditingController(text: p?.bio ?? '');
    _dobCtrl = TextEditingController();
    _selectedGender = p?.gender;
    _selectedPrefs = List.from(p?.preferences ?? []);
    if (p?.dateOfBirth != null) {
      _selectedDob = p!.dateOfBirth;
      _dobCtrl.text = _formatDate(p.dateOfBirth!);
    }

    // Track changes
    for (final c in [_nameCtrl, _phoneCtrl, _bioCtrl, _dobCtrl]) {
      c.addListener(() => setState(() => _hasChanges = true));
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Unsaved Changes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('You have unsaved changes. Leave without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Editing',
              style: TextStyle(color: AppTheme.greyMedium),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return leave ?? false;
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _hasChanges = true;
      });
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      builder: (_, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: _yellow,
            onPrimary: _black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobCtrl.text = _formatDate(picked);
        _hasChanges = true;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await _ctrl.updateProfile(
      name: _nameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim().isEmpty
          ? null
          : _phoneCtrl.text.trim(),
      bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDob,
    );

    await _ctrl.updatePreferences(_selectedPrefs);

    if (_ctrl.error.isEmpty) {
      setState(() => _hasChanges = false);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _black,
            ),
            onPressed: () async {
              if (await _onWillPop()) Get.back();
            },
          ),
          title: const Text(
            'EDIT PROFILE',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
              color: _black,
            ),
          ),
          centerTitle: true,
          actions: [
            Obx(
              () => _ctrl.isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _yellow,
                        ),
                      ),
                    )
                  : TextButton(
                      onPressed: _save,
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: _yellow,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ──────────────────────────────────────────────
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundColor: _yellow,
                          backgroundImage: _pickedImage != null
                              ? FileImage(_pickedImage!) as ImageProvider
                              : (_ctrl.profile?.avatar?.isNotEmpty == true
                                    ? NetworkImage(_ctrl.profile!.avatar!)
                                    : null),
                          child:
                              (_pickedImage == null &&
                                  (_ctrl.profile?.avatar?.isEmpty ?? true))
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 52,
                                  color: _black,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _black,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Tap to change photo',
                    style: TextStyle(fontSize: 12, color: AppTheme.greyMedium),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Personal Info ────────────────────────────────────────
                _sectionLabel('PERSONAL INFORMATION'),
                const SizedBox(height: 12),
                _card([
                  _field(
                    controller: _nameCtrl,
                    label: 'Full Name',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name is required'
                        : null,
                  ),
                  _divider(),
                  _field(
                    initialValue: _ctrl.profile?.email ?? '',
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    enabled: false,
                    hint: 'Cannot be changed',
                  ),
                  _divider(),
                  _field(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  _divider(),
                  // Gender dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: const Icon(
                          Icons.wc_rounded,
                          color: AppTheme.greyMedium,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        labelStyle: const TextStyle(
                          color: AppTheme.greyMedium,
                          fontSize: 12,
                        ),
                      ),
                      items: _genders
                          .map(
                            (g) => DropdownMenuItem(value: g, child: Text(g)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() {
                        _selectedGender = v;
                        _hasChanges = true;
                      }),
                    ),
                  ),
                  _divider(),
                  // Date of birth
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: TextFormField(
                      controller: _dobCtrl,
                      readOnly: true,
                      onTap: _pickDob,
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        prefixIcon: Icon(
                          Icons.cake_outlined,
                          color: AppTheme.greyMedium,
                          size: 20,
                        ),
                        suffixIcon: Icon(
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: AppTheme.greyMedium,
                        ),
                        border: InputBorder.none,
                        labelStyle: TextStyle(
                          color: AppTheme.greyMedium,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Bio ──────────────────────────────────────────────────
                _sectionLabel('ABOUT ME'),
                const SizedBox(height: 12),
                _card([
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _bioCtrl,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Tell us a little about yourself...',
                        hintStyle: TextStyle(
                          color: AppTheme.greyMedium,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 24),

                // ── Preferences ──────────────────────────────────────────
                _sectionLabel('SERVICE PREFERENCES'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _allPrefs.map((pref) {
                      final sel = _selectedPrefs.contains(pref);
                      return GestureDetector(
                        onTap: () => setState(() {
                          sel
                              ? _selectedPrefs.remove(pref)
                              : _selectedPrefs.add(pref);
                          _hasChanges = true;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? _yellow.withValues(alpha: 0.15)
                                : const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: sel ? _yellow : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            pref,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: sel
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: sel ? _black : AppTheme.greyMedium,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 32),

                // ── Save Button ──────────────────────────────────────────
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _ctrl.isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _yellow,
                        foregroundColor: _black,
                        disabledBackgroundColor: _yellow.withValues(alpha: 0.5),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: _ctrl.isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _black,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w900,
      color: AppTheme.greyMedium,
      letterSpacing: 1.5,
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(children: children),
  );

  Widget _divider() => const Divider(
    height: 1,
    indent: 52,
    endIndent: 16,
    color: Color(0xFFF0F0F0),
  );

  Widget _field({
    TextEditingController? controller,
    String? initialValue,
    required String label,
    required IconData icon,
    bool enabled = true,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: enabled ? _black : AppTheme.greyMedium,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.greyMedium, size: 20),
          border: InputBorder.none,
          labelStyle: const TextStyle(color: AppTheme.greyMedium, fontSize: 12),
          filled: !enabled,
          fillColor: enabled ? null : const Color(0xFFF9F9F9),
        ),
      ),
    );
  }
}
