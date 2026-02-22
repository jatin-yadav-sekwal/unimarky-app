import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/core/widgets/app_shimmer.dart';
import 'package:unimarky/features/marketplace/models/marketplace_item.dart';
import 'package:unimarky/features/marketplace/widgets/category_filter.dart';
import 'package:unimarky/features/marketplace/widgets/marketplace_card.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final _searchController = TextEditingController();
  List<MarketplaceItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _offset = 0;
  String _category = 'all';
  String _search = '';
  static const _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchItems(reset: true);
  }

  Future<void> _fetchItems({bool reset = false}) async {
    if (reset) {
      setState(() { _loading = true; _offset = 0; });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final api = ApiClient.instance;
      final catParam = _category != 'all' ? '&category=$_category' : '';
      final qParam = _search.isNotEmpty ? '&q=${Uri.encodeComponent(_search)}' : '';
      final data = await api.get('/marketplace?limit=$_limit&offset=${reset ? 0 : _offset}$catParam$qParam');
      final items = (data['items'] as List? ?? []).map((e) => MarketplaceItem.fromJson(e)).toList();
      setState(() {
        if (reset) { _items = items; } else { _items.addAll(items); }
        _hasMore = data['hasMore'] == true;
        _offset = (reset ? 0 : _offset) + items.length;
      });
    } catch (_) {}
    setState(() { _loading = false; _loadingMore = false; });
  }

  void _onCategoryChanged(String cat) {
    _category = cat;
    _fetchItems(reset: true);
  }

  void _onSearchChanged(String q) {
    _search = q;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_search == q) _fetchItems(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        actions: [
          TextButton(
            onPressed: () => context.push('/my-listings'),
            child: const Text('My Listings'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/marketplace/create'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetchItems(reset: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Search
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            // Category filters
            CategoryFilter(
              items: marketplaceCategories.cast<Map<String, String>>(),
              selected: _category,
              onSelected: _onCategoryChanged,
            ),
            const SizedBox(height: 16),

            // Loading
            if (_loading)
              ...[for (int i = 0; i < 4; i++) ...[
                AppShimmer(width: double.infinity, height: 200),
                const SizedBox(height: 12),
              ]]
            else if (_items.isEmpty)
              _EmptyState(onReport: () => context.push('/marketplace/create'))
            else ...[
              // Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: _items.length,
                itemBuilder: (_, i) => MarketplaceCard(
                  item: _items[i],
                  onTap: () => context.push('/marketplace/${_items[i].id}'),
                ),
              ),

              // Load more
              if (_hasMore)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _loadingMore
                        ? const CircularProgressIndicator()
                        : TextButton.icon(
                            onPressed: () => _fetchItems(),
                            icon: const Icon(Icons.expand_more),
                            label: const Text('Load More'),
                          ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onReport;
  const _EmptyState({required this.onReport});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.shopping_bag_outlined, size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text('No items yet', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Be the first to list something!', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          FilledButton(onPressed: onReport, child: const Text('List an Item')),
        ],
      ),
    ),
  );
}
