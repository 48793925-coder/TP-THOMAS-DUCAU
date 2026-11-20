
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/auth_repository.dart';

// Firebase Authentication.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Cloud Firestore.
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Repositorio.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
});

// Escuchar el estado de autenticación.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

// Controlador de autenticación.
final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Registro.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _execute(() {
      return ref.read(authRepositoryProvider).register(
        name: name,
        email: email,
        password: password,
      );
    });
  }

  // Login.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _execute(() {
      return ref.read(authRepositoryProvider).login(
        email: email,
        password: password,
      );
    });
  }

  // Logout.
  Future<void> logout() async {
    await _execute(() {
      return ref.read(authRepositoryProvider).logout();
    });
  }

  // Administrar estados de carga y errores.
  Future<void> _execute(
    Future<void> Function() action,
  ) async {
    state = const AsyncLoading<void>();

    try {
      await action();
      state = const AsyncData<void>(null);
    } catch (error, stackTrace) {
      state = AsyncError<void>(error, stackTrace);
      rethrow;
    }
  }
}
