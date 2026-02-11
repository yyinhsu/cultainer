import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Web OAuth client ID from Firebase Console.
const _webClientId =
    '719263123687-ec3k3ndk3g2iugp95uvvjhq7eh0louh1.apps.googleusercontent.com';

/// Repository handling Firebase Authentication operations.
class AuthRepository {
  AuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(
              clientId: kIsWeb ? _webClientId : null,
            );

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  /// Stream of authentication state changes.
  Stream<User?> authStateChanges() => _firebaseAuth.authStateChanges();

  /// The current authenticated user, or null if not signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Signs in with Google.
  ///
  /// Returns the [UserCredential] on success, or throws on failure.
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the Google Sign-In flow
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled by the user.');
    }

    // Obtain auth details from the request
    final googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    return _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs out the current user from both Firebase and Google.
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
