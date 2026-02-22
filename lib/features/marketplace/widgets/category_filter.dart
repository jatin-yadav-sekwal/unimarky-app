import 'package:flutter/material.dart';

/// Horizontal scrollable filter pills — used for category/type filtering
class CategoryFilter extends StatelessWidget {
  final List<Map<String, String>> items;
  final String selected;
  final ValueChanged<String> onSelected;
  final Map<String, Color>? colorMap;

  const CategoryFilter({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.colorMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final value = item['value']!;
          final isActive = value == selected;
          final color = colorMap?[value] ?? theme.colorScheme.primary;

          return FilterChip(
            label: Text(item['label']!),
            selected: isActive,
            onSelected: (_) => onSelected(value),
            selectedColor: color.withValues(alpha: 0.15),
            checkmarkColor: color,
            labelStyle: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? color : theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
            side: BorderSide(
              color: isActive ? color : theme.colorScheme.outlineVariant,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }
}
