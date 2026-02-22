import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarky/core/theme/brand_colors.dart';
import 'package:unimarky/core/widgets/app_button.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Minimal header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      'assets/images/logo2.svg',
                      height: 32, // Adjusted height for top header
                    ),
                    TextButton(
                      onPressed: () => context.go('/auth'),
                      child: const Text('Log In', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                SizedBox(height: size.height * 0.1),
                
                // Hero Section
                SvgPicture.asset(
                  'assets/images/logo2.svg',
                  height: 80,
                ),
                const SizedBox(height: 32),
                
                Text(
                  'Your Campus.\nYour Marketplace.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Join thousands of students buying, selling, finding housing, and discovering campus food—all in one place.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Action Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: AppButton(
                    label: 'Get Started for Free',
                    onPressed: () => context.go('/auth'),
                  ),
                ),
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.go('/auth'),
                    child: const Text('Explore (Log in required)', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 64),
                
                // Features
                _buildFeatureItem(
                  context, 
                  Icons.shopping_bag_outlined, 
                  'Peer-to-Peer Market', 
                  'Buy and sell textbooks, electronics, and dorm essentials safely within your campus community.'
                ),
                _buildFeatureItem(
                  context, 
                  Icons.home_outlined, 
                  'Student Housing', 
                  'Find verified PGs, hostels, and apartments nearby without dealing with middleman brokers.'
                ),
                _buildFeatureItem(
                  context, 
                  Icons.restaurant_menu_outlined, 
                  'Campus Dining', 
                  'Discover menus, read real student reviews, and find the top spots to eat around campus.'
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String title, String desc) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
