import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/theme/app_typography.dart';
import 'package:cultainer/core/widgets/app_button.dart';
import 'package:cultainer/core/widgets/app_card.dart';
import 'package:cultainer/features/auth/auth_providers.dart';
import 'package:cultainer/features/journal/entry_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for Gemini API key.
final geminiApiKeyProvider =
    StateNotifierProvider<GeminiApiKeyNotifier, String?>((ref) {
  return GeminiApiKeyNotifier();
});

class GeminiApiKeyNotifier extends StateNotifier<String?> {
  GeminiApiKeyNotifier() : super(null) {
    _loadKey();
  }

  static const _key = 'gemini_api_key';

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_key);
  }

  Future<void> setKey(String? key) async {
    final prefs = await SharedPreferences.getInstance();
    if (key == null || key.isEmpty) {
      await prefs.remove(_key);
      state = null;
    } else {
      await prefs.setString(_key, key);
      state = key;
    }
  }
}

/// The profile page displaying user information and settings.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authAction = ref.watch(authActionProvider);
    final isLoading = authAction is AsyncLoading;

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
                    if (user?.photoURL != null)
                      CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(user!.photoURL!),
                      )
                    else
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
                            user?.displayName ?? 'Guest User',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'Sign in to sync your data',
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

              // Stats row
              _buildStatsRow(ref),

              const SizedBox(height: 16),

              // Sign out button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: isLoading ? 'Signing out…' : 'Sign Out',
                  icon: Icons.logout,
                  onPressed: isLoading
                      ? null
                      : () => ref.read(authActionProvider.notifier).signOut(),
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
                      subtitle: ref.watch(geminiApiKeyProvider) != null
                          ? 'Configured'
                          : 'Configure AI assistant',
                      onTap: () => _showGeminiApiKeyDialog(context, ref),
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

  Widget _buildStatsRow(WidgetRef ref) {
    final countsAsync = ref.watch(entryCountsProvider);

    return countsAsync.when(
      data: (counts) => AppCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              '${counts['total'] ?? 0}',
              'Total',
              Icons.library_books,
            ),
            _buildStatItem(
              '${counts['completed'] ?? 0}',
              'Completed',
              Icons.check_circle,
            ),
            _buildStatItem(
              '${counts['in-progress'] ?? 0}',
              'In Progress',
              Icons.play_circle,
            ),
          ],
        ),
      ),
      loading: () => const AppCard(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.numberLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showGeminiApiKeyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(
      text: ref.read(geminiApiKeyProvider),
    );

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Gemini API Key',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your Gemini API key to enable AI features like '
              'recommendations and insights.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Paste your API key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final data = await Clipboard.getData('text/plain');
                    if (data?.text != null) {
                      controller.text = data!.text!;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Get your key at aistudio.google.com',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.text = '';
              ref.read(geminiApiKeyProvider.notifier).setKey(null);
              Navigator.of(context).pop();
            },
            child: Text(
              'Clear',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              ref.read(geminiApiKeyProvider.notifier).setKey(controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
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
