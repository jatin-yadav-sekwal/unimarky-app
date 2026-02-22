import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unimarky/core/network/api_client.dart';
import '../models/accommodation_model.dart';

class AccommodationDetailScreen extends StatefulWidget {
  final String itemId;
  const AccommodationDetailScreen({super.key, required this.itemId});

  @override
  State<AccommodationDetailScreen> createState() => _AccommodationDetailScreenState();
}

class _AccommodationDetailScreenState extends State<AccommodationDetailScreen> {
  Accommodation? _item;
  bool _isLoading = true;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.get('/accommodation/${widget.itemId}');
      setState(() {
        _item = Accommodation.fromJson(data);
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
    if (_item == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('Accommodation not found')));
    }
    final a = _item!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(a.name, style: const TextStyle(shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
              background: a.images.isNotEmpty
                  ? _ImageCarousel(images: a.images, currentIndex: _currentImageIndex, onIndexChanged: (i) => setState(() => _currentImageIndex = i))
                  : Container(color: theme.colorScheme.surfaceContainerHighest, child: const Center(child: Icon(Icons.apartment, size: 64))),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type & Price
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(16)),
                        child: Text(a.type, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      Text(a.priceDisplay, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Icon(Icons.star, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 4),
                      Text(a.rating.toStringAsFixed(1), style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (a.description != null) ...[
                    Text(a.description!, style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                  ],
                  // Amenities
                  if (a.amenitiesList.isNotEmpty) ...[
                    Text('Amenities', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: a.amenitiesList.map((am) => Chip(
                        label: Text(am, style: theme.textTheme.labelSmall),
                        avatar: const Icon(Icons.check_circle, size: 16),
                        visualDensity: VisualDensity.compact,
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Contact Info
                  Text('Contact Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (a.address != null) _infoRow(Icons.location_on, a.address!, theme),
                  if (a.phone != null) _contactRow(Icons.phone, a.phone!, theme),
                  if (a.contact != null) _contactRow(Icons.contact_phone, a.contact!, theme),
                  _infoRow(Icons.map, a.location, theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, ThemeData theme) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Icon(icon, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
      const SizedBox(width: 10),
      Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
    ]),
  );

  Widget _contactRow(IconData icon, String text, ThemeData theme) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied: $text')));
      },
      child: Row(children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(text, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary)),
        const SizedBox(width: 6),
        Icon(Icons.content_copy, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
      ]),
    ),
  );
}

class _ImageCarousel extends StatelessWidget {
  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  const _ImageCarousel({required this.images, required this.currentIndex, required this.onIndexChanged});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: onIndexChanged,
          itemBuilder: (_, i) => Image.network(images[i], fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300)),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 48,
            left: 0, right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) => Container(
                width: 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i == currentIndex ? Colors.white : Colors.white.withValues(alpha: 0.4),
                ),
              )),
            ),
          ),
      ],
    );
  }
}
