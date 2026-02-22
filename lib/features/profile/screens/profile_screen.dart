import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/features/auth/providers/auth_provider.dart';

/// Profile screen — mirrors web's ProfilePage.tsx (basic view).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              child: profile?.avatarUrl != null
                  ? ClipOval(
                      child: Image.network(profile!.avatarUrl!,
                          width: 100, height: 100, fit: BoxFit.cover))
                  : Text(
                      (profile?.fullName ?? 'U')[0].toUpperCase(),
                      style: TextStyle(
                          fontSize: 36, color: theme.colorScheme.primary),
                    ),
            ),
            const SizedBox(height: 16),

            // Name
            Text(profile?.fullName ?? 'UniMARKY User',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(authState.user?.email ?? '',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.textTheme.bodySmall?.color)),
            const SizedBox(height: 24),

            // Info cards
            _InfoCard(
              icon: Icons.school,
              label: 'University',
              value: profile?.universityName ?? '—',
            ),
            _InfoCard(
              icon: Icons.phone,
              label: 'Mobile',
              value: profile?.mobileNumber ?? '—',
            ),
            _InfoCard(
              icon: Icons.badge,
              label: 'Role',
              value: authState.role.toUpperCase(),
            ),
            const SizedBox(height: 24),

            // Quick actions
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('My Content'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/my-content'),
            ),
            if (authState.role == 'superuser')
              ListTile(
                leading: const Icon(Icons.dashboard_customize),
                title: const Text('Superuser Dashboard'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/superuser'),
              ),
            if (authState.role == 'userX')
              ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Admin Panel'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/admin'),
              ),
            if (authState.role == 'normal')
              ListTile(
                leading: const Icon(Icons.upgrade),
                title: const Text('Request Role Upgrade'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/request-role'),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out',
                  style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) context.go('/auth');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
