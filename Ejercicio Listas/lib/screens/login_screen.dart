import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Lista de usuarios hardcodeada (se puede extender con usuarios guardados)
  Map<String, String> usuariosValidos = {
    'user': 'user123',
    'adm': 'adm123',
    'laika@gmail.com': 'pizza123',
    'thomas@gmail.com': '12345'
  };

  @override
  void initState() {
    super.initState();
    _loadStoredUsers();
  }

  Future<void> _loadStoredUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString('users');
    if (str != null && str.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(str);
        setState(() {
          usuariosValidos.addAll(decoded.map((k, v) => MapEntry(k, v.toString())));
        });
      } catch (_) {
        // ignore malformed data
      }
    }
  }

  String? errorEmail;
  String? errorPassword;
  String? errorLogin;

  void validar() {
    setState(() {
      errorEmail = null;
      errorPassword = null;
      errorLogin = null;

      String email = emailController.text.trim();
      String password = passwordController.text;

      if (email.isEmpty) {
        errorEmail = "Ingresa tu usuario o email";
      }

      if (password.isEmpty) {
        errorPassword = "Ingresa tu contraseña";
      }

      if (errorEmail == null && errorPassword == null) {
        if (usuariosValidos[email] == password) {
          // Uso de GoRouter para navegar a Home
          context.go('/home', extra: email);
        } else {
          errorLogin = "Usuario o contraseña incorrectos";
        }
      }
    });
  }

  Future<void> _openRegister() async {
    // Navegar a la pantalla de registro; al volver recargar usuarios guardados
    await context.push('/sign_in');
    await _loadStoredUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Iniciar sesión"),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Bienvenido",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Usuario o Email",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 1.3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 1.8),
                ),
                errorText: errorEmail,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 1.3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(width: 1.8),
                ),
                errorText: errorPassword,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
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
              onPressed: validar,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Ingresar",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                  onPressed: _openRegister,
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