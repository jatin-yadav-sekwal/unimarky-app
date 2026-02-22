import 'package:flutter/material.dart';
import 'package:unimarky/core/network/api_client.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  List<dynamic> _pendingRequests = [];
  List<dynamic> _reviewedRequests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadRequests();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    try {
      final pending = await ApiClient.instance.get('/role-requests?status=pending');
      final approved = await ApiClient.instance.get('/role-requests?status=approved');
      final rejected = await ApiClient.instance.get('/role-requests?status=rejected');
      setState(() {
        _pendingRequests = pending is List ? pending : [];
        _reviewedRequests = [...(approved is List ? approved : []), ...(rejected is List ? rejected : [])];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _handleAction(String requestId, String action) async {
    try {
      await ApiClient.instance.patch('/role-requests/$requestId', data: {'status': action});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request $action'), backgroundColor: Colors.green));
      _loadRequests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(controller: _tabCtrl, tabs: const [
          Tab(text: 'Pending'),
          Tab(text: 'Reviewed'),
        ]),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(controller: _tabCtrl, children: [
              // Pending
              _pendingRequests.isEmpty
                  ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.inbox, size: 64, color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      Text('No pending requests', style: theme.textTheme.titleMedium),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _loadRequests,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _pendingRequests.length,
                        itemBuilder: (_, i) => _buildPendingCard(_pendingRequests[i], theme),
                      ),
                    ),
              // Reviewed
              _reviewedRequests.isEmpty
                  ? Center(child: Text('No reviewed requests', style: theme.textTheme.titleMedium))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _reviewedRequests.length,
                      itemBuilder: (_, i) => _buildReviewedCard(_reviewedRequests[i], theme),
                    ),
            ]),
    );
  }

  Widget _buildPendingCard(dynamic req, ThemeData theme) {
    final request = req['request'] ?? req;
    final user = req['user'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user != null) ...[
              Text(user['fullName'] ?? 'Unknown', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${user['department'] ?? ''} • ${user['universityName'] ?? ''}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
            ],
            Text(request['reason'] ?? '', style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _handleAction(request['id'], 'rejected'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => _handleAction(request['id'], 'approved'),
                  child: const Text('Approve'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewedCard(dynamic req, ThemeData theme) {
    final request = req['request'] ?? req;
    final user = req['user'];
    final status = request['status'] ?? '';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          status == 'approved' ? Icons.check_circle : Icons.cancel,
          color: status == 'approved' ? Colors.green : Colors.red,
        ),
        title: Text(user?['fullName'] ?? 'Unknown'),
        subtitle: Text(request['reason'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: Text(status.toString().toUpperCase(), style: theme.textTheme.labelSmall?.copyWith(
          color: status == 'approved' ? Colors.green : Colors.red,
          fontWeight: FontWeight.w600,
        )),
      ),
    );
  }
}
