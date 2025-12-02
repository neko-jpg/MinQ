import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:minq/core/providers/core_providers.dart';
import 'package:minq/data/repositories/firebase_auth_repository.dart';
import 'package:minq/data/repositories/user_repository.dart';
import 'package:minq/domain/user/user.dart' as minq_user;

final firebaseAuthProvider = Provider<FirebaseAuth?>(
  (ref) =>
      ref.watch(firebaseAvailabilityProvider) ? FirebaseAuth.instance : null,
);

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(firebaseAuthProvider));
});

UserRepository _buildUserRepository(Ref ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw StateError('Isar instance is not yet initialised');
  }
  final authRepository = ref.watch(authRepositoryProvider);
  return UserRepository(isar, authRepository);
}

final userRepositoryProvider = Provider<UserRepository>(_buildUserRepository);

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

final guestUserIdProvider = StateProvider<String?>((ref) => null);

final localUserProvider = FutureProvider<minq_user.User?>((ref) async {
  final authState = ref.watch(authStateChangesProvider);
  final guestUid = ref.watch(guestUserIdProvider);
  return authState.when(
    data: (firebaseUser) async {
      final uid = firebaseUser?.uid ?? guestUid;
      if (uid == null) {
        return null;
      }
      return ref.watch(userRepositoryProvider).getUserById(uid);
    },
    error: (_, __) => Future.value(null),
    loading: () => Future.value(null),
  );
});

final uidProvider = Provider<String?>((ref) {
  final guestUid = ref.watch(guestUserIdProvider);
  if (guestUid != null) {
    return guestUid;
  }
  final authState = ref.watch(authStateChangesProvider);
  return authState.value?.uid;
});
