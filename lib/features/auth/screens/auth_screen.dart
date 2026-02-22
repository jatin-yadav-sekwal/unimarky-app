import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:unimarky/core/theme/brand_colors.dart';
import 'package:unimarky/core/widgets/app_button.dart';
import 'package:unimarky/core/widgets/app_input.dart';
import 'package:unimarky/features/auth/providers/auth_provider.dart';
import 'package:unimarky/features/auth/widgets/social_auth_button.dart';

/// Auth screen with Login/Signup tabs — mirrors web's AuthPage + AuthForm.
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _error;
  String? _message;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _error = null;
        _message = null;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  bool get _isSignup => _tabController.index == 1;

  Future<void> _handleAuth() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });

    try {
      final supabase = Supabase.instance.client;

      if (_isSignup) {
        final res = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'full_name': _fullNameController.text.trim()},
        );
        if (res.user != null) {
          setState(() => _message = 'Check your email for the confirmation link!');
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        // Auth state change will trigger redirect via GoRouter guard
      }
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // If already authenticated, redirect
    final authState = ref.watch(authProvider);
    if (authState.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/dashboard');
      });
    }

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
                  children: [
                    // Header
                    Text(
                      _isSignup ? 'Join Unmarky' : 'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: BrandColors.navy,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isSignup
                          ? 'Create an account to get started'
                          : 'Enter your credentials or use social login',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: BrandColors.blue.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Social auth
                    const SocialAuthButton(),
                    const SizedBox(height: 20),

                    // Tabs
                    TabBar(
                      controller: _tabController,
                      tabs: const [Tab(text: 'Login'), Tab(text: 'Sign Up')],
                      labelColor: BrandColors.navy,
                      indicatorColor: BrandColors.orange,
                    ),
                    const SizedBox(height: 16),

                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Full name (signup only)
                          if (_isSignup) ...[
                            AppInput(
                              controller: _fullNameController,
                              label: 'Full Name',
                              hint: 'John Doe',
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Name is required' : null,
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Email
                          AppInput(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'student@university.edu',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email is required';
                              if (!v.contains('@')) return 'Invalid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Password
                          AppInput(
                            controller: _passwordController,
                            label: 'Password',
                            obscureText: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Password is required';
                              if (v.length < 6) return 'Min 6 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Error
                          if (_error != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_error!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13)),
                            ),

                          // Success message
                          if (_message != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(_message!,
                                  style: const TextStyle(color: Colors.green, fontSize: 13)),
                            ),

                          const SizedBox(height: 16),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            child: AppButton(
                              label: _isSignup ? 'Create Account' : 'Sign In',
                              onPressed: _handleAuth,
                              isLoading: _isLoading,
                            ),
                          ),
                        ],
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
