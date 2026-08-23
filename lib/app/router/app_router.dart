import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/items/domain/entities/item_entity.dart';
import '../../features/items/presentation/pages/create_found_page.dart';
import '../../features/items/presentation/pages/create_lost_page.dart';
import '../../features/items/presentation/pages/home_page.dart';
import '../../features/items/presentation/pages/item_details_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import 'app_routes.dart';
import 'route_guards.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  redirect: (context, state) {
    return authGuard(state.matchedLocation);
  },

  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginPage(),
    ),

    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterPage(),
    ),

    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordPage(),
    ),

    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),

    GoRoute(
      path: AppRoutes.createLost,
      builder: (context, state) => const CreateLostPage(),
    ),

    GoRoute(
      path: AppRoutes.createFound,
      builder: (context, state) => const CreateFoundPage(),
    ),

    GoRoute(
      path: '${AppRoutes.itemDetails}/:itemId',
      builder: (context, state) {
        final item = state.extra as ItemEntity;

        return ItemDetailsPage(item: item);
      },
    ),

    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchPage(),
    ),
  ],
);
