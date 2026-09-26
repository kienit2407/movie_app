import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/config/utils/format_episode.dart';
import 'package:movie_app/l10n/app_localizations.dart';

void main() {
  test('localizes a series runtime for every supported locale', () {
    final expectations = <Locale, String>{
      const Locale('de'): '70 Minuten/Folge',
      const Locale('en'): '70 minutes/episode',
      const Locale('es'): '70 minutos por episodio',
      const Locale('fr'): '70 minutes par épisode',
      const Locale('hi'): '70 मिनट प्रति एपिसोड',
      const Locale('id'): '70 menit/episode',
      const Locale('ja'): '70分/話',
      const Locale('ko'): '70분/회',
      const Locale('ru'): '70 минут на серию',
      const Locale('th'): '70 นาที/ตอน',
      const Locale('vi'): '70 phút/tập',
      const Locale('zh'): '70 分钟/集',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'):
          '70 分钟/集',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'):
          '70 分鐘/集',
    };

    for (final MapEntry(key: locale, value: expected) in expectations.entries) {
      final l10n = lookupAppLocalizations(locale);

      expect(
        '70 phút/tập'.toFormatEpisode(l10n, perEpisode: true),
        expected,
        reason: locale.toLanguageTag(),
      );
    }
  });

  test('keeps the API value when the runtime has no leading number', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      'Đang cập nhật'.toFormatEpisode(l10n, perEpisode: true),
      'Đang cập nhật',
    );
  });

  test('still formats a single movie runtime as hours and minutes', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect('70 phút'.toFormatEpisode(l10n), '1 hour 10 minutes');
  });

  test('localizes completed episode progress for every supported locale', () {
    final expectations = <Locale, String>{
      const Locale('de'): 'Abgeschlossen (16/16)',
      const Locale('en'): 'Completed (16/16)',
      const Locale('es'): 'Completado (16/16)',
      const Locale('fr'): 'Terminé (16/16)',
      const Locale('hi'): 'पूर्ण (16/16)',
      const Locale('id'): 'Selesai (16/16)',
      const Locale('ja'): '完結（16/16）',
      const Locale('ko'): '완결 (16/16)',
      const Locale('ru'): 'Завершено (16/16)',
      const Locale('th'): 'จบแล้ว (16/16)',
      const Locale('vi'): 'Hoàn tất (16/16)',
      const Locale('zh'): '已完结（16/16）',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'):
          '已完结（16/16）',
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'):
          '已完結（16/16）',
    };

    for (final MapEntry(key: locale, value: expected) in expectations.entries) {
      final l10n = lookupAppLocalizations(locale);
      expect(
        'Hoàn Tất (16/16)'.toLocalizedEpisodeLabel(l10n),
        expected,
        reason: locale.toLanguageTag(),
      );
    }
  });

  test('localizes API episode names in full and compact forms', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final ru = lookupAppLocalizations(const Locale('ru'));
    final ja = lookupAppLocalizations(const Locale('ja'));

    expect('Tập 01'.toLocalizedEpisodeLabel(en), 'Episode 1');
    expect('04'.toLocalizedEpisodeLabel(en), 'Episode 4');
    expect('Tập 02'.toLocalizedEpisodeShortLabel(ru), 'Эп.2');
    expect('Tập 03'.toLocalizedEpisodeLabel(ja), '第3話');
  });

  test('keeps unknown episode labels from the API unchanged', () {
    final en = lookupAppLocalizations(const Locale('en'));

    expect('Ngoại truyện'.toLocalizedEpisodeLabel(en), 'Ngoại truyện');
  });
}
