import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../../features/authentication/presentation/pages/forgot_password_page.dart';
import '../../features/authentication/presentation/pages/login_page.dart';
import '../../features/authentication/presentation/pages/register_page.dart';
import '../../features/authentication/presentation/pages/splash_page.dart';
import '../../features/claims/presentation/pages/my_claims_page.dart';
import '../../features/items/presentation/pages/create_found_page.dart';
import '../../features/items/presentation/pages/create_lost_page.dart';
import '../../features/items/presentation/pages/edit_item_page.dart';
import '../../features/items/presentation/pages/home_page.dart';
import '../../features/items/presentation/pages/item_details_page.dart';
import '../../features/items/presentation/pages/my_items_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/search/presentation/pages/search_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import 'app_routes.dart';
import 'go_router_refresh_stream.dart';
import 'route_guards.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.splash,

  // Re-evaluate redirect whenever Firebase auth state changes.
  // This ensures users are sent to /login immediately after signing out.
  refreshListenable: GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  ),

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
        final itemId = state.pathParameters['itemId'];

        if (itemId == null || itemId.isEmpty) {
          return const HomePage();
        }

        return ItemDetailsPage(itemId: itemId);
      },
    ),

    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const SearchPage(),
    ),

    GoRoute(
      path: AppRoutes.myItems,
      builder: (context, state) => const MyItemsPage(),
    ),

    GoRoute(
      path: '${AppRoutes.editItem}/:itemId',
      builder: (context, state) {
        final itemId = state.pathParameters['itemId'];

        if (itemId == null || itemId.isEmpty) {
          return const MyItemsPage();
        }

        return EditItemPage(itemId: itemId);
      },
    ),

    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfilePage(),
    ),

    GoRoute(
      path: AppRoutes.notifications,
      builder: (context, state) => const NotificationsPage(),
    ),

    GoRoute(
      path: AppRoutes.myClaims,
      builder: (context, state) => const MyClaimsPage(),
    ),

    GoRoute(
      path: AppRoutes.adminDashboard,
      builder: (context, state) => const AdminDashboardPage(),
    ),

    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
