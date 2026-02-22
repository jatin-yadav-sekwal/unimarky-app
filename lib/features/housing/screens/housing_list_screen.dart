import 'package:flutter/material.dart';
import 'package:unimarky/core/network/api_client.dart';
import '../models/accommodation_model.dart';
import '../widgets/accommodation_card.dart';
import 'package:go_router/go_router.dart';

class HousingListScreen extends StatefulWidget {
  const HousingListScreen({super.key});

  @override
  State<HousingListScreen> createState() => _HousingListScreenState();
}

class _HousingListScreenState extends State<HousingListScreen> {
  final _scrollController = ScrollController();
  List<Accommodation> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _offset = 0;
  String _selectedType = 'All';
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
      final typeP = _selectedType != 'All' ? '&type=$_selectedType' : '';
      final data = await ApiClient.instance.get('/accommodation?limit=$_limit&offset=${reset ? 0 : _offset}$typeP');
      final items = (data['items'] as List? ?? []).map((e) => Accommodation.fromJson(e)).toList();
      setState(() {
        if (reset) { _items = items; } else { _items.addAll(items); }
        _hasMore = data['hasMore'] == true;
        _offset = (reset ? 0 : _offset) + items.length;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() => _isLoading = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Type filter
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            itemCount: accommodationTypes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final type = accommodationTypes[i];
              final selected = type == _selectedType;
              return FilterChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) {
                  setState(() => _selectedType = type);
                  _loadItems(reset: true);
                },
                selectedColor: theme.colorScheme.primaryContainer,
              );
            },
          ),
        ),
        Expanded(
          child: _isLoading && _items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.apartment, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      Text('No accommodations found', style: theme.textTheme.titleMedium),
                    ]))
                  : RefreshIndicator(
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
                            child: AccommodationCard(item: _items[index], onTap: () => context.push('/housing/${_items[index].id}')),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
