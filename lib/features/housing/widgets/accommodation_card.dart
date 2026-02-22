import 'package:flutter/material.dart';
import '../models/accommodation_model.dart';

class AccommodationCard extends StatelessWidget {
  final Accommodation item;
  final VoidCallback? onTap;
  const AccommodationCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: item.images.isNotEmpty
                  ? Image.network(item.images.first, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(theme))
                  : _placeholder(theme),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(item.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      _typeBadge(theme),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item.priceDisplay, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      const SizedBox(width: 4),
                      Text(item.rating.toStringAsFixed(1), style: theme.textTheme.bodySmall),
                      const Spacer(),
                      Icon(Icons.location_on, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                      const SizedBox(width: 2),
                      Flexible(child: Text(item.location, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5)), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeBadge(ThemeData theme) {
    final color = switch (item.type) {
      'PG' => Colors.blue,
      'Hostel' => Colors.orange,
      'Apartment' => Colors.purple,
      _ => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
      child: Text(item.type, style: theme.textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }

  Widget _placeholder(ThemeData theme) => Container(
    color: theme.colorScheme.surfaceContainerHighest,
    child: Center(child: Icon(Icons.apartment, size: 40, color: theme.colorScheme.onSurface.withValues(alpha: 0.3))),
  );
}
