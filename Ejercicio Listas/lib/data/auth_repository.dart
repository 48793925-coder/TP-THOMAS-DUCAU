
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  // Escuchar los cambios de sesión.
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }

  // Registrar un usuario.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('No se pudo crear el usuario.');
    }

    // Asociar el nombre al perfil de Authentication.
    await user.updateDisplayName(name.trim());

    // Guardar los datos del perfil en Firestore.
    await _firestore
        .collection('users')
        .doc(user.uid)
        .set({
      'name': name.trim(),
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Iniciar sesión.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Cerrar sesión.
  Future<void> logout() async {
    await _auth.signOut();
  }
}
