import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/unimedia/models/post_model.dart';
import 'package:unimarky/features/unimedia/widgets/post_card.dart';
import 'package:unimarky/features/unimedia/widgets/create_post_sheet.dart';

class UnimediaScreen extends StatefulWidget {
  const UnimediaScreen({super.key});
  @override
  State<UnimediaScreen> createState() => _UnimediaScreenState();
}

class _UnimediaScreenState extends State<UnimediaScreen> {
  List<Post> _posts = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _offset = 0;
  String _type = 'all';
  static const _limit = 20;

  @override
  void initState() { super.initState(); _fetch(reset: true); }

  Future<void> _fetch({bool reset = false}) async {
    if (reset) { setState(() { _loading = true; _offset = 0; }); }
    else { setState(() => _loadingMore = true); }
    try {
      final typeP = _type != 'all' ? '&type=$_type' : '';
      final data = await ApiClient.instance.get('/social?limit=$_limit&offset=${reset ? 0 : _offset}$typeP');
      final posts = (data['items'] as List? ?? []).map((e) => Post.fromJson(e)).toList();
      setState(() {
        if (reset) { _posts = posts; } else { _posts.addAll(posts); }
        _hasMore = data['hasMore'] == true;
        _offset = (reset ? 0 : _offset) + posts.length;
      });
    } catch (_) {}
    setState(() { _loading = false; _loadingMore = false; });
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    setState(() { post.isLiked = !post.isLiked; post.likesCount += post.isLiked ? 1 : -1; });
    try { await ApiClient.instance.post('/social/${post.id}/like'); }
    catch (_) { setState(() { post.isLiked = !post.isLiked; post.likesCount += post.isLiked ? 1 : -1; }); }
  }

  Future<void> _deletePost(int index) async {
    final post = _posts[index];
    final confirmed = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Post?'),
      content: const Text('This cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (confirmed != true) return;
    try {
      await ApiClient.instance.delete('/social/${post.id}');
      setState(() => _posts.removeAt(index));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => CreatePostSheet(onCreated: () => _fetch(reset: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unimedia')),
      floatingActionButton: FloatingActionButton(onPressed: _openCreateSheet, child: const Icon(Icons.edit)),
      body: RefreshIndicator(
        onRefresh: () => _fetch(reset: true),
        child: ListView(padding: const EdgeInsets.all(16), children: [
          // Tab filters
          SizedBox(
            height: 38,
            child: ListView(scrollDirection: Axis.horizontal, children: feedTabs.map((tab) {
              final id = tab['id']!;
              final isActive = id == _type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(label: Text(tab['label']!), selected: isActive,
                  onSelected: (_) { _type = id; _fetch(reset: true); }),
              );
            }).toList()),
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()))
          else if (_posts.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(children: [
                Icon(Icons.feed_outlined, size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                const SizedBox(height: 16),
                Text('No posts yet', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                FilledButton(onPressed: _openCreateSheet, child: const Text('Create First Post')),
              ]),
            ))
          else ...[
            ...List.generate(_posts.length, (i) => PostCard(
              post: _posts[i],
              onTap: () => context.push('/unimedia/${_posts[i].id}'),
              onLike: () => _toggleLike(i),
              onDelete: () => _deletePost(i),
            )),
            if (_hasMore)
              Center(child: _loadingMore
                ? const CircularProgressIndicator()
                : TextButton.icon(onPressed: () => _fetch(), icon: const Icon(Icons.expand_more), label: const Text('Load More'))),
          ],
        ]),
      ),
    );
  }
}
