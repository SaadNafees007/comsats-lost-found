import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/theme_mode_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _version = '1.0.0';
  String _buildNumber = '1';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = info.version;
        _buildNumber = info.buildNumber;
      });
    } catch (_) {
      // Fallback to default
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -----------------------------------------------
          // Appearance
          // -----------------------------------------------
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Theme',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose how the app looks',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ThemeOption(
                      label: 'System',
                      icon: Icons.brightness_auto_outlined,
                      isSelected: currentThemeMode == ThemeMode.system,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.system),
                    ),
                    const SizedBox(width: 10),
                    _ThemeOption(
                      label: 'Light',
                      icon: Icons.light_mode_outlined,
                      isSelected: currentThemeMode == ThemeMode.light,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.light),
                    ),
                    const SizedBox(width: 10),
                    _ThemeOption(
                      label: 'Dark',
                      icon: Icons.dark_mode_outlined,
                      isSelected: currentThemeMode == ThemeMode.dark,
                      onTap: () => ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.dark),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // -----------------------------------------------
          // Preferences
          // -----------------------------------------------
          const Text(
            'Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Push Notifications',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Receive alerts when your item is claimed',
                  ),
                  secondary: const Icon(Icons.notifications_active_outlined),
                  value: _notificationsEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _notificationsEnabled = val;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.location_city_outlined),
                  title: const Text(
                    'Campus Location',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'COMSATS University Islamabad, Wah Campus',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // -----------------------------------------------
          // About
          // -----------------------------------------------
          const Text(
            'About Application',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text(
                    'App Version',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('v$_version (Build $_buildNumber)'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: const Text(
                    'Privacy & Data Policy',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Student data protection rules'),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'COMSATS Lost & Found',
                      applicationVersion: 'v$_version',
                      applicationIcon: Icon(
                        Icons.inventory_2,
                        size: 40,
                        color: AppColors.primary,
                      ),
                      children: [
                        const Text(
                          'COMSATS Lost & Found is designed for COMSATS University Islamabad, Wah Campus students and staff to report and recover lost belongings safely.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
