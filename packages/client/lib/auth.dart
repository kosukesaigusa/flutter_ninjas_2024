import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth.g.dart';

@riverpod
FirebaseAuth _firebaseAuth(_FirebaseAuthRef _) => FirebaseAuth.instance;

@riverpod
Stream<User?> authUser(AuthUserRef ref) =>
    ref.watch(_firebaseAuthProvider).userChanges();

@riverpod
String? currentUserId(CurrentUserIdRef ref) {
  ref.watch(_firebaseAuthProvider).userChanges();
  return ref.watch(_firebaseAuthProvider).currentUser?.uid;
}

@riverpod
class Auth extends _$Auth {
  @override
  Future<User?> build() async => null;

  Future<void> signInAnonymously() async {
    state = const AsyncLoading<User?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      return userCredential.user;
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading<User?>().copyWithPrevious(state);
    state = await AsyncValue.guard(() async {
      await FirebaseAuth.instance.signOut();
      return null;
    });
  }
}
