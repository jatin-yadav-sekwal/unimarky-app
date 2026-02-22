import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unimarky/core/network/api_client.dart';
import '../models/food_models.dart';
import '../widgets/menu_item_card.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  Restaurant? _restaurant;
  List<MenuItem> _menuItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.get('/food/${widget.restaurantId}');
      final menuData = await ApiClient.instance.get('/food/menu?restaurantId=${widget.restaurantId}');
      final menuList = (menuData is List ? menuData : (menuData as Map)['items'] ?? menuData) as List;
      setState(() {
        _restaurant = Restaurant.fromJson(data);
        _menuItems = menuList.map((e) => MenuItem.fromJson(e)).toList();
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
    if (_isLoading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (_restaurant == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Restaurant not found')));
    }
    final r = _restaurant!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(r.name, style: const TextStyle(shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
              background: r.imageUrl != null
                  ? Image.network(r.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surfaceContainerHighest))
                  : Container(color: theme.colorScheme.surfaceContainerHighest, child: const Center(child: Icon(Icons.restaurant, size: 64))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Row
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 4),
                      Text('${r.rating.toStringAsFixed(1)} (${r.reviewCount} reviews)', style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      if (r.priceRange != null) Text(r.priceRange!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (r.cuisine != null) ...[
                    Text('Cuisine: ${r.cuisine!}', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 6),
                  ],
                  if (r.timing != null) ...[
                    Row(children: [
                      const Icon(Icons.access_time, size: 16),
                      const SizedBox(width: 6),
                      Text(r.timing!, style: theme.textTheme.bodyMedium),
                    ]),
                    const SizedBox(height: 6),
                  ],
                  if (r.address != null) ...[
                    Row(children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 6),
                      Expanded(child: Text(r.address!, style: theme.textTheme.bodyMedium)),
                    ]),
                    const SizedBox(height: 6),
                  ],
                  if (r.phone != null)
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: r.phone!));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone copied to clipboard')));
                      },
                      child: Row(children: [
                        const Icon(Icons.phone, size: 16),
                        const SizedBox(width: 6),
                        Text(r.phone!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
                      ]),
                    ),
                  const Divider(height: 32),
                  Text('Menu', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          if (_menuItems.isEmpty)
            const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No menu items available'))))
          else
            ..._buildMenuSections(theme),
        ],
      ),
    );
  }

  List<Widget> _buildMenuSections(ThemeData theme) {
    final grouped = <String, List<MenuItem>>{};
    for (final item in _menuItems) {
      final cat = item.category ?? 'Other';
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    final widgets = <Widget>[];
    for (final entry in grouped.entries) {
      widgets.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Text(entry.key, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
        ),
      ));
      widgets.add(SliverList(delegate: SliverChildBuilderDelegate(
        (_, i) => MenuItemCard(item: entry.value[i]),
        childCount: entry.value.length,
      )));
    }
    return widgets;
  }
}
