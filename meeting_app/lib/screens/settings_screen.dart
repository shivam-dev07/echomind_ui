import 'package:flutter/material.dart';

import '../core/auth_service.dart';
import '../core/theme.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();

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
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // App Logo Header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'EchoMind',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Settings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Profile Section
            _buildSectionCard(
              title: 'Profile',
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryPeach.withOpacity(0.2),
                    child: Text(
                      (user?.name ?? user?.email ?? '?')[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primaryPeach,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Connectors Section
            _buildSectionCard(
              title: 'Connectors',
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google Calendar',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Calendar integration coming soon'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPeach,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('Connect'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Call Recording Section
            _buildSectionCard(
              title: 'Call Recording',
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.phone_in_talk,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Not Available',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Call recording is blocked by Android security policies on this device',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Preferences
            _buildSectionCard(
              title: 'Preferences',
              child: Column(
                children: const [
                  _SwitchTile(label: 'Background Listening', value: true),
                  Divider(color: AppColors.border),
                  _SwitchTile(label: 'Push Notifications', value: true),
                  Divider(color: AppColors.border),
                  _SwitchTile(label: 'Auto-add to Calendar', value: true),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Account Actions
            _buildSectionCard(
              title: 'Account',
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryPeach.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.download_rounded, color: AppColors.primaryPeach, size: 20),
                    ),
                    title: const Text(
                      'Export My Data',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary.withOpacity(0.5),
                      size: 20,
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No data to export yet'),
                        ),
                      );
                    },
                  ),
                  const Divider(color: AppColors.border),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    ),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red, fontSize: 15),
                    ),
                    onTap: _signOut,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App Version
            Center(
              child: Text(
                'EchoMind v1.0.0',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryPeach,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _SwitchTile extends StatefulWidget {
  final String label;
  final bool value;

  const _SwitchTile({required this.label, required this.value});

  @override
  State<_SwitchTile> createState() => _SwitchTileState();
}

class _SwitchTileState extends State<_SwitchTile> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(widget.label, style: const TextStyle(color: AppColors.textPrimary)),
      value: _value,
      activeColor: AppColors.primaryPeach,
      onChanged: (next) {
        setState(() => _value = next);
      },
    );
  }
}
