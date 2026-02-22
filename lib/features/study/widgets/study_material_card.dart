import 'package:flutter/material.dart';
import '../models/study_models.dart';

class StudyMaterialCard extends StatelessWidget {
  final StudyMaterial material;
  final VoidCallback? onTap;
  const StudyMaterialCard({super.key, required this.material, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = categoryLabels[material.category] ?? material.category;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon(material.category), color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(material.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(material.subjectName, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: theme.colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(8)),
                            child: Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSecondaryContainer), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (material.uploaderName != null)
                          Flexible(
                            child: Text('by ${material.uploaderName}', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.4)), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String cat) => switch (cat) {
    'previous_year_papers' => Icons.history_edu,
    'notes' => Icons.note_alt,
    'sessional_exams' => Icons.quiz,
    'assignments' => Icons.assignment,
    'syllabus' => Icons.list_alt,
    'reference_books' => Icons.menu_book,
    _ => Icons.description,
  };
}
