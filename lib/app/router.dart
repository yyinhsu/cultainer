import 'package:cultainer/app/shell_scaffold.dart';
import 'package:cultainer/features/auth/auth_providers.dart';
import 'package:cultainer/features/auth/sign_in_page.dart';
import 'package:cultainer/features/explore/explore_page.dart';
import 'package:cultainer/features/home/home_page.dart';
import 'package:cultainer/features/journal/entry_detail_page.dart';
import 'package:cultainer/features/journal/entry_edit_page.dart';
import 'package:cultainer/features/journal/journal_page.dart';
import 'package:cultainer/features/journal/media_search_page.dart';
import 'package:cultainer/features/profile/profile_page.dart';
import 'package:cultainer/services/media_search_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Global navigation key for accessing navigator from anywhere.
final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Shell navigation key for bottom navigation.
final shellNavigatorKey = GlobalKey<NavigatorState>();

/// Router provider for the application.
final routerProvider = Provider<GoRouter>((ref) {
  // Watch auth state to trigger route refresh on sign-in / sign-out.
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/home',
    // Redirect unauthenticated users to the sign-in page.
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isSignInRoute = state.matchedLocation == '/sign-in';

      if (!isLoggedIn && !isSignInRoute) {
        return '/sign-in';
      }
      if (isLoggedIn && isSignInRoute) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInPage(),
      ),
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
      // Entry routes (outside shell for full-screen experience)
      GoRoute(
        path: '/entry/search',
        name: 'mediaSearch',
        builder: (context, state) => const MediaSearchPage(),
      ),
      GoRoute(
        path: '/entry/new',
        name: 'newEntry',
        builder: (context, state) {
          // Check if a media search result was passed
          final extra = state.extra;
          if (extra is MediaSearchResult) {
            return EntryEditPage(prefillData: extra);
          }
          return const EntryEditPage();
        },
      ),
      GoRoute(
        path: '/entry/:id',
        name: 'entryDetail',
        builder: (context, state) {
          final entryId = state.pathParameters['id']!;
          return EntryDetailPage(entryId: entryId);
        },
        routes: [
          GoRoute(
            path: 'edit',
            name: 'editEntry',
            builder: (context, state) {
              final entryId = state.pathParameters['id']!;
              return EntryEditPage(entryId: entryId);
            },
          ),
        ],
      ),
    ],
  );
});
