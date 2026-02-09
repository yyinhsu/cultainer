import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';

/// The profile page displaying user information and settings.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Profile',
                style: AppTypography.displayLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // User card
              AppCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(36),
                        border: Border.all(
                          color: AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 36,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Guest User',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Sign in to sync your data',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Sign in button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Sign in with Google',
                  icon: Icons.login,
                  onPressed: () {
                    // TODO(auth): Implement Google Sign-In
                  },
                  isExpanded: true,
                ),
              ),

              const SizedBox(height: 32),

              // Settings section
              Text(
                'Settings',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsItem(
                      icon: Icons.key_outlined,
                      title: 'Gemini API Key',
                      subtitle: 'Configure AI assistant',
                      onTap: () {
                        // TODO(settings): Open Gemini API key settings
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                    ),
                    _SettingsItem(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      subtitle: 'Manage reminders',
                      onTap: () {
                        // TODO(settings): Open notifications settings
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                    ),
                    _SettingsItem(
                      icon: Icons.cloud_outlined,
                      title: 'Data & Storage',
                      subtitle: 'Manage cached data',
                      onTap: () {
                        // TODO(settings): Open data settings
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // About section
              Text(
                'About',
                style: AppTypography.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _SettingsItem(
                      icon: Icons.policy_outlined,
                      title: 'Privacy Policy',
                      onTap: () {
                        // TODO(about): Open privacy policy
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                    ),
                    _SettingsItem(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () {
                        // TODO(about): Open terms of service
                      },
                    ),
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                    ),
                    _SettingsItem(
                      icon: Icons.info_outline,
                      title: 'Version',
                      trailing: Text(
                        '0.1.0',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}
