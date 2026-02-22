import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/marketplace/models/marketplace_item.dart';

class MarketplaceItemScreen extends StatefulWidget {
  final String itemId;
  const MarketplaceItemScreen({super.key, required this.itemId});
  @override
  State<MarketplaceItemScreen> createState() => _MarketplaceItemScreenState();
}

class _MarketplaceItemScreenState extends State<MarketplaceItemScreen> {
  MarketplaceItemDetail? _item;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.get('/marketplace/${widget.itemId}');
      setState(() { _item = MarketplaceItemDetail.fromJson(data); _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12),
          Text(_error ?? 'Item not found'), const SizedBox(height: 12),
          FilledButton(onPressed: () => context.pop(), child: const Text('Go Back')),
        ])),
      );
    }

    final item = _item!;
    final condLabel = conditionLabels[item.condition] ?? 'Used';

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: 'Check out "${item.title}" on UniMARKY!'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!')));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (item.imageUrl != null)
              AspectRatio(aspectRatio: 4 / 3,
                child: Image.network(item.imageUrl!, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: Icon(Icons.image_not_supported, size: 48))))),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Condition
                  Row(children: [
                    _Chip(label: item.category, color: theme.colorScheme.secondaryContainer,
                      textColor: theme.colorScheme.onSecondaryContainer),
                    const SizedBox(width: 8),
                    _Chip(label: condLabel, color: theme.colorScheme.tertiaryContainer,
                      textColor: theme.colorScheme.onTertiaryContainer),
                  ]),
                  const SizedBox(height: 12),

                  // Title
                  Text(item.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  // Price
                  Row(children: [
                    Text('₹${item.price}', style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                    if (item.isNegotiable)
                      Padding(padding: const EdgeInsets.only(left: 8),
                        child: Text('Negotiable', style: TextStyle(color: theme.colorScheme.tertiary, fontSize: 14))),
                  ]),
                  const SizedBox(height: 16),

                  // Description
                  Text(item.description, style: theme.textTheme.bodyLarge),

                  if (item.manufacturedYear != null) ...[
                    const SizedBox(height: 12),
                    Row(children: [
                      Icon(Icons.calendar_today, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('Year: ${item.manufacturedYear}', style: theme.textTheme.bodyMedium),
                    ]),
                  ],

                  const Divider(height: 32),

                  // Seller Info
                  Text('Seller', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: CircleAvatar(child: Text(item.seller.fullName.isNotEmpty ? item.seller.fullName[0] : '?')),
                    title: Row(children: [
                      Text(item.seller.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                      if (item.seller.isVerified) const Padding(padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified, size: 16, color: Colors.blue)),
                    ]),
                    subtitle: item.seller.department != null ? Text(item.seller.department!) : null,
                    contentPadding: EdgeInsets.zero,
                  ),

                  // Contact
                  if (item.seller.mobileNumber != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item.seller.mobileNumber!));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${item.seller.mobileNumber}')));
                        },
                        icon: const Icon(Icons.phone),
                        label: Text('Call ${item.seller.mobileNumber}'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label; final Color color; final Color textColor;
  const _Chip({required this.label, required this.color, required this.textColor});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor)),
  );
}
