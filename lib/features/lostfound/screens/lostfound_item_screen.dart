import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/lostfound/models/lostfound_item.dart';

class LostFoundItemScreen extends StatefulWidget {
  final String itemId;
  const LostFoundItemScreen({super.key, required this.itemId});
  @override
  State<LostFoundItemScreen> createState() => _LostFoundItemScreenState();
}

class _LostFoundItemScreenState extends State<LostFoundItemScreen> {
  LostFoundItemDetail? _item;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.get('/lostfound/${widget.itemId}');
      setState(() { _item = LostFoundItemDetail.fromJson(data); _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_error != null || _item == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12),
        Text(_error ?? 'Item not found'), const SizedBox(height: 12),
        FilledButton(onPressed: () => context.pop(), child: const Text('Go Back')),
      ])));
    }

    final item = _item!;
    final isLost = item.type == 'lost';
    final badgeColor = isLost ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(icon: const Icon(Icons.share),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: '${isLost ? "Lost" : "Found"}: "${item.itemName}" on UniMARKY!'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied!')));
          }),
      ]),
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (item.imageUrl != null)
            AspectRatio(aspectRatio: 4 / 3,
              child: Image.network(item.imageUrl!, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.image_not_supported, size: 48))))),
          Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Type badge + Status
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                child: Text(isLost ? 'LOST' : 'FOUND',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                child: Text(item.status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSecondaryContainer)),
              ),
            ]),
            const SizedBox(height: 12),
            Text(item.itemName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(item.description, style: theme.textTheme.bodyLarge),
            if (item.location != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.location_on, size: 18, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(item.location!, style: theme.textTheme.bodyMedium),
              ]),
            ],
            const Divider(height: 32),
            Text('Reported By', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: CircleAvatar(child: Text(item.reporter.fullName.isNotEmpty ? item.reporter.fullName[0] : '?')),
              title: Text(item.reporter.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: item.reporter.department != null ? Text(item.reporter.department!) : null,
              contentPadding: EdgeInsets.zero,
            ),
            if (item.reporter.mobileNumber != null) ...[
              const SizedBox(height: 12),
              SizedBox(width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item.reporter.mobileNumber!));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied ${item.reporter.mobileNumber}')));
                  },
                  icon: const Icon(Icons.phone), label: Text('Call ${item.reporter.mobileNumber}'),
                )),
            ],
          ])),
        ]),
      ),
    );
  }
}
