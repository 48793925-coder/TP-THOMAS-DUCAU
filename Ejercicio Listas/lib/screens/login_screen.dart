
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String? errorEmail;
  String? errorPassword;
  String? errorLogin;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> validar() async {
    setState(() {
      errorEmail = null;
      errorPassword = null;
      errorLogin = null;
    });

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      setState(() => errorEmail = 'Ingresa tu email');
    } else if (!RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email)) {
      setState(() => errorEmail = 'Ingresa un email válido');
    }

    if (password.isEmpty) {
      setState(() => errorPassword = 'Ingresa tu contraseña');
    }

    if (errorEmail != null || errorPassword != null) {
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      context.go('/home');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() => errorLogin = _getErrorMessage(e));
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorLogin = 'No se pudo iniciar sesión. Intentá nuevamente.';
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El email no tiene un formato válido.';

      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'El email o la contraseña son incorrectos.';

      case 'user-disabled':
        return 'Esta cuenta está deshabilitada.';

      case 'too-many-requests':
        return 'Demasiados intentos. Probá más tarde.';

      case 'network-request-failed':
        return 'No se pudo conectar. Revisá tu conexión.';

      default:
        return 'No se pudo iniciar sesión.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: errorEmail,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: errorPassword,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
              ),
            ),

            const SizedBox(height: 12),

            if (errorLogin != null)
              Text(
                errorLogin!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),

            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: isLoading ? null : validar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text(
                      'Ingresar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('¿No tienes cuenta?'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => context.push('/sign_in'),
                  child: const Text('Registrarse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
