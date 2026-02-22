import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';

class MyContentScreen extends StatefulWidget {
  const MyContentScreen({super.key});

  @override
  State<MyContentScreen> createState() => _MyContentScreenState();
}

class _MyContentScreenState extends State<MyContentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _posts = [];
  List<dynamic> _listings = [];
  List<dynamic> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final dashData = await ApiClient.instance.get('/dashboard/summary');
      setState(() {
        _listings = dashData['marketplace'] is List ? dashData['marketplace'] : [];
        _reports = dashData['lostFound'] is List ? dashData['lostFound'] : [];
        _posts = dashData['announcements'] is List ? dashData['announcements'] : [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Content'),
        bottom: TabBar(controller: _tabCtrl, tabs: const [
          Tab(text: 'Listings'),
          Tab(text: 'Reports'),
          Tab(text: 'Posts'),
        ]),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabCtrl, children: [
              _buildTab(_listings, 'listings', Icons.shopping_bag, theme, (id) => context.push('/marketplace/$id')),
              _buildTab(_reports, 'reports', Icons.search, theme, (id) => context.push('/lost-found/$id')),
              _buildTab(_posts, 'posts', Icons.article, theme, null),
            ]),
    );
  }

  Widget _buildTab(List<dynamic> items, String label, IconData icon, ThemeData theme, void Function(String id)? onTap) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        Text('No $label yet', style: theme.textTheme.titleMedium),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final title = item['title'] ?? item['itemName'] ?? item['item_name'] ?? 'Untitled';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(icon, color: theme.colorScheme.primary),
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(_formatDate(item['createdAt'] ?? item['created_at']), style: theme.textTheme.labelSmall),
            trailing: const Icon(Icons.chevron_right),
            onTap: onTap != null ? () => onTap(item['id']) : null,
          ),
        );
      },
    );
  }

  String _formatDate(String? date) {
    if (date == null) { return ''; }
    final d = DateTime.tryParse(date);
    if (d == null) { return ''; }
    return '${d.day}/${d.month}/${d.year}';
  }
}
