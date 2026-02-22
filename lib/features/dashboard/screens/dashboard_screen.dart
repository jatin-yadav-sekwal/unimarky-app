import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/core/theme/brand_colors.dart';
import 'package:unimarky/core/widgets/app_shimmer.dart';
import 'package:unimarky/features/auth/providers/auth_provider.dart';
import 'package:unimarky/features/dashboard/widgets/quick_access_card.dart';
import 'package:unimarky/features/dashboard/widgets/summary_card.dart';

/// Dashboard screen — mirrors web's DashboardPage.tsx.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _marketplaceItems = [];
  List<Map<String, dynamic>> _lostFoundItems = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final api = ApiClient.instance;
      final results = await Future.wait([
        api.get('/marketplace/my-listings').catchError((_) => []),
        api.get('/lost-found/my-listings').catchError((_) => []),
      ]);
      if (mounted) {
        setState(() {
          _marketplaceItems = List<Map<String, dynamic>>.from(results[0] as List? ?? []).take(3).toList();
          _lostFoundItems = List<Map<String, dynamic>>.from(results[1] as List? ?? []).take(3).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final firstName = profile?.fullName?.split(' ').first ?? 'there';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, $firstName! ✨',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            Text('What would you like to do today?',
                style: theme.textTheme.bodySmall),
          ],
        ),
        toolbarHeight: 72,
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Access Grid
              Text('Quick Access',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: const [
                  QuickAccessCard(
                    title: 'Marketplace',
                    description: 'Buy & Sell items',
                    icon: Icons.shopping_bag,
                    gradientColors: [Color(0xFFF59E0B), Color(0xFFEA580C)],
                    route: '/marketplace',
                  ),
                  QuickAccessCard(
                    title: 'Lost & Found',
                    description: 'Report or find items',
                    icon: Icons.search,
                    gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    route: '/lost-found',
                  ),
                  QuickAccessCard(
                    title: 'Unimedia',
                    description: 'Campus news & stories',
                    icon: Icons.newspaper,
                    gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                    route: '/unimedia',
                  ),
                  QuickAccessCard(
                    title: 'Food',
                    description: 'Restaurants nearby',
                    icon: Icons.restaurant,
                    gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
                    route: '/explore?tab=food',
                  ),
                  QuickAccessCard(
                    title: 'Housing',
                    description: 'Find a place to stay',
                    icon: Icons.home,
                    gradientColors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                    route: '/explore?tab=housing',
                  ),
                  QuickAccessCard(
                    title: 'Study',
                    description: 'Resources & notes',
                    icon: Icons.menu_book,
                    gradientColors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                    route: '/explore?tab=study',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Section
              Text('Your Activity',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              if (_isLoading)
                Column(children: [
                  AppShimmer(width: double.infinity, height: 140),
                  const SizedBox(height: 12),
                  AppShimmer(width: double.infinity, height: 140),
                ])
              else ...[
                SummaryCard(
                  title: 'Marketplace Listings',
                  icon: Icons.shopping_bag,
                  iconColor: BrandColors.orange,
                  bgColor: BrandColors.orange.withValues(alpha: 0.1),
                  href: '/marketplace/my-listings',
                  items: _marketplaceItems,
                  secondaryHref: '/marketplace/create',
                  secondaryLabel: '+ New Listing',
                ),
                const SizedBox(height: 12),
                SummaryCard(
                  title: 'Lost & Found',
                  icon: Icons.search,
                  iconColor: Colors.red,
                  bgColor: Colors.red.withValues(alpha: 0.1),
                  href: '/lost-found/my-listings',
                  items: _lostFoundItems,
                  secondaryHref: '/lost-found/report',
                  secondaryLabel: '+ Report Item',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
