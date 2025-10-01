import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:google_sign_in/google_sign_in.dart';

import 'package:minq/domain/auth/auth_exception.dart';

class AuthRepository {
  AuthRepository(this._firebaseAuth);

  final FirebaseAuth? _firebaseAuth;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool get isAvailable => _firebaseAuth != null;

  Stream<User?> get authStateChanges {
    final auth = _firebaseAuth;
    if (auth == null) {
      return const Stream<User?>.empty();
    }
    return auth.authStateChanges();
  }

  User? getCurrentUser() {
    return _firebaseAuth?.currentUser;
  }

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

  Future<User?> linkWithGoogle() async {
    debugPrint('Google Sign-In is temporarily disabled.');
    // try {
    //   // ...
    // } on FirebaseAuthException catch (e) {
    //   throw AuthException(_handleFirebaseAuthException(e));
    // }
    return null;
  }

  Future<void> signOut() async {
    final auth = _firebaseAuth;
    if (auth == null) {
      debugPrint('FirebaseAuth unavailable; skipping signOut.');
      return;
    }
    // await _googleSignIn.signOut();
    await auth.signOut();
  }

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'operation-not-allowed':
        return 'Anonymous sign-in is not enabled for this project.';
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided for this user.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials.';
      case 'invalid-credential':
        return 'The credential received is malformed or has expired.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
