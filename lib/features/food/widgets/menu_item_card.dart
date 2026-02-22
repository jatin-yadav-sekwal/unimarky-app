import 'package:flutter/material.dart';
import '../models/food_models.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;
  const MenuItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: item.isVeg ? Colors.green : Colors.red,
          border: Border.all(color: item.isVeg ? Colors.green.shade700 : Colors.red.shade700, width: 1.5),
        ),
      ),
      title: Row(
        children: [
          Expanded(child: Text(item.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500))),
          Text('₹${item.price.toStringAsFixed(0)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.description != null) ...[
            const SizedBox(height: 2),
            Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
          ],
          if (!item.isAvailable) ...[
            const SizedBox(height: 4),
            Text('Currently Unavailable', style: theme.textTheme.labelSmall?.copyWith(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
