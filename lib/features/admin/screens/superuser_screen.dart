import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';

class SuperuserScreen extends StatefulWidget {
  const SuperuserScreen({super.key});

  @override
  State<SuperuserScreen> createState() => _SuperuserScreenState();
}

class _SuperuserScreenState extends State<SuperuserScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _restaurants = [];
  List<dynamic> _accommodations = [];
  List<dynamic> _materials = [];
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
      final results = await Future.wait([
        ApiClient.instance.get('/food/my-listings'),
        ApiClient.instance.get('/accommodation/my-listings'),
        ApiClient.instance.get('/study/mine'),
      ]);
      setState(() {
        _restaurants = results[0] is List ? results[0] : [];
        _accommodations = results[1] is List ? results[1] : [];
        _materials = results[2] is List ? results[2] : [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _deleteItem(String endpoint, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) { return; }
    try {
      await ApiClient.instance.delete('$endpoint/$id');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deleted successfully'), backgroundColor: Colors.green));
      _loadAll();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Superuser Dashboard'),
        bottom: TabBar(controller: _tabCtrl, tabs: const [
          Tab(text: 'Food'),
          Tab(text: 'Housing'),
          Tab(text: 'Study'),
        ]),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabCtrl, children: [
              _buildList(_restaurants, 'restaurants', '/food', Icons.restaurant, theme),
              _buildList(_accommodations, 'accommodations', '/accommodation', Icons.apartment, theme),
              _buildMaterialList(theme),
            ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final tabIndex = _tabCtrl.index;
          if (tabIndex == 2) {
            context.push('/study/upload');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add new items from the web dashboard')));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildList(List<dynamic> items, String label, String endpoint, IconData icon, ThemeData theme) {
    if (items.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        Text('No $label yet', style: theme.textTheme.titleMedium),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(icon, color: theme.colorScheme.primary),
              title: Text(item['name'] ?? 'Untitled', maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(item['location'] ?? item['type'] ?? '', maxLines: 1),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteItem(endpoint, item['id']),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMaterialList(ThemeData theme) {
    if (_materials.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.school, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
        const SizedBox(height: 12),
        Text('No study materials yet', style: theme.textTheme.titleMedium),
      ]));
    }
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _materials.length,
        itemBuilder: (_, i) {
          final m = _materials[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.description, color: theme.colorScheme.primary),
              title: Text(m['title'] ?? 'Untitled', maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text('${m['department'] ?? ''} • ${m['year'] ?? ''}', maxLines: 1),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteItem('/study', m['id']),
              ),
            ),
          );
        },
      ),
    );
  }
}
