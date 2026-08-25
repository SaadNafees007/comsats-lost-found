import 'dart:async';

import 'package:flutter/foundation.dart';

/// A [ChangeNotifier] that triggers whenever a [Stream] emits a value.
/// Used to notify [GoRouter] to re-evaluate its redirect guard whenever
/// Firebase auth state changes (login / logout).
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
