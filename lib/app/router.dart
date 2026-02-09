import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/explore/explore_page.dart';
import '../features/home/home_page.dart';
import '../features/journal/journal_page.dart';
import '../features/profile/profile_page.dart';
import 'shell_scaffold.dart';

part 'router.g.dart';

/// Global navigation key for accessing navigator from anywhere.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Shell navigation key for bottom navigation.
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider for the application.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomePage(),
            ),
          ),
          GoRoute(
            path: '/explore',
            name: 'explore',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ExplorePage(),
            ),
          ),
          GoRoute(
            path: '/journal',
            name: 'journal',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JournalPage(),
            ),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfilePage(),
            ),
          ),
        ],
      ),
      // TODO(routes): Add entry detail, add/edit entry routes
    ],
  );
});
