import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/core/enum/language_enum.dart';

void main() {
  late _MemoryStorage storage;

  setUp(() {
    storage = _MemoryStorage();
    HydratedBloc.storage = storage;
  });

  test('defaults to Vietnamese when no preference is stored', () async {
    final cubit = LocalizationCubit();

    expect(cubit.state, Language.vietnamese);

    await cubit.close();
  });

  test('restores the selected language from hydrated storage', () async {
    final firstCubit = LocalizationCubit();
    firstCubit.changeLanguage(Language.english);
    await firstCubit.close();

    final restoredCubit = LocalizationCubit();
    expect(restoredCubit.state, Language.english);

    await restoredCubit.close();
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
      cubit.fromJson(const <String, dynamic>{'languageCode': 'fr'}),
      Language.vietnamese,
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
