import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/features/auth/providers/auth_provider.dart';

/// Role-based navigation drawer — mirrors web's Sidebar.tsx.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final profile = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final role = authState.role;

    return Drawer(
      child: Column(
        children: [
          // Header
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            accountName: Text(profile?.fullName ?? 'UniMARKY User',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(authState.user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (profile?.fullName ?? 'U')[0].toUpperCase(),
                style: TextStyle(
                    fontSize: 24, color: theme.colorScheme.primary),
              ),
            ),
          ),

          // Main nav items
          _DrawerItem(icon: Icons.dashboard, label: 'Dashboard', route: '/dashboard'),
          _DrawerItem(icon: Icons.shopping_bag, label: 'Marketplace', route: '/marketplace'),
          _DrawerItem(icon: Icons.search, label: 'Lost & Found', route: '/lost-found'),
          _DrawerItem(icon: Icons.newspaper, label: 'Unimedia', route: '/unimedia'),
          _DrawerItem(icon: Icons.restaurant, label: 'Food', route: '/food'),
          _DrawerItem(icon: Icons.home, label: 'Housing', route: '/housing'),
          _DrawerItem(icon: Icons.menu_book, label: 'Study', route: '/study'),

          const Divider(),

          // User items
          _DrawerItem(icon: Icons.person, label: 'Profile', route: '/profile'),
          _DrawerItem(icon: Icons.list_alt, label: 'My Listings', route: '/my-listings'),
          _DrawerItem(icon: Icons.article, label: 'My Content', route: '/my-content'),

          // Superuser/Admin items (role-based)
          if (role == 'superuser' || role == 'admin') ...[
            const Divider(),
            _DrawerItem(icon: Icons.admin_panel_settings, label: 'Superuser', route: '/superuser'),
          ],
          if (role == 'admin') ...[
            _DrawerItem(icon: Icons.shield, label: 'Admin', route: '/admin'),
          ],

          const Spacer(),
          const Divider(),

          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go('/auth');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = GoRouterState.of(context).uri.path.startsWith(route);
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon,
          color: isSelected ? theme.colorScheme.primary : null),
      title: Text(label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : null,
          )),
      selected: isSelected,
      onTap: () {
        Navigator.pop(context);
        context.go(route);
      },
    );
  }
}
