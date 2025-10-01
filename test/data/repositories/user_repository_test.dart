import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:minq/data/repositories/firebase_auth_repository.dart';
import 'package:minq/data/repositories/user_repository.dart';
import 'package:minq/domain/user/user.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

import 'user_repository_test.mocks.dart';

// Mock classes for dependencies
class MockIAuthRepository extends Mock implements IAuthRepository {}
class MockIsar extends Mock implements Isar {}
class MockUserCollection extends Mock implements IsarCollection<User> {}
class MockUserQuery extends Mock implements Query<User> {}
class MockFirebaseUser extends Mock implements fb_auth.User {}

@GenerateMocks([IAuthRepository, Isar, IsarCollection, Query, fb_auth.User])
void main() {
  group('UserRepository', () {
    late MockIsar mockIsar;
    late MockIAuthRepository mockAuthRepository;
    late UserRepository userRepository;
    late MockUserCollection mockUserCollection;
    late MockUserQuery mockQuery;

    setUp(() {
      mockIsar = MockIsar();
      mockAuthRepository = MockIAuthRepository();
      userRepository = UserRepository(mockIsar, mockAuthRepository);
      mockUserCollection = MockUserCollection();
      mockQuery = MockUserQuery();

      when(mockIsar.users).thenReturn(mockUserCollection);
      when(mockUserCollection.filter()).thenReturn(mockQuery);
      when(mockQuery.uidEqualTo(any)).thenReturn(mockQuery);
    });

    test('getCurrentUser returns user from Isar when firebase user exists', () async {
      final mockFirebaseUser = MockFirebaseUser();
      when(mockFirebaseUser.uid).thenReturn('test_uid');
      when(mockAuthRepository.getCurrentUser()).thenReturn(mockFirebaseUser);

      final user = User()..uid = 'test_uid';
      when(mockQuery.findFirst()).thenAnswer((_) async => user);

      final result = await userRepository.getCurrentUser();

      expect(result, isA<User>());
      expect(result?.uid, 'test_uid');
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verify(mockQuery.findFirst()).called(1);
    });

    test('getCurrentUser returns null when firebase user does not exist', () async {
      when(mockAuthRepository.getCurrentUser()).thenReturn(null);

      final result = await userRepository.getCurrentUser();

      expect(result, isNull);
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verifyNever(mockIsar.users);
    });

    test('saveLocalUser calls Isar.writeTxn and puts user', () async {
      final user = User()..uid = 'new_user';
      when(mockIsar.writeTxn<int>(any)).thenAnswer((invocation) async {
        final callback = invocation.positionalArguments[0] as Future<int> Function();
        return await callback();
      });
      when(mockUserCollection.put(user)).thenAnswer((_) async => 1);

      await userRepository.saveLocalUser(user);

      verify(mockIsar.writeTxn(any)).called(1);
      verify(mockUserCollection.put(user)).called(1);
    });
  });
}