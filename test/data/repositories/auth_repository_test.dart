import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minq/data/repositories/firebase_auth_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([FirebaseAuth, User, UserCredential])
void main() {
  group('FirebaseAuthRepository', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late FirebaseAuthRepository authRepository;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      authRepository = FirebaseAuthRepository(mockFirebaseAuth);
    });

    test('signInAnonymously calls FirebaseAuth.signInAnonymously', () async {
      final mockUserCredential = MockUserCredential();
      when(mockFirebaseAuth.signInAnonymously())
          .thenAnswer((_) async => mockUserCredential);

      await authRepository.signInAnonymously();

      verify(mockFirebaseAuth.signInAnonymously()).called(1);
    });

    test('signOut calls FirebaseAuth.signOut', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
      await authRepository.signOut();
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    test('getCurrentUser returns the current user from FirebaseAuth', () {
      final mockUser = MockUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      final result = authRepository.getCurrentUser();

      expect(result, mockUser);
      verify(mockFirebaseAuth.currentUser).called(1);
    });

    test('authStateChanges returns the stream from FirebaseAuth', () {
      final stream = Stream.value(MockUser());
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => stream);

      final result = authRepository.authStateChanges;

      expect(result, stream);
      verify(mockFirebaseAuth.authStateChanges()).called(1);
    });
  });
}