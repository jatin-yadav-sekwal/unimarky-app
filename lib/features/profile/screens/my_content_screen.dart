import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MyContentScreen extends StatelessWidget {
  const MyContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Content'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _ContentSectionTile(
            icon: Icons.shopping_bag_outlined,
            title: 'My Marketplace Listings',
            onTap: () => context.push('/marketplace/my-listings'),
          ),
          const Divider(height: 1),
          _ContentSectionTile(
            icon: Icons.search,
            title: 'My Lost & Found Reports',
            onTap: () => context.push('/lost-found/my-listings'),
          ),
          const Divider(height: 1),
          _ContentSectionTile(
            icon: Icons.article_outlined,
            title: 'My Unimedia Posts',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unimedia posts management coming soon!')));
            },
          ),
          const Divider(height: 1),
          _ContentSectionTile(
            icon: Icons.restaurant_menu,
            title: 'My Food & Restaurants',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food management coming soon!')));
            },
          ),
          const Divider(height: 1),
          _ContentSectionTile(
            icon: Icons.other_houses_outlined,
            title: 'My Accommodations',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Accommodation management coming soon!')));
            },
          ),
          const Divider(height: 1),
          _ContentSectionTile(
            icon: Icons.menu_book_outlined,
            title: 'My Study Materials',
            onTap: () {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Study material management coming soon!')));
            },
          ),
        ],
      ),
    );
  }
}

class _ContentSectionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ContentSectionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: theme.colorScheme.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
