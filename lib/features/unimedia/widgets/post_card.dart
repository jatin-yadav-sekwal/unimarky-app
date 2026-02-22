import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/features/unimedia/models/post_model.dart';

/// Social post card with like/comment/share actions
class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback? onDelete;

  const PostCard({super.key, required this.post, required this.onTap, required this.onLike, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isAuthor = currentUserId == post.authorId;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header: Author + type + menu
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(children: [
              CircleAvatar(radius: 18,
                child: Text(post.author.fullName.isNotEmpty ? post.author.fullName[0].toUpperCase() : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(post.author.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  if (post.author.role != 'normal') ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(6)),
                      child: Text(post.author.role.toUpperCase(),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer)),
                    ),
                  ],
                ]),
                Text(_timeAgo(post.createdAt), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
              ])),
              // Type chip
              _TypeChip(type: post.type),
              if (isAuthor && onDelete != null)
                IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: onDelete,
                  color: theme.colorScheme.error, iconSize: 18),
            ]),
          ),

          // Title (for events/announcements)
          if (post.title != null)
            Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(post.title!, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),

          // Content
          Padding(padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Text(post.content, maxLines: 4, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)),

          // Event info
          if (post.type == 'event' && post.eventDate != null)
            Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Row(children: [
                Icon(Icons.event, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text(post.eventDate!, style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
                if (post.hostedBy != null) ...[
                  const SizedBox(width: 12),
                  Icon(Icons.person, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(post.hostedBy!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
                ],
              ])),

          // Image
          if (post.imageUrl != null)
            ClipRRect(
              child: Image.network(post.imageUrl!, width: double.infinity, height: 200, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink())),

          // Actions
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            child: Row(children: [
              TextButton.icon(
                onPressed: onLike,
                icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: post.isLiked ? Colors.red : null, size: 18),
                label: Text('${post.likesCount}', style: const TextStyle(fontSize: 13)),
              ),
              TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.comment_outlined, size: 18),
                label: Text('${post.commentsCount}', style: const TextStyle(fontSize: 13)),
              ),
              const Spacer(),
              IconButton(icon: const Icon(Icons.share_outlined, size: 18), onPressed: () {}),
            ]),
          ),
        ]),
      ),
    );
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) { return dateStr; }
  }
}

class _TypeChip extends StatelessWidget {
  final String type;
  const _TypeChip({required this.type});
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'event' => ('Event', Colors.purple),
      'announcement' => ('News', Colors.orange),
      _ => ('Post', Colors.blue),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
