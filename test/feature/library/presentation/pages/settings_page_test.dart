import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/feature/auth/data/saved_account_store.dart';
import 'package:movie_app/feature/auth/presentation/session/saved_accounts_cubit.dart';
import 'package:movie_app/feature/library/presentation/pages/settings_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../helpers/localized_test_app.dart';

void main() {
  testWidgets('settings header stays pinned and gains glass on scroll', (
    tester,
  ) async {
    HydratedBloc.storage = _MemoryStorage();
    FlutterSecureStorage.setMockInitialValues(const <String, String>{});

    final localizationCubit = LocalizationCubit();
    final accountsCubit = SavedAccountsCubit(
      store: SavedAccountStore(),
      client: SupabaseClient(
        'https://settings-test.supabase.co',
        'settings-test-anon-key',
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      ),
    );
    addTearDown(localizationCubit.close);
    addTearDown(accountsCubit.close);

    await tester.binding.setSurfaceSize(const Size(390, 180));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: localizationCubit),
          BlocProvider.value(value: accountsCubit),
        ],
        child: localizedTestApp(home: const SettingsPage()),
      ),
    );
    await tester.pump();

    final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
    expect(appBar.pinned, isTrue);
    expect(appBar.backgroundColor, Colors.transparent);

    BoxDecoration headerDecoration() {
      return tester
              .widget<AnimatedContainer>(
                find.byKey(const ValueKey('settings-header-surface')),
              )
              .decoration!
          as BoxDecoration;
    }

    expect(headerDecoration().color, Colors.transparent);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
    await tester.pumpAndSettle();

    expect(find.text('Cài đặt'), findsOneWidget);
    expect(headerDecoration().color, isNot(Colors.transparent));
  });
}

class _MemoryStorage implements Storage {
  final Map<String, dynamic> _values = <String, dynamic>{};

  @override
  dynamic read(String key) => _values[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> clear() async {
    _values.clear();
  }

  @override
  Future<void> close() async {}
}
