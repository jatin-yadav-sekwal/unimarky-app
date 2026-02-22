import 'package:flutter/material.dart';
import 'package:unimarky/core/network/api_client.dart';
import '../models/food_models.dart';
import '../widgets/restaurant_card.dart';
import 'package:go_router/go_router.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({super.key});

  @override
  State<FoodListScreen> createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  final _scrollController = ScrollController();
  List<Restaurant> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  static const _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadItems(reset: true);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
        _loadItems();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadItems({bool reset = false}) async {
    if (_isLoading) { return; }
    setState(() => _isLoading = true);
    try {
      final data = await ApiClient.instance.get('/food?limit=$_limit&offset=${reset ? 0 : _offset}');
      final items = (data['items'] as List? ?? []).map((e) => Restaurant.fromJson(e)).toList();
      setState(() {
        if (reset) { _items = items; } else { _items.addAll(items); }
        _hasMore = data['hasMore'] == true;
        _offset = (reset ? 0 : _offset) + items.length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load restaurants: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() => _isLoading = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text('No restaurants found', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadItems(reset: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _items.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _items.length) {
            return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RestaurantCard(restaurant: _items[index], onTap: () => context.push('/food/${_items[index].id}')),
          );
        },
      ),
    );
  }
}
