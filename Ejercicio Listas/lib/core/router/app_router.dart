
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import 'package:tp4/screens/login_screen.dart';
import 'package:tp4/screens/home_screen.dart';
import 'package:tp4/screens/sign_in_screen.dart';
import 'package:tp4/screens/detail_screen.dart';
import 'package:tp4/core/router/entities/item.dart';

// Escuchar cambios de autenticación para actualizar GoRouter.
final _authRefresh = AuthRefreshListenable(
  FirebaseAuth.instance.authStateChanges(),
);

final appRouter = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authRefresh,

  // Controlar el acceso según la sesión.
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final loggedIn = user != null;

    final isAuthRoute =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/sign_in';

    if (!loggedIn && !isAuthRoute) {
      return '/login';
    }

    if (loggedIn && isAuthRoute) {
      return '/home';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) {
        final user = FirebaseAuth.instance.currentUser;

        return HomeScreen(
          username: user?.displayName ??
              user?.email ??
              'Usuario',
        );
      },
    ),

    GoRoute(
      path: '/sign_in',
      builder: (context, state) => const SignInScreen(),
    ),

    GoRoute(
      path: '/detail',
      builder: (context, state) {
        return DetailScreen(
          item: state.extra as Item,
        );
      },
    ),
  ],
);

// Adaptar el stream de Firebase a un Listenable.
class AuthRefreshListenable extends ChangeNotifier {
  late final StreamSubscription<User?> _subscription;

  AuthRefreshListenable(Stream<User?> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
