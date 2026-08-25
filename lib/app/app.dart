import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_mode_provider.dart';

class ComsatsLostFoundApp extends ConsumerWidget {
  const ComsatsLostFoundApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'COMSATS Lost & Found',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Smooth theme transition — eliminates the glitch on mode change
      themeAnimationDuration: const Duration(milliseconds: 350),
      themeAnimationCurve: Curves.easeInOut,

      routerConfig: appRouter,
    );
  }
}
