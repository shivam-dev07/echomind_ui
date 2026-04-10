import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/auth_service.dart';
import '../core/mock_data.dart';
import '../core/theme.dart';
import '../core/widgets.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

  // Toggle states
  bool _backgroundListening = true;
  bool _pushNotifications = true;
  bool _autoAddCalendar = false;
  bool _calendarConnected = true;

  @override
  void initState() {
    super.initState();
    _authService.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    _authService.removeListener(_onAuthChange);
    super.dispose();
  }

  void _onAuthChange() {
    if (mounted) setState(() {});
  }

  Future<void> _signOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => _buildSignOutDialog(ctx),
    );

    if (confirm != true) return;
    await _authService.signOut();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildSignOutDialog(BuildContext ctx) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.error.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.error.withOpacity(0.2),
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 20),
                Text('Sign Out', style: AppTypography.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Are you sure you want to sign out?',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: NeumorphicButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx, true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            border: Border.all(
                              color: AppColors.error.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Sign Out',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
          children: [
            const AppLogoHeader(),
            const SizedBox(height: 24),
            Text('Settings', style: AppTypography.displayMedium),
            const SizedBox(height: 28),

            // Profile Section
            _buildGlassSection(
              title: 'Profile',
              icon: Icons.person_rounded,
              child: Row(
                children: [
                  // Avatar with gradient border
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.primaryGradient,
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.surface,
                      child: Text(
                        MockDataProvider.userInitials,
                        style: AppTypography.headlineLarge.copyWith(
                          fontSize: 18,
                          foreground: Paint()
                            ..shader = AppColors.primaryGradient.createShader(
                              const Rect.fromLTWH(0, 0, 40, 40),
                            ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          MockDataProvider.userName,
                          style: AppTypography.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          MockDataProvider.userEmail,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Edit icon
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      color: AppColors.glass,
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: AppColors.textTertiary,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Usage stats
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    '5',
                    'Meetings',
                    Icons.mic_none_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    '2.5h',
                    'Recorded',
                    Icons.timer_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    '12',
                    'Actions',
                    Icons.task_alt_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Connectors Section
            _buildGlassSection(
              title: 'Connectors',
              icon: Icons.link_rounded,
              child: Column(
                children: [
                  _buildConnectorItem(
                    icon: Icons.calendar_month_rounded,
                    title: 'Google Calendar',
                    subtitle: 'Syncing 3 upcoming events',
                    isConnected: _calendarConnected,
                    trailing: GestureDetector(
                      onTap: () {
                        setState(() => _calendarConnected = !_calendarConnected);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          gradient: _calendarConnected
                              ? null
                              : AppColors.primaryGradient,
                          color: _calendarConnected
                              ? AppColors.success.withOpacity(0.1)
                              : null,
                          border: _calendarConnected
                              ? Border.all(
                                  color: AppColors.success.withOpacity(0.3))
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_calendarConnected)
                              Icon(Icons.check_rounded,
                                  size: 14, color: AppColors.success),
                            if (_calendarConnected) const SizedBox(width: 4),
                            Text(
                              _calendarConnected ? 'Connected' : 'Connect',
                              style: AppTypography.caption.copyWith(
                                color: _calendarConnected
                                    ? AppColors.success
                                    : Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 0.5,
                    color: AppColors.border,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  _buildConnectorItem(
                    icon: Icons.videocam_rounded,
                    title: 'Google Meet',
                    subtitle: 'Auto-record virtual meetings',
                    isConnected: false,
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Text(
                        'Connect',
                        style: AppTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Preferences Section
            _buildGlassSection(
              title: 'Preferences',
              icon: Icons.tune_rounded,
              child: Column(
                children: [
                  _buildSwitchTile(
                    'Background Listening',
                    'Record meetings automatically',
                    _backgroundListening,
                    (v) => setState(() => _backgroundListening = v),
                  ),
                  _divider(),
                  _buildSwitchTile(
                    'Push Notifications',
                    'Get notified when summaries are ready',
                    _pushNotifications,
                    (v) => setState(() => _pushNotifications = v),
                  ),
                  _divider(),
                  _buildSwitchTile(
                    'Auto-add to Calendar',
                    'Create calendar events from meetings',
                    _autoAddCalendar,
                    (v) => setState(() => _autoAddCalendar = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Account Actions
            _buildGlassSection(
              title: 'Account',
              icon: Icons.manage_accounts_rounded,
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.download_rounded,
                    title: 'Export My Data',
                    subtitle: '5 meetings, 12 action items',
                    iconColor: AppColors.primaryPeach,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Preparing export...'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                  _divider(),
                  _buildActionTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'FAQ, contact us',
                    iconColor: AppColors.secondaryBlue,
                    onTap: () {},
                  ),
                  _divider(),
                  _buildActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: null,
                    iconColor: AppColors.error,
                    textColor: AppColors.error,
                    onTap: _signOut,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // App Version
            Center(
              child: Column(
                children: [
                  Text(
                    'EchoMind v1.0.0',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Made with 💡 for executive teams',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary.withOpacity(0.3),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, icon: icon),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatTile(String value, String label, IconData icon) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      borderRadius: AppRadius.lg,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryPeach, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.caption.copyWith(fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildConnectorItem({
    required IconData icon,
    required String title,
    String? subtitle,
    bool isConnected = false,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              color: AppColors.glass,
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(fontSize: 14),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isConnected
                          ? AppColors.success.withOpacity(0.7)
                          : AppColors.textTertiary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          GlowingSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                color: iconColor.withOpacity(0.1),
                border: Border.all(color: iconColor.withOpacity(0.1)),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        fontSize: 11,
                        color: AppColors.textTertiary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textTertiary.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 0.5,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
