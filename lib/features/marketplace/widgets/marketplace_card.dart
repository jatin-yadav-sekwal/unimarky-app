import 'package:flutter/material.dart';
import 'package:unimarky/features/marketplace/models/marketplace_item.dart';

/// Marketplace item card for list view
class MarketplaceCard extends StatelessWidget {
  final MarketplaceItem item;
  final VoidCallback onTap;

  const MarketplaceCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final condLabel = conditionLabels[item.condition] ?? 'Used';

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
            // Image
            AspectRatio(
              aspectRatio: 4 / 3,
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(theme))
                  : _placeholder(theme),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('₹${item.price}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800, color: theme.colorScheme.primary)),
                      if (item.isNegotiable) ...[
                        const SizedBox(width: 6),
                        Text('Negotiable', style: TextStyle(fontSize: 10, color: theme.colorScheme.tertiary)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(condLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer)),
                  ),
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
    child: Center(child: Icon(Icons.shopping_bag_outlined, size: 40,
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3))),
  );
}
