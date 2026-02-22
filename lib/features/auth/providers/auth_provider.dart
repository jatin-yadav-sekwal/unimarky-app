import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/features/auth/models/user_profile.dart';

/// Auth state exposed to the entire app via Riverpod.
class AuthState {
  final User? user;
  final Session? session;
  final UserProfile? profile;
  final bool isLoading;

  const AuthState({
    this.user,
    this.session,
    this.profile,
    this.isLoading = true,
  });

  bool get isAuthenticated => user != null;
  bool get onboardingCompleted => profile?.onboardingCompleted ?? false;
  String get role => profile?.role ?? 'normal';

  AuthState copyWith({
    User? user,
    Session? session,
    UserProfile? profile,
    bool? isLoading,
  }) {
    return AuthState(
      user: user ?? this.user,
      session: session ?? this.session,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Manages authentication state — mirrors web's `useAuth.ts` hook.
class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;
  final ApiClient _api;
  StreamSubscription<AuthState>? _authSub;

  AuthNotifier(this._supabase, this._api) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // 1. Get initial session
    final session = _supabase.auth.currentSession;
    final user = session?.user;

    if (user != null) {
      state = state.copyWith(user: user, session: session, isLoading: true);
      await _fetchProfile();
    } else {
      state = state.copyWith(isLoading: false);
    }

    // 2. Listen for auth changes
    _supabase.auth.onAuthStateChange.listen((data) async {
      final newSession = data.session;
      final newUser = newSession?.user;

      state = state.copyWith(
        user: newUser,
        session: newSession,
        isLoading: newUser != null,
      );

      if (newUser != null) {
        await _fetchProfile();
      } else {
        state = AuthState(isLoading: false); // Logged out — reset
      }
    });
  }

  Future<void> _fetchProfile() async {
    try {
      final data = await _api.get('/profiles/me');
      final profile = UserProfile.fromJson(data as Map<String, dynamic>);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (_) {
      // Profile not found (new user) — still mark loading as done
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    state = const AuthState(isLoading: false);
  }

  Future<void> refreshProfile() async {
    await _fetchProfile();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

// ── Providers ──

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    Supabase.instance.client,
    ApiClient.instance,
  );
});

/// Convenience selectors
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isLoadingAuthProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final userProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authProvider).profile;
});
