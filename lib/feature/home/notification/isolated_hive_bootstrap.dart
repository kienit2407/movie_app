import 'package:hive_ce_flutter/hive_flutter.dart';

typedef IsolatedHiveInitializer = Future<void> Function();

/// Coordinates IsolatedHive initialization once per Dart isolate.
///
/// Static fields are isolate-local, so the UI and each Workmanager isolate
/// still initialize independently while stores inside one isolate share the
/// same initialization future.
class IsolatedHiveBootstrap {
  IsolatedHiveBootstrap({IsolatedHiveInitializer? initialize})
    : _initialize = initialize ?? IsolatedHive.initFlutter;

  static final IsolatedHiveBootstrap shared = IsolatedHiveBootstrap();

  final IsolatedHiveInitializer _initialize;
  Future<void>? _initialization;

  Future<void> ensureInitialized() {
    return _initialization ??= _runInitialization();
  }

  Future<void> _runInitialization() async {
    try {
      await _initialize();
    } catch (_) {
      // A later call may retry after a transient initialization failure.
      _initialization = null;
      rethrow;
    }
  }
}
