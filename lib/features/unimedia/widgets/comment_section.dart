import 'package:flutter/material.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/unimedia/models/post_model.dart';

/// Expandable comment list + add comment for a post
class CommentSection extends StatefulWidget {
  final String postId;
  const CommentSection({super.key, required this.postId});
  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _controller = TextEditingController();
  List<Comment> _comments = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() { super.initState(); _loadComments(); }

  Future<void> _loadComments() async {
    try {
      final data = await ApiClient.instance.get('/social/${widget.postId}/comments');
      final list = (data as List? ?? []).map((e) => Comment.fromJson(e)).toList();
      if (mounted) setState(() { _comments = list; _loading = false; });
    } catch (_) { if (mounted) setState(() => _loading = false); }
  }

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ApiClient.instance.post('/social/${widget.postId}/comments', data: {'content': text});
      _controller.clear();
      await _loadComments();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Comments', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),

      // Add comment
      Row(children: [
        Expanded(child: TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Write a comment...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), isDense: true),
        )),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _sending ? null : _addComment,
          icon: _sending ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.send, size: 18),
        ),
      ]),
      const SizedBox(height: 12),

      if (_loading)
        const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
      else if (_comments.isEmpty)
        Padding(padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(child: Text('No comments yet', style: TextStyle(color: theme.colorScheme.onSurfaceVariant))))
      else
        ...List.generate(_comments.length, (i) {
          final c = _comments[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(radius: 14,
                child: Text(c.user.fullName.isNotEmpty ? c.user.fullName[0] : '?', style: const TextStyle(fontSize: 12))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(c.user.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 8),
                  Text(_timeAgo(c.createdAt), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurfaceVariant)),
                ]),
                const SizedBox(height: 2),
                Text(c.content, style: theme.textTheme.bodyMedium),
              ])),
            ]),
          );
        }),
    ]);
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'now';
      if (diff.inHours < 1) return '${diff.inMinutes}m';
      if (diff.inDays < 1) return '${diff.inHours}h';
      return '${diff.inDays}d';
    } catch (_) { return ''; }
  }
}
