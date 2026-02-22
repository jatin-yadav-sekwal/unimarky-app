import 'package:flutter/material.dart';
import 'package:unimarky/features/lostfound/models/lostfound_item.dart';

/// Lost & Found item card with type badge
class LostFoundCard extends StatelessWidget {
  final LostFoundItem item;
  final VoidCallback onTap;

  const LostFoundCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLost = item.type == 'lost';
    final badgeColor = isLost ? Colors.red : Colors.green;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with type badge
            Stack(children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: item.imageUrl != null
                    ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _placeholder(theme))
                    : _placeholder(theme),
              ),
              Positioned(top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(isLost ? 'LOST' : 'FOUND',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.itemName, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  if (item.location != null) ...[
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.location_on, size: 14, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(child: Text(item.location!, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant))),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Center(child: Icon(Icons.search_off, size: 40,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3))),
  );
}
