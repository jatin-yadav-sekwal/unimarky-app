import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/auth/providers/auth_provider.dart';

class RequestRoleScreen extends ConsumerStatefulWidget {
  const RequestRoleScreen({super.key});

  @override
  ConsumerState<RequestRoleScreen> createState() => _RequestRoleScreenState();
}

class _RequestRoleScreenState extends ConsumerState<RequestRoleScreen> {
  final _reasonCtrl = TextEditingController();
  List<dynamic> _myRequests = [];
  bool _isLoading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    try {
      final data = await ApiClient.instance.get('/role-requests/mine');
      setState(() {
        _myRequests = data is List ? data : [];
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _submitRequest() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reason must be at least 10 characters'), backgroundColor: Colors.orange));
      return;
    }
    setState(() => _submitting = true);
    try {
      await ApiClient.instance.post('/role-requests', data: {'reason': reason});
      _reasonCtrl.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request submitted!'), backgroundColor: Colors.green));
      }
      _loadRequests();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) { setState(() => _submitting = false); }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final role = authState.role;

    return Scaffold(
      appBar: AppBar(title: const Text('Role Upgrade')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current role
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.badge, color: theme.colorScheme.primary, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Current Role', style: theme.textTheme.labelMedium),
                              Text(role.toString().toUpperCase(), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (role == 'superuser' || role == 'userX') ...[
                    Card(
                      color: Colors.green.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 12),
                            Text('You already have elevated privileges!'),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Submit form
                    Text('Request Superuser Role', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Superusers can manage food listings, accommodations, and study materials.', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reasonCtrl,
                      decoration: const InputDecoration(labelText: 'Why do you want superuser access?', border: OutlineInputBorder(), hintText: 'Min 10 characters'),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _submitting ? null : _submitRequest,
                      child: _submitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Submit Request'),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // My requests
                  if (_myRequests.isNotEmpty) ...[
                    Text('My Requests', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._myRequests.map((req) => Card(
                      child: ListTile(
                        leading: _statusIcon(req['status']),
                        title: Text(req['reason'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text('Status: ${req['status']}'),
                        trailing: Text(_formatDate(req['createdAt']), style: theme.textTheme.labelSmall),
                      ),
                    )),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _statusIcon(String? status) => Icon(
    switch (status) {
      'approved' => Icons.check_circle,
      'rejected' => Icons.cancel,
      _ => Icons.hourglass_empty,
    },
    color: switch (status) {
      'approved' => Colors.green,
      'rejected' => Colors.red,
      _ => Colors.orange,
    },
  );

  String _formatDate(String? date) {
    if (date == null) { return ''; }
    final d = DateTime.tryParse(date);
    if (d == null) { return date; }
    return '${d.day}/${d.month}/${d.year}';
  }
}
