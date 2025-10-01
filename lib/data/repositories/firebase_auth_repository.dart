import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:minq/domain/auth/auth_exception.dart';

/// Abstract interface for authentication functionalities.
/// This allows for easy mocking in tests and decouples the app from a specific
/// auth provider implementation.
abstract class IAuthRepository {
  /// A stream that notifies of changes to the user's sign-in state.
  Stream<User?> get authStateChanges;

  /// Returns the current signed-in user, or null if none exists.
  User? getCurrentUser();

  /// Signs in the user anonymously.
  Future<User?> signInAnonymously();

  /// Links the current user's account with Google Sign-In.
  Future<User?> linkWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();

  /// A boolean indicating if the authentication service is available.
  /// This is useful for environments where Firebase might not be initialized.
  bool get isAvailable;
}

/// Firebase-based implementation of the [IAuthRepository].
class FirebaseAuthRepository implements IAuthRepository {
  FirebaseAuthRepository(this._firebaseAuth);

  final FirebaseAuth? _firebaseAuth;

  @override
  bool get isAvailable => _firebaseAuth != null;

  @override
  Stream<User?> get authStateChanges {
    final auth = _firebaseAuth;
    if (auth == null) {
      return const Stream<User?>.empty();
    }
    return auth.authStateChanges();
  }

  @override
  User? getCurrentUser() {
    return _firebaseAuth?.currentUser;
  }

  @override
  Future<User?> signInAnonymously() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      debugPrint('FirebaseAuth unavailable; skipping anonymous sign-in.');
      return null;
    }
    try {
      final userCredential = await auth.signInAnonymously();
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_handleFirebaseAuthException(e));
    }
  }

  @override
  Future<User?> linkWithGoogle() async {
    debugPrint('Google Sign-In is temporarily disabled.');
    // In a real implementation, you would use google_sign_in package here.
    return null;
  }

  @override
  Future<void> signOut() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      debugPrint('FirebaseAuth unavailable; skipping signOut.');
      return;
    }
    await auth.signOut();
  }

  /// Converts a [FirebaseAuthException] into a localization-friendly error key.
  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'authErrorOperationNotAllowed';
      case 'weak-password':
        return 'authErrorWeakPassword';
      case 'email-already-in-use':
        return 'authErrorEmailAlreadyInUse';
      case 'invalid-email':
        return 'authErrorInvalidEmail';
      case 'user-disabled':
        return 'authErrorUserDisabled';
      case 'user-not-found':
        return 'authErrorUserNotFound';
      case 'wrong-password':
        return 'authErrorWrongPassword';
      case 'account-exists-with-different-credential':
        return 'authErrorAccountExistsWithDifferentCredential';
      case 'invalid-credential':
        return 'authErrorInvalidCredential';
      default:
        return 'authErrorUnknown';
    }
  }
}