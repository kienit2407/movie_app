import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/core/enum/language_enum.dart';
import 'package:movie_app/l10n/app_localizations.dart';

void main() {
  late _MemoryStorage storage;

  setUp(() {
    storage = _MemoryStorage();
    HydratedBloc.storage = storage;
  });

  test(
    'defaults to the device language when no preference is stored',
    () async {
      final cubit = LocalizationCubit();

      expect(cubit.state, Language.system);
      expect(cubit.state.locale, isNull);
      expect(cubit.state.localeTag, 'system');

      await cubit.close();
    },
  );

  test('restores the selected language from hydrated storage', () async {
    final firstCubit = LocalizationCubit();
    firstCubit.changeLanguage(Language.english);
    await firstCubit.close();

    final restoredCubit = LocalizationCubit();
    expect(restoredCubit.state, Language.english);

    await restoredCubit.close();
  });

  test('persists the device-language preference', () async {
    final firstCubit = LocalizationCubit();
    firstCubit.changeLanguage(Language.english);
    firstCubit.changeLanguage(Language.system);
    await firstCubit.close();

    final restoredCubit = LocalizationCubit();
    expect(restoredCubit.state, Language.system);
    expect(restoredCubit.state.locale, isNull);

    await restoredCubit.close();
  });

  testWidgets('system preference follows the device locale', (tester) async {
    tester.binding.platformDispatcher.localesTestValue = const <Locale>[
      Locale('hi'),
    ];
    addTearDown(tester.binding.platformDispatcher.clearLocalesTestValue);

    final cubit = LocalizationCubit();
    addTearDown(cubit.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: BlocBuilder<LocalizationCubit, Language>(
          builder: (context, language) => MaterialApp(
            locale: language.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Builder(
              builder: (context) =>
                  Text(Localizations.localeOf(context).toLanguageTag()),
            ),
          ),
        ),
      ),
    );

    expect(find.text('hi'), findsOneWidget);

    cubit.changeLanguage(Language.english);
    await tester.pumpAndSettle();

    expect(find.text('en'), findsOneWidget);
  });

  test('unsupported device locale falls back to Vietnamese', () {
    final resolvedLocale = basicLocaleListResolution(const <Locale>[
      Locale('ar'),
    ], AppLocalizations.supportedLocales);

    expect(resolvedLocale, const Locale('vi'));
  });

  test('keeps simplified and traditional Chinese as distinct locales', () {
    final cubit = LocalizationCubit();
    addTearDown(cubit.close);

    expect(Language.chineseSimplified.localeTag, 'zh-Hans');
    expect(Language.chineseTraditional.localeTag, 'zh-Hant');
    expect(
      cubit.fromJson(const <String, dynamic>{'localeTag': 'zh-Hans'}),
      Language.chineseSimplified,
    );
    expect(
      cubit.fromJson(const <String, dynamic>{'localeTag': 'zh-Hant'}),
      Language.chineseTraditional,
    );
  });

  test('migrates legacy Chinese locale codes', () {
    final cubit = LocalizationCubit();
    addTearDown(cubit.close);

    expect(
      cubit.fromJson(const <String, dynamic>{'languageCode': 'am'}),
      Language.chineseSimplified,
    );
    expect(
      cubit.fromJson(const <String, dynamic>{'languageCode': 'zh'}),
      Language.chineseTraditional,
    );
  });

  test('falls back safely when a stored language is unsupported', () async {
    final cubit = LocalizationCubit();

    expect(
      cubit.fromJson(const <String, dynamic>{'languageCode': 'xx'}),
      Language.system,
    );

    await cubit.close();
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
