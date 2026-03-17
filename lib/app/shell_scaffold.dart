import 'package:cultainer/core/constants/breakpoints.dart';
import 'package:cultainer/core/theme/app_colors.dart';
import 'package:cultainer/core/widgets/bottom_nav_bar.dart';
import 'package:cultainer/core/widgets/sidebar_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Shell scaffold that provides navigation (sidebar on desktop, bottom bar on mobile).
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
        context.push('/entry/search');
      case 3:
        context.go('/journal');
      case 4:
        context.go('/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= Breakpoints.desktop;
    final selectedIndex = _calculateSelectedIndex(context);

    Widget body;
    if (isDesktop) {
      body = Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            SidebarNav(
              currentIndex: selectedIndex,
              onTap: (index) => _onItemTapped(context, index),
            ),
            Expanded(child: child),
          ],
        ),
      );
    } else {
      body = Scaffold(
        backgroundColor: AppColors.background,
        body: child,
        bottomNavigationBar: BottomNavBar(
          currentIndex: selectedIndex,
          onTap: (index) => _onItemTapped(context, index),
        ),
      );
    }

    // Keyboard shortcuts (Cmd+1..4 for navigation, Cmd+N for new entry)
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.digit1, meta: true): () =>
            _onItemTapped(context, 0),
        const SingleActivator(LogicalKeyboardKey.digit2, meta: true): () =>
            _onItemTapped(context, 1),
        const SingleActivator(LogicalKeyboardKey.digit3, meta: true): () =>
            _onItemTapped(context, 3),
        const SingleActivator(LogicalKeyboardKey.digit4, meta: true): () =>
            _onItemTapped(context, 4),
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () =>
            _onItemTapped(context, 2),
      },
      child: Focus(
        autofocus: true,
        child: body,
      ),
    );
  }
}
