import 'package:firebase_auth/firebase_auth.dart';
import 'package:muevete/core/firebase/firebase_providers.dart';
import 'package:muevete/features/auth/domain/repositories/auth_repository.dart';
import 'package:muevete/features/auth/domain/repositories/firebase_auth_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class AuthNotifier extends _$AuthNotifier {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  User? build() {
    return _repository.currentUser;
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _repository.signIn(email, password);
    state = user;
  }

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    final user = await _repository.signUp(email, password);
    state = user;
    return user;
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = null;
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository(
    auth: ref.read(firebaseAuthProvider),
  );
}

@riverpod
Stream<User?> authState(Ref ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}