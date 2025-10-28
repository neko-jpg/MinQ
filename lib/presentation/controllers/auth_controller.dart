import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';
import 'package:minq/data/services/notification_service.dart';
import 'package:minq/domain/auth/auth_exception.dart';
import 'package:minq/domain/user/user.dart' as minq_user;

enum AuthMethod { google, apple, email, anonymous }

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.error,
    this.isFirstTimeUser = false,
    this.isGuestAuthenticated = false,
  });

  final bool isLoading;
  final String? error;
  final bool isFirstTimeUser;
  final bool isGuestAuthenticated;

  AuthState copyWith({
    bool? isLoading,
    String? error,
    bool? isFirstTimeUser,
    bool? isGuestAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isFirstTimeUser: isFirstTimeUser ?? this.isFirstTimeUser,
      isGuestAuthenticated: isGuestAuthenticated ?? this.isGuestAuthenticated,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState());

  static const _guestUserId = 'debug-guest-user';

  final Ref _ref;

  Future<bool> signIn(AuthMethod method) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      isGuestAuthenticated: false,
    );
    _clearGuestUser();

    try {
      switch (method) {
        case AuthMethod.google:
          return await _signInWithGoogle();
        case AuthMethod.apple:
          return await _signInWithApple();
        case AuthMethod.email:
          return await _signInWithEmail();
        case AuthMethod.anonymous:
          return await _signInAnonymously();
      }
    } on AuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'authErrorUnknown');
      debugPrint('Auth error: $e');
      return false;
    }
  }

  Future<bool> _signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    // For now, fall back to anonymous sign-in
    debugPrint('Google Sign-In not yet implemented, using anonymous sign-in');
    return await _signInAnonymously();
  }

  Future<bool> _signInWithApple() async {
    // TODO: Implement Apple Sign-In
    // For now, fall back to anonymous sign-in
    debugPrint('Apple Sign-In not yet implemented, using anonymous sign-in');
    return await _signInAnonymously();
  }

  Future<bool> _signInWithEmail() async {
    // TODO: Implement Email Sign-In
    // For now, fall back to anonymous sign-in
    debugPrint('Email Sign-In not yet implemented, using anonymous sign-in');
    return await _signInAnonymously();
  }

  Future<bool> _signInAnonymously() async {
    // NOTE: Firebase接続までのデバッグ用ゲストログイン
    debugPrint(
      'Bypassing Firebase auth and using local guest session for debugging.',
    );
    return _completeGuestSignIn();
  }

  Future<void> _initializeUserProfile(String uid) async {
    try {
      final userRepository = _ref.read(userRepositoryProvider);
      final notificationService = _ref.read(notificationServiceProvider);

      final newUser =
          minq_user.User()
            ..uid = uid
            ..displayName = 'Adventurer'
            ..handle = null
            ..bio = ''
            ..avatarSeed = 'seed-01'
            ..focusTags = <String>[]
            ..createdAt = DateTime.now()
            ..notificationTimes = List.of(
              NotificationService.defaultReminderTimes,
            )
            ..privacy = 'private'
            ..longestStreak = 0
            ..currentStreak = 0;

      await userRepository.saveLocalUser(newUser);

      // Initialize notifications
      final permissionGranted = await notificationService.requestPermission();
      if (permissionGranted) {
        await notificationService.scheduleRecurringReminders(
          newUser.notificationTimes.take(2).toList(),
        );
      }

      debugPrint('User profile initialized for $uid');
    } catch (e) {
      debugPrint('Failed to initialize user profile: $e');
    }
  }

  Future<bool> startDebugGuestSession() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      isGuestAuthenticated: false,
    );
    _clearGuestUser();
    return _signInAnonymously();
  }

  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      isGuestAuthenticated: false,
    );
    _clearGuestUser();

    try {
      final authRepository = _ref.read(authRepositoryProvider);
      await authRepository.signOut();

      // Clear notifications
      final notificationService = _ref.read(notificationServiceProvider);
      await notificationService.cancelAll();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'authErrorUnknown');
      debugPrint('Sign out error: $e');
    }
  }

  Future<bool> _completeGuestSignIn() async {
    debugPrint('Using local guest session for debugging.');

    final guestUserNotifier = _ref.read(guestUserIdProvider.notifier);
    guestUserNotifier.state = _guestUserId;

    final userRepository = _ref.read(userRepositoryProvider);
    final existingUser = await userRepository.getUserById(_guestUserId);
    if (existingUser == null) {
      await _initializeUserProfile(_guestUserId);
    } else if (existingUser.displayName.isEmpty) {
      await userRepository.upsertProfile(
        _guestUserId,
        displayName: 'Guest Adventurer',
      );
    }

    state = state.copyWith(
      isLoading: false,
      error: null,
      isFirstTimeUser: false,
      isGuestAuthenticated: true,
    );
    return true;
  }

  void _clearGuestUser() {
    _ref.read(guestUserIdProvider.notifier).state = null;
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<bool> retrySignIn(AuthMethod method) async {
    clearError();
    return await signIn(method);
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(ref);
  },
);
