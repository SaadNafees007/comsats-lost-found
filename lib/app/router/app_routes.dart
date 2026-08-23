class AppRoutes {
  AppRoutes._();

  // ===========================
  // Root
  // ===========================

  static const String splash = '/';

  // ===========================
  // Authentication
  // ===========================

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // ===========================
  // Main Application
  // ===========================

  static const String home = '/home';

  // ===========================
  // Items
  // ===========================

  static const String createLost = '/items/create-lost';
  static const String createFound = '/items/create-found';
  static const String itemDetails = '/items/details';
  static const String editItem = '/items/edit';
  static const String myItems = '/items/my-items';

  // ===========================
  // Search
  // ===========================

  static const String search = '/search';

  // ===========================
  // Profile
  // ===========================

  static const String profile = '/profile';

  // ===========================
  // Notifications
  // ===========================

  static const String notifications = '/notifications';

  // ===========================
  // Settings
  // ===========================

  static const String settings = '/settings';
}
