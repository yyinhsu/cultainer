import 'dart:async';

import 'package:cultainer/features/auth/auth_providers.dart';
import 'package:cultainer/features/auth/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late AuthRepository authRepository;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('AuthRepository', () {
    group('currentUser', () {
      test('returns null when not signed in', () {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);
        expect(authRepository.currentUser, isNull);
      });

      test('returns user when signed in', () {
        final mockUser = MockUser();
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
        expect(authRepository.currentUser, mockUser);
      });
    });

    group('authStateChanges', () {
      test('emits null then user on sign-in', () {
        final mockUser = MockUser();
        final controller = StreamController<User?>();
        when(() => mockFirebaseAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final stream = authRepository.authStateChanges();

        expectLater(stream, emitsInOrder([null, mockUser]));

        controller
          ..add(null)
          ..add(mockUser);

        addTearDown(() => controller.close().ignore());
      });
    });

    group('signInWithGoogle', () {
      test('throws when user cancels Google sign-in', () async {
        when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

        expect(
          () => authRepository.signInWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });

      test('calls Firebase signInWithCredential on success', () async {
        final mockAccount = MockGoogleSignInAccount();
        final mockAuth = MockGoogleSignInAuthentication();
        final mockCredential = MockUserCredential();

        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) async => mockAccount);
        when(() => mockAccount.authentication)
            .thenAnswer((_) async => mockAuth);
        when(() => mockAuth.accessToken).thenReturn('access-token');
        when(() => mockAuth.idToken).thenReturn('id-token');
        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockCredential);

        final result = await authRepository.signInWithGoogle();
        expect(result, mockCredential);

        verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
      });
    });

    group('signOut', () {
      test('signs out from both Firebase and Google', () async {
        when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        await authRepository.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });
    });
  });

  group('Auth providers', () {
    group('authStateProvider', () {
      test('emits auth state changes from repository', () async {
        final mockUser = MockUser();
        final controller = StreamController<User?>();

        final mockAuth = MockFirebaseAuth();
        when(() => mockAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final repo = AuthRepository(
          firebaseAuth: mockAuth,
          googleSignIn: MockGoogleSignIn(),
        );

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        // Initial state is loading
        expect(
          container.read(authStateProvider),
          isA<AsyncLoading<User?>>(),
        );

        controller.add(mockUser);
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(authStateProvider).valueOrNull,
          mockUser,
        );

        controller.add(null);
        await Future<void>.delayed(Duration.zero);

        expect(
          container.read(authStateProvider).valueOrNull,
          isNull,
        );

        controller.close().ignore();
      });
    });

    group('currentUserProvider', () {
      test('returns null when auth state is loading', () {
        final controller = StreamController<User?>();
        final mockAuth = MockFirebaseAuth();
        when(() => mockAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final repo = AuthRepository(
          firebaseAuth: mockAuth,
          googleSignIn: MockGoogleSignIn(),
        );

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);
        addTearDown(() => controller.close().ignore());

        expect(container.read(currentUserProvider), isNull);
      });

      test('returns user when signed in', () async {
        final mockUser = MockUser();
        final controller = StreamController<User?>();

        final mockAuth = MockFirebaseAuth();
        when(() => mockAuth.authStateChanges())
            .thenAnswer((_) => controller.stream);

        final repo = AuthRepository(
          firebaseAuth: mockAuth,
          googleSignIn: MockGoogleSignIn(),
        );

        final container = ProviderContainer(
          overrides: [
            authRepositoryProvider.overrideWithValue(repo),
          ],
        );
        addTearDown(container.dispose);

        // Subscribe to trigger the stream provider
        container.listen(authStateProvider, (_, __) {});

        controller.add(mockUser);
        // Give the stream provider time to process
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(container.read(currentUserProvider), mockUser);

        controller.close().ignore();
      });
    });
  });

  group('Router redirect logic', () {
    String? computeRedirect({
      required bool isLoggedIn,
      required bool isSignInRoute,
    }) {
      if (!isLoggedIn && !isSignInRoute) return '/sign-in';
      if (isLoggedIn && isSignInRoute) return '/home';
      return null;
    }

    test('unauthenticated user should be redirected to sign-in', () {
      expect(
        computeRedirect(isLoggedIn: false, isSignInRoute: false),
        '/sign-in',
      );
    });

    test('authenticated user on sign-in should be redirected to home', () {
      expect(
        computeRedirect(isLoggedIn: true, isSignInRoute: true),
        '/home',
      );
    });

    test('authenticated user on other routes should not redirect', () {
      expect(
        computeRedirect(isLoggedIn: true, isSignInRoute: false),
        isNull,
      );
    });

    test('unauthenticated user on sign-in should not redirect', () {
      expect(
        computeRedirect(isLoggedIn: false, isSignInRoute: true),
        isNull,
      );
    });
  });
}
