import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/core/network/api_client.dart';
import 'package:unimarky/core/theme/brand_colors.dart';
import 'package:unimarky/core/widgets/app_button.dart';
import 'package:unimarky/core/widgets/app_input.dart';
import 'package:unimarky/features/auth/providers/auth_provider.dart';
import 'package:unimarky/features/onboarding/widgets/university_selector.dart';

/// Onboarding screen — mirrors web's OnboardingPage.tsx.
/// Collects university, mobile number, and optional password (for social logins).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _university = '';
  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  bool get _isSocialLogin {
    final user = Supabase.instance.client.auth.currentUser;
    return user?.appMetadata['provider'] != 'email';
  }

  bool get _isValid {
    if (_university.isEmpty) return false;
    if (_mobileController.text.length != 10) return false;
    if (_isSocialLogin && _passwordController.text.length < 6) return false;
    return true;
  }

  Future<void> _handleSubmit() async {
    if (!_isValid) return;
    setState(() => _isLoading = true);

    try {
      // 1. If social login, set password in Supabase Auth
      if (_isSocialLogin && _passwordController.text.isNotEmpty) {
        final res = await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: _passwordController.text),
        );
        if (res.user == null) throw Exception('Failed to set password');
      }

      // 2. Update profile in backend
      final api = ApiClient.instance;
      await api.patch('/profiles/onboarding', data: {
        'universityName': _university,
        'mobileNumber': _mobileController.text,
      });

      // 3. Refresh profile in provider
      ref.read(authProvider.notifier).refreshProfile();

      // 4. Navigate to dashboard
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Onboarding failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Welcome to Unimarky! 🎓',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BrandColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Let's set up your profile to get started.",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // University selector
                    Text('Select University',
                        style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    UniversitySelector(
                      value: _university.isEmpty ? null : _university,
                      onChanged: (v) => setState(() => _university = v),
                    ),
                    const SizedBox(height: 16),

                    // Mobile number
                    AppInput(
                      controller: _mobileController,
                      label: 'Mobile Number',
                      hint: '10-digit mobile number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Password (social login only)
                    if (_isSocialLogin) ...[
                      AppInput(
                        controller: _passwordController,
                        label: 'Set Account Password',
                        hint: 'Min. 6 characters',
                        obscureText: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Since you logged in with Google, set a password to login with email later.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: _isLoading ? 'Setting up...' : 'Complete Setup',
                        onPressed: _isValid ? _handleSubmit : null,
                        isLoading: _isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
