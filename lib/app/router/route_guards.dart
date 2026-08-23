import 'package:firebase_auth/firebase_auth.dart';

import 'app_routes.dart';

String? authGuard(String? location) {
  final user = FirebaseAuth.instance.currentUser;

  final isAuthenticated = user != null;

  final isAuthRoute =
      location == AppRoutes.login ||
      location == AppRoutes.register ||
      location == AppRoutes.forgotPassword;

  final isSplashRoute = location == AppRoutes.splash;

  if (isSplashRoute) {
    return null;
  }

  if (!isAuthenticated && !isAuthRoute) {
    return AppRoutes.login;
  }

  if (isAuthenticated && isAuthRoute) {
    return AppRoutes.home;
  }

  return null;
}
