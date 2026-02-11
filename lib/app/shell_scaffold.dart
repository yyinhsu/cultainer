import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/widgets/bottom_nav_bar.dart';

/// Shell scaffold that provides the bottom navigation bar.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/explore')) return 1;
    if (location.startsWith('/journal')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/explore');
      case 2:
        // Navigate to media search page first (can skip to direct entry)
        context.push('/entry/search');
      case 3:
        context.go('/journal');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: child,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(context, index),
      ),
    );
  }
}
