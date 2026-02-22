import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/network/api_client.dart';
import '../../marketplace/models/marketplace_item.dart';
import '../../lostfound/models/lost_found_item.dart';

class PublicProfileScreen extends StatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  State<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends State<PublicProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _profile;
  List<MarketplaceItem> _marketplaceItems = [];
  List<LostFoundItem> _lostFoundItems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchProfileData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfileData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profileResponse = await ApiClient.instance.get('/profiles/${widget.userId}');
      if (profileResponse.data != null) {
        _profile = profileResponse.data as Map<String, dynamic>;
      } else {
        throw Exception('Profile not found');
      }

      final marketplaceResponse = await ApiClient.instance.get('/marketplace?userId=${widget.userId}&limit=50');
      if (marketplaceResponse.data != null && marketplaceResponse.data['items'] != null) {
        _marketplaceItems = (marketplaceResponse.data['items'] as List)
            .map((json) => MarketplaceItem.fromJson(json))
            .toList();
      }

      final lostFoundResponse = await ApiClient.instance.get('/lost-found?userId=${widget.userId}&limit=50');
      if (lostFoundResponse.data != null && lostFoundResponse.data['items'] != null) {
        _lostFoundItems = (lostFoundResponse.data['items'] as List)
            .map((json) => LostFoundItem.fromJson(json))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error ?? 'Could not load profile', style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchProfileData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final String joinedDate = _profile!['createdAt'] != null
        ? DateFormat('MMMM yyyy').format(DateTime.parse(_profile!['createdAt']))
        : 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: Text(_profile!['fullName'] ?? 'User Profile'),
      ),
      body: Column(
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24.0),
            width: double.infinity,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  child: Text(
                    (_profile!['fullName'] as String?)?.isNotEmpty == true
                        ? (_profile!['fullName'] as String).substring(0, 1).toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _profile!['fullName'] ?? 'Anonymous',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (_profile!['isVerified'] == true) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 20),
                    ]
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Joined $joinedDate',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (_profile!['department'] != null && _profile!['department'].toString().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _profile!['department'],
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Marketplace'),
              Tab(text: 'Lost & Found'),
            ],
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMarketplaceTab(),
                _buildLostFoundTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab() {
    if (_marketplaceItems.isEmpty) {
      return const Center(child: Text('No marketplace listings found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _marketplaceItems.length,
      itemBuilder: (context, index) {
        final item = _marketplaceItems[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                    ),
                  )
                : _buildPlaceholderIcon(),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('₹${item.price}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
                Text(DateFormat('MMM d, yyyy').format(DateTime.parse(item.createdAt))),
              ],
            ),
            onTap: () => context.push('/marketplace/${item.id}'),
          ),
        );
      },
    );
  }

  Widget _buildLostFoundTab() {
    if (_lostFoundItems.isEmpty) {
      return const Center(child: Text('No lost & found reports found.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lostFoundItems.length,
      itemBuilder: (context, index) {
        final item = _lostFoundItems[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: item.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                    ),
                  )
                : _buildPlaceholderIcon(),
            title: Text(item.itemName, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: item.type == 'lost' ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: item.type == 'lost' ? Colors.red : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(DateFormat('MMM d, yyyy').format(DateTime.parse(item.createdAt))),
              ],
            ),
            onTap: () => context.push('/lost-found/${item.id}'),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
