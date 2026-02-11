import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:cultainer/features/auth/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen sign-in page shown to unauthenticated users.
class SignInPage extends ConsumerWidget {
  const SignInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAction = ref.watch(authActionProvider);

    // Listen for errors and show a snackbar.
    ref.listen<AsyncValue<void>>(authActionProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${next.error}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final isLoading = authAction is AsyncLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // App icon / branding
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 52,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),

              // App name
              Text(
                'Cultainer',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Tagline
              Text(
                'Track every book, movie, and podcast\nthat shapes your world.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Sign in button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: isLoading ? 'Signing in…' : 'Sign in with Google',
                  icon: Icons.login,
                  onPressed: isLoading
                      ? null
                      : () => ref
                          .read(authActionProvider.notifier)
                          .signInWithGoogle(),
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: 16),

              // Loading indicator
              if (isLoading)
                const LinearProgressIndicator(
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                ),

              const SizedBox(height: 24),

              // Terms text
              Text(
                'By signing in, you agree to our\nTerms of Service and Privacy Policy.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                  height: 1.5,
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
