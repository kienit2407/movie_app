import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/language_page.dart';

import 'helpers/localized_test_app.dart';

void main() {
  testWidgets(
    'language header stays pinned and gains a glass surface on scroll',
    (tester) async {
      HydratedBloc.storage = _MemoryStorage();
      final cubit = LocalizationCubit();
      addTearDown(cubit.close);

      await tester.binding.setSurfaceSize(const Size(390, 180));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: localizedTestApp(home: const LanguagePage()),
        ),
      );

      final appBar = tester.widget<SliverAppBar>(find.byType(SliverAppBar));
      expect(appBar.pinned, isTrue);
      expect(appBar.backgroundColor, Colors.transparent);

      BoxDecoration headerDecoration() {
        return tester
                .widget<AnimatedContainer>(
                  find.byKey(const ValueKey('language-header-surface')),
                )
                .decoration!
            as BoxDecoration;
      }

      expect(headerDecoration().color, Colors.transparent);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(find.text('Ngôn ngữ ứng dụng'), findsOneWidget);
      expect(headerDecoration().color, isNot(Colors.transparent));
    },
  );
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
