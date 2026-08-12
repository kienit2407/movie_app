import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/home/notification/isolated_hive_bootstrap.dart';

void main() {
  test('concurrent callers share one initialization future', () async {
    final gate = Completer<void>();
    var initializationCount = 0;
    final bootstrap = IsolatedHiveBootstrap(
      initialize: () {
        initializationCount++;
        return gate.future;
      },
    );

    final first = bootstrap.ensureInitialized();
    final second = bootstrap.ensureInitialized();

    expect(identical(first, second), isTrue);
    expect(initializationCount, 1);

    gate.complete();
    await Future.wait([first, second]);
  });

  test('allows retry after initialization fails', () async {
    var initializationCount = 0;
    final bootstrap = IsolatedHiveBootstrap(
      initialize: () async {
        initializationCount++;
        if (initializationCount == 1) throw StateError('temporary failure');
      },
    );

    await expectLater(bootstrap.ensureInitialized(), throwsStateError);
    await bootstrap.ensureInitialized();

    expect(initializationCount, 2);
  });
}
