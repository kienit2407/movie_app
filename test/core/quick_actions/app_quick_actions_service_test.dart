import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/quick_actions/app_quick_actions_service.dart';

void main() {
  group('AppQuickActionsService.routeForType', () {
    test('opens storage management and requests cache confirmation', () {
      final route = AppQuickActionsService.routeForType(
        AppQuickActionsService.clearCacheType,
      );

      expect(route, '${AppRoutes.storageManagement}?clearCache=true');
    });

    test('opens search and notifications destinations', () {
      expect(
        AppQuickActionsService.routeForType(AppQuickActionsService.searchType),
        AppRoutes.search,
      );
      expect(
        AppQuickActionsService.routeForType(
          AppQuickActionsService.notificationsType,
        ),
        AppRoutes.notifications,
      );
    });

    test('ignores unknown shortcut types', () {
      expect(AppQuickActionsService.routeForType('unknown'), isNull);
    });
  });
}
