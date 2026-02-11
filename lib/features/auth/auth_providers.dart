import 'dart:async';

import 'package:cultainer/features/auth/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the [AuthRepository].
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// Stream provider that emits the current authentication state.
///
/// Emits `null` when the user is signed out, and a [User] when signed in.
final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges();
});

/// Provider for the current user, derived from [authStateProvider].
///
/// Returns `null` when signed out or while the auth state is loading.
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Notifier that manages sign-in / sign-out actions.
final authActionProvider =
    AutoDisposeAsyncNotifierProvider<AuthActionNotifier, void>(
  AuthActionNotifier.new,
);

/// Handles authentication actions (sign in, sign out).
class AuthActionNotifier extends AutoDisposeAsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // No-op: initial state is idle.
  }

  /// Signs in with Google.
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signInWithGoogle();
    });
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(authRepositoryProvider);
      await repo.signOut();
    });
  }
}
