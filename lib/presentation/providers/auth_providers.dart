import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minq/data/providers.dart';

final uidProvider = Provider<String?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.asData?.value?.uid;
});
