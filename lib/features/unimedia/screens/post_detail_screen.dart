import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/unimedia/models/post_model.dart';
import 'package:unimarky/features/unimedia/widgets/comment_section.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _loading = true;
  String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await ApiClient.instance.get('/social/${widget.postId}');
      setState(() { _post = Post.fromJson(data); _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;
    setState(() { _post!.isLiked = !_post!.isLiked; _post!.likesCount += _post!.isLiked ? 1 : -1; });
    try { await ApiClient.instance.post('/social/${_post!.id}/like'); }
    catch (_) { setState(() { _post!.isLiked = !_post!.isLiked; _post!.likesCount += _post!.isLiked ? 1 : -1; }); }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) return Scaffold(appBar: AppBar(), body: const Center(child: CircularProgressIndicator()));
    if (_error != null || _post == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.error_outline, size: 48), const SizedBox(height: 12),
        Text(_error ?? 'Post not found'), const SizedBox(height: 12),
        FilledButton(onPressed: () => context.pop(), child: const Text('Go Back')),
      ])));
    }

    final post = _post!;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Author
          Row(children: [
            CircleAvatar(child: Text(post.author.fullName.isNotEmpty ? post.author.fullName[0].toUpperCase() : '?')),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(post.author.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text(_timeAgo(post.createdAt), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant)),
            ]),
          ]),
          const SizedBox(height: 16),

          if (post.title != null) ...[
            Text(post.title!, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
          ],

          Text(post.content, style: theme.textTheme.bodyLarge),

          if (post.type == 'event' && post.eventDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                Icon(Icons.event, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(post.eventDate!, style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  if (post.hostedBy != null) Text('Hosted by ${post.hostedBy}', style: TextStyle(fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant)),
                ]),
              ]),
            ),
          ],

          if (post.imageUrl != null) ...[
            const SizedBox(height: 16),
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.network(post.imageUrl!, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink())),
          ],

          const SizedBox(height: 12),

          // Like / Stats
          Row(children: [
            IconButton(
              onPressed: _toggleLike,
              icon: Icon(post.isLiked ? Icons.favorite : Icons.favorite_border,
                color: post.isLiked ? Colors.red : null)),
            Text('${post.likesCount} likes'),
            const SizedBox(width: 16),
            const Icon(Icons.comment_outlined, size: 20),
            const SizedBox(width: 4),
            Text('${post.commentsCount} comments'),
          ]),

          const Divider(height: 32),

          // Comments
          CommentSection(postId: post.id),
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
