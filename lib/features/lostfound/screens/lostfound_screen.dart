import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/core/widgets/app_shimmer.dart';
import 'package:unimarky/features/lostfound/models/lostfound_item.dart';
import 'package:unimarky/features/lostfound/widgets/lostfound_card.dart';
import 'package:unimarky/features/marketplace/widgets/category_filter.dart';

class LostFoundScreen extends StatefulWidget {
  const LostFoundScreen({super.key});
  @override
  State<LostFoundScreen> createState() => _LostFoundScreenState();
}

class _LostFoundScreenState extends State<LostFoundScreen> {
  final _searchController = TextEditingController();
  List<LostFoundItem> _items = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _offset = 0;
  String _type = 'all';
  String _search = '';
  static const _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  Future<void> _fetch({bool reset = false}) async {
    if (reset) { setState(() { _loading = true; _offset = 0; }); }
    else { setState(() => _loadingMore = true); }
    try {
      final api = ApiClient.instance;
      final typeP = _type != 'all' ? '&type=$_type' : '';
      final qP = _search.isNotEmpty ? '&q=${Uri.encodeComponent(_search)}' : '';
      final data = await api.get('/lostfound?limit=$_limit&offset=${reset ? 0 : _offset}$typeP$qP');
      final items = (data['items'] as List? ?? []).map((e) => LostFoundItem.fromJson(e)).toList();
      setState(() {
        if (reset) { _items = items; } else { _items.addAll(items); }
        _hasMore = data['hasMore'] == true;
        _offset = (reset ? 0 : _offset) + items.length;
      });
    } catch (_) {}
    setState(() { _loading = false; _loadingMore = false; });
  }

  void _onTypeChanged(String t) { _type = t; _fetch(reset: true); }

  void _onSearchChanged(String q) {
    _search = q;
    Future.delayed(const Duration(milliseconds: 400), () {
      if (_search == q) _fetch(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final typeColors = {'lost': Colors.red, 'found': Colors.green};
    return Scaffold(
      appBar: AppBar(title: const Text('Lost & Found')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/lostfound/report'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => _fetch(reset: true),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _searchController, onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search lost/found items...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), isDense: true,
              ),
            ),
            const SizedBox(height: 12),

            CategoryFilter(
              items: lostFoundTypeFilters.cast<Map<String, String>>(),
              selected: _type, onSelected: _onTypeChanged,
              colorMap: typeColors.map((k, v) => MapEntry(k, v)),
            ),
            const SizedBox(height: 16),

            if (_loading)
              ...[for (int i = 0; i < 4; i++) ...[
                AppShimmer(width: double.infinity, height: 200), const SizedBox(height: 12),
              ]]
            else if (_items.isEmpty)
              Center(child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(children: [
                  Icon(Icons.search_off, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text('No items reported', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: () => context.push('/lostfound/report'), child: const Text('Report an Item')),
                ]),
              ))
            else ...[
              GridView.builder(
                shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.7),
                itemCount: _items.length,
                itemBuilder: (_, i) => LostFoundCard(
                  item: _items[i], onTap: () => context.push('/lostfound/${_items[i].id}')),
              ),
              if (_hasMore) Center(child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _loadingMore ? const CircularProgressIndicator()
                    : TextButton.icon(onPressed: () => _fetch(), icon: const Icon(Icons.expand_more), label: const Text('Load More')),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
