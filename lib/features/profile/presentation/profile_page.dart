import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/navigation/bottom_navigation.dart';
import '../../authentication/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please login to view your profile.')),
      );
    }

    final email = user.email ?? 'No email available';
    final displayName = user.displayName;

    final profileAsync = ref.watch(currentUserProvider);
    final userProfile = profileAsync.valueOrNull;
    final isAdmin = userProfile?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile Name',
            onPressed: () => _showEditProfileDialog(context, user),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Icon(Icons.person, size: 52, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayName?.isNotEmpty == true
                        ? displayName!
                        : 'COMSATS Student',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _showEditProfileDialog(context, user),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              _ProfileSection(
                title: 'Account',
                children: [
                  _ProfileTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    subtitle: email,
                  ),
                  if (userProfile?.studentId?.isNotEmpty == true)
                    _ProfileTile(
                      icon: Icons.badge_outlined,
                      title: 'Student ID',
                      subtitle: userProfile!.studentId!,
                    ),
                  if (userProfile?.department?.isNotEmpty == true)
                    _ProfileTile(
                      icon: Icons.school_outlined,
                      title: 'Department',
                      subtitle: userProfile!.department!,
                    ),
                  _ProfileTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Account Status',
                    subtitle: isAdmin ? 'Administrator' : 'Active COMSATS User',
                    trailing: Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _ProfileSection(
                title: 'Application',
                children: [
                  _ProfileTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'My Reported Items',
                    subtitle: 'View items you posted',
                    onTap: () {
                      context.go(AppRoutes.myItems);
                    },
                  ),
                  _ProfileTile(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'My Submitted Claims',
                    subtitle: 'View your claim requests',
                    onTap: () {
                      context.push(AppRoutes.myClaims);
                    },
                  ),
                  _ProfileTile(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Claim updates & alerts',
                    onTap: () {
                      context.push(AppRoutes.notifications);
                    },
                  ),
                  _ProfileTile(
                    icon: Icons.search_outlined,
                    title: 'Search Items',
                    subtitle: 'Find lost and found items',
                    onTap: () {
                      context.go(AppRoutes.search);
                    },
                  ),
                  if (isAdmin)
                    _ProfileTile(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin Dashboard',
                      subtitle: 'Manage reports & moderation',
                      onTap: () {
                        context.push(AppRoutes.adminDashboard);
                      },
                    ),
                  _ProfileTile(
                    icon: Icons.settings_outlined,
                    title: 'Settings',
                    subtitle: 'Preferences & App version',
                    onTap: () {
                      context.push(AppRoutes.settings);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'COMSATS Lost & Found',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(currentIndex: 3),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context, User user) async {
    final controller = TextEditingController(text: user.displayName);

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Full Name / Roll Number',
            hintText: 'e.g. Saad Nafees (FA21-BCS-001)',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updated == true && controller.text.trim().isNotEmpty) {
      final newName = controller.text.trim();
      try {
        await user.updateDisplayName(newName);
        await ref
            .read(updateDisplayNameProvider)
            .call(uid: user.uid, displayName: newName);
        ref.invalidate(currentUserProvider);

        if (context.mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
          );
        }
      }
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout?'),
          content: const Text(
            'Are you sure you want to logout from your account?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(logoutProvider).call();

    if (!context.mounted) {
      return;
    }

    context.go(AppRoutes.login);
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing:
          trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
    );
  }
}
