import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/features/auth/providers/auth_provider.dart';
import 'package:unimarky/features/auth/screens/auth_screen.dart';
import 'package:unimarky/features/onboarding/screens/onboarding_screen.dart';
import 'package:unimarky/features/dashboard/screens/dashboard_screen.dart';
import 'package:unimarky/features/profile/screens/profile_screen.dart';
import 'package:unimarky/features/marketplace/screens/marketplace_screen.dart';
import 'package:unimarky/features/marketplace/screens/marketplace_item_screen.dart';
import 'package:unimarky/features/marketplace/screens/my_marketplace_listings_screen.dart';
import 'package:unimarky/features/marketplace/screens/create_listing_screen.dart';
import 'package:unimarky/features/marketplace/screens/edit_listing_screen.dart';
import 'package:unimarky/features/lostfound/screens/lostfound_screen.dart';
import 'package:unimarky/features/lostfound/screens/lostfound_item_screen.dart';
import 'package:unimarky/features/lostfound/screens/report_item_screen.dart';
import 'package:unimarky/features/lostfound/screens/my_lostfound_listings_screen.dart';
import 'package:unimarky/features/lostfound/screens/edit_report_screen.dart';
import 'package:unimarky/features/unimedia/screens/unimedia_screen.dart';
import 'package:unimarky/features/unimedia/screens/post_detail_screen.dart';
import 'package:unimarky/features/explore/screens/explore_screen.dart';
import 'package:unimarky/features/food/screens/restaurant_detail_screen.dart';
import 'package:unimarky/features/housing/screens/accommodation_detail_screen.dart';
import 'package:unimarky/features/study/screens/upload_material_screen.dart';
import 'package:unimarky/features/admin/screens/request_role_screen.dart';
import 'package:unimarky/features/admin/screens/admin_panel_screen.dart';
import 'package:unimarky/features/admin/screens/superuser_screen.dart';
import 'package:unimarky/features/profile/screens/edit_profile_screen.dart';
import 'package:unimarky/features/profile/screens/my_content_screen.dart';
import 'package:unimarky/features/profile/screens/public_profile_screen.dart';
import 'package:unimarky/features/landing/screens/landing_screen.dart';

// ── GoRouter configuration ──
// Mirrors react-router-dom routes + ProtectedRoute logic from App.tsx.
// Uses authProvider from features/auth/providers/auth_provider.dart.

class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen(authProvider, (_, __) => notifyListeners());
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      if (authState.isLoading) {
        return state.uri.path == '/splash' ? null : '/splash';
      }

      final isAuthenticated = authState.isAuthenticated;
      final isOnboarded = authState.onboardingCompleted;
      final path = state.uri.path;

      final publicPaths = ['/', '/auth', '/about', '/contact', '/privacy', '/terms', '/splash'];
      final isPublicRoute = publicPaths.contains(path);

      // Not authenticated → send to auth
      if (!isAuthenticated && !isPublicRoute) return '/auth';

      // Authenticated but on auth page or splash → redirect appropriately
      if (isAuthenticated && (path == '/auth' || path == '/splash')) {
        return isOnboarded ? '/dashboard' : '/onboarding';
      }

      // Authenticated but not onboarded → force onboarding
      if (isAuthenticated && !isOnboarded && path != '/onboarding') {
        return '/onboarding';
      }

      // Authenticated + onboarded but on landing → dashboard
      if (isAuthenticated && isOnboarded && path == '/') return '/dashboard';

      return null;
    },
    routes: [
      // ── Splash ──
      GoRoute(
        path: '/splash',
        builder: (_, _) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),

      // ── Public routes ──
      GoRoute(path: '/', builder: (_, _) => const LandingScreen()),
      GoRoute(path: '/auth', builder: (_, _) => const AuthScreen()),
      GoRoute(path: '/about', builder: (_, _) => const _PlaceholderScreen('About')),

      // ── Onboarding ──
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),

      // ── Main app shell ──
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
          GoRoute(path: '/marketplace', builder: (_, _) => const MarketplaceScreen()),
          GoRoute(path: '/marketplace/my-listings', builder: (_, _) => const MyMarketplaceListingsScreen()),
          GoRoute(path: '/marketplace/create', builder: (_, _) => const CreateListingScreen()),
          GoRoute(path: '/marketplace/edit/:id', builder: (_, state) => EditListingScreen(itemId: state.pathParameters['id']!)),
          GoRoute(path: '/marketplace/:id', builder: (_, state) => MarketplaceItemScreen(itemId: state.pathParameters['id']!)),
          GoRoute(path: '/lost-found', builder: (_, _) => const LostFoundScreen()),
          GoRoute(path: '/lost-found/my-listings', builder: (_, _) => const MyLostFoundListingsScreen()),
          GoRoute(path: '/lost-found/report', builder: (_, _) => const ReportItemScreen()),
          GoRoute(path: '/lost-found/edit/:id', builder: (_, state) => EditReportScreen(itemId: state.pathParameters['id']!)),
          GoRoute(path: '/lost-found/:id', builder: (_, state) => LostFoundItemScreen(itemId: state.pathParameters['id']!)),
          GoRoute(path: '/unimedia', builder: (_, _) => const UnimediaScreen()),
          GoRoute(path: '/unimedia/:id', builder: (_, state) => PostDetailScreen(postId: state.pathParameters['id']!)),
          GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen()),
          GoRoute(path: '/food/:id', builder: (_, state) => RestaurantDetailScreen(restaurantId: state.pathParameters['id']!)),
          GoRoute(path: '/housing/:id', builder: (_, state) => AccommodationDetailScreen(itemId: state.pathParameters['id']!)),
          GoRoute(path: '/study/upload', builder: (_, _) => const UploadMaterialScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
          GoRoute(path: '/profile/edit', builder: (_, _) => const EditProfileScreen()),
          GoRoute(path: '/public-profile/:id', builder: (_, state) => PublicProfileScreen(userId: state.pathParameters['id']!)),
          GoRoute(path: '/request-role', builder: (_, _) => const RequestRoleScreen()),
          GoRoute(path: '/my-content', builder: (_, _) => const MyContentScreen()),
          GoRoute(path: '/admin', builder: (_, _) => const AdminPanelScreen()),
          GoRoute(path: '/superuser', builder: (_, _) => const SuperuserScreen()),
        ],
      ),
    ],
  );
});

// ── Temporary placeholder screen ──
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

// ── App shell with bottom nav ──
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), selectedIcon: Icon(Icons.shopping_bag), label: 'Market'),
          NavigationDestination(icon: Icon(Icons.article_outlined), selectedIcon: Icon(Icons.article), label: 'Unimedia'),
          NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: 'Explore'),
          NavigationDestination(icon: Icon(Icons.person_outlined), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path.startsWith('/dashboard')) return 0;
    if (path.startsWith('/marketplace')) return 1;
    if (path.startsWith('/unimedia')) return 2;
    if (path.startsWith('/explore') || path.startsWith('/food') || path.startsWith('/housing') || path.startsWith('/study')) return 3;
    if (path.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/dashboard');
      case 1: context.go('/marketplace');
      case 2: context.go('/unimedia');
      case 3: context.go('/explore');
      case 4: context.go('/profile');
    }
  }
}
