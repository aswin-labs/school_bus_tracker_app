import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:school_bus_tracker/core/extensions/context_extensions.dart';
import 'package:school_bus_tracker/core/theme/app_colors.dart';
import 'package:school_bus_tracker/core/theme/theme_provider.dart';
import 'package:school_bus_tracker/core/utils/snackbar_helper.dart';
import 'package:school_bus_tracker/core/widgets/common_pop_up.dart';
import 'package:school_bus_tracker/features/auth/presentation/provider/auth_provider.dart';
import 'package:school_bus_tracker/features/settings/presentation/provider/settings_provider.dart';
import 'package:school_bus_tracker/features/settings/presentation/widgets/edit_profile_dialog.dart';
import 'package:school_bus_tracker/features/settings/presentation/widgets/school_details_card.dart';
import 'package:school_bus_tracker/features/settings/presentation/widgets/settings_section_card.dart';
import 'package:school_bus_tracker/features/settings/presentation/widgets/staff_profile_card.dart';
import 'package:school_bus_tracker/routes/router_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().fetchProfileAndSchoolDetails();
    });
  }

  Future<void> _handleLogout() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.logout();

    if (!mounted) return;

    if (error != null) {
      SnackbarHelper.showError(context, message: error);
    } else {
      context.read<SettingsProvider>().clearProfile();
      context.goNamed(RouterConstants.loginScreen);
    }
  }

  void _showEditProfileDialog() {
    final user = context.read<SettingsProvider>().user;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => EditProfileDialog(user: user),
    );
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: context.theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Profile Picture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ImageSourceOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickAndUploadImage(ImageSource.camera);
                    },
                  ),
                  _ImageSourceOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(bottomSheetContext);
                      _pickAndUploadImage(ImageSource.gallery);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null || !mounted) return;

      final provider = context.read<SettingsProvider>();
      final error = await provider.updateDp(filePath: pickedFile.path);

      if (!mounted) return;

      if (error == null) {
        SnackbarHelper.showSuccess(
          context,
          message: 'Profile picture updated successfully',
        );
      } else {
        SnackbarHelper.showError(
          context,
          message: error,
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString();
      final message = errorStr.contains('channel-error')
          ? 'Please restart the app to enable photo selection'
          : 'Failed to pick image: $e';
      SnackbarHelper.showError(
        context,
        message: message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final settingsProvider = context.watch<SettingsProvider>();

    final user = settingsProvider.user;
    final school = settingsProvider.school;
    final isLoading = settingsProvider.isLoading;
    final isUpdatingDp = settingsProvider.isUpdatingDp;
    final errorMessage = settingsProvider.errorMessage;

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            context.read<SettingsProvider>().fetchProfileAndSchoolDetails(),
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LOADING STATE (Initial) ──────────────────────
              if (isLoading && user == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              // ── ERROR STATE (Initial) ────────────────────────
              else if (errorMessage != null && user == null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.error.withAlpha(60),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AppColors.error,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => context
                            .read<SettingsProvider>()
                            .fetchProfileAndSchoolDetails(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              // ── MAIN CONTENT ─────────────────────────────────
              else ...[
                // Staff Profile Card with edit and update dp actions
                StaffProfileCard(
                  user: user,
                  isLoading: isLoading,
                  isUpdatingDp: isUpdatingDp,
                  onUpdateDpTap: _showImagePickerBottomSheet,
                  onEditProfileTap: _showEditProfileDialog,
                ),

                const SizedBox(height: 14),

                // School Details Card
                if (school != null) ...[
                  SchoolDetailsCard(school: school),
                  const SizedBox(height: 14),
                ],

                // Preferences Card
                SettingsSectionCard(
                  title: 'Preferences',
                  icon: Icons.tune_rounded,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (themeProvider.mode == ThemeMode.dark
                                        ? Colors.amber
                                        : AppColors.primary)
                                    .withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                themeProvider.mode == ThemeMode.dark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                size: 18,
                                color: themeProvider.mode == ThemeMode.dark
                                    ? Colors.amber
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dark Mode',
                                  style: context.text.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  themeProvider.mode == ThemeMode.dark
                                      ? 'Dark theme enabled'
                                      : 'Light theme enabled',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch.adaptive(
                          value: themeProvider.mode == ThemeMode.dark,
                          activeTrackColor: AppColors.primary,
                          activeThumbColor: Colors.white,
                          onChanged: (_) => themeProvider.toggleTheme(),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Account & Logout Card
                SettingsSectionCard(
                  title: 'Account',
                  icon: Icons.shield_outlined,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (authProvider.isLoading) return;
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) => CommonPopUp(
                              icon: Icons.logout_rounded,
                              title: "Logout",
                              subtitle: "Are you sure you want to logout?",
                              iconText: "logout",
                              onPressed: () {
                                Navigator.pop(dialogContext);
                                _handleLogout();
                              },
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.error.withAlpha(40),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Sign out of transport staff account",
                                      style: TextStyle(
                                        color: AppColors.textMuted,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: AppColors.error,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // App version & branding footer
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Acadobs School Bus Tracker',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted.withAlpha(180),
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Version 1.0.0 (Transport Staff)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withAlpha(40),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
