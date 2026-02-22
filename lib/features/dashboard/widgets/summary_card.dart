import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Summary card showing recent items — mirrors web's SummaryCard.
class SummaryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String href;
  final List<Map<String, dynamic>> items;
  final String? secondaryHref;
  final String? secondaryLabel;

  const SummaryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.href,
    this.items = const [],
    this.secondaryHref,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items list
            if (items.isEmpty)
              Text('No items yet',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
                  ))
            else
              ...items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: iconColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (item['title'] ?? item['itemName'] ?? item['content'] ?? '') as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  )),

            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => context.go(href),
                  child: Text('View All',
                      style: TextStyle(color: iconColor, fontSize: 13)),
                ),
                if (secondaryHref != null && secondaryLabel != null)
                  TextButton(
                    onPressed: () => context.go(secondaryHref!),
                    child: Text(secondaryLabel!,
                        style: TextStyle(color: iconColor, fontSize: 13)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
