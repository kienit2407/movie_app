import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/extension/filter_localization_extension.dart';
import 'package:movie_app/l10n/app_localizations.dart';

void main() {
  testWidgets('localizes API slugs and preserves unknown API names', (
    tester,
  ) async {
    late BuildContext context;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (builderContext) {
            context = builderContext;
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(context.filterGenreLabel('hanh-dong', 'Hành Động'), 'Action');
    expect(context.filterCountryLabel('viet-nam', 'Việt Nam'), 'Vietnam');
    expect(
      context.filterGenreLabel('the-loai-moi', 'Thể loại mới'),
      'Thể loại mới',
    );
  });

  test('ships genre and country translations for every supported locale', () {
    const genreSlugs = [
      'bi_an',
      'chien_tranh',
      'chinh_kich',
      'co_trang',
      'gia_dinh',
      'hai_huoc',
      'hanh_dong',
      'hinh_su',
      'hoc_duong',
      'khoa_hoc',
      'kinh_di',
      'kinh_dien',
      'lich_su',
      'mien_tay',
      'phim_18',
      'phim_ngan',
      'phieu_luu',
      'than_thoai',
      'the_thao',
      'tre_em',
      'tai_lieu',
      'tam_ly',
      'tinh_cam',
      'vien_tuong',
      'vo_thuat',
      'am_nhac',
    ];
    const countrySlugs = [
      'anh',
      'ba_lan',
      'brazil',
      'bo_dao_nha',
      'canada',
      'chau_phi',
      'ha_lan',
      'han_quoc',
      'hong_kong',
      'indonesia',
      'malaysia',
      'mexico',
      'na_uy',
      'nam_phi',
      'nga',
      'nhat_ban',
      'philippines',
      'phap',
      'quoc_gia_khac',
      'thai_lan',
      'tho_nhi_ky',
      'thuy_si',
      'thuy_dien',
      'trung_quoc',
      'tay_ban_nha',
      'uae',
      'ukraina',
      'viet_nam',
      'au_my',
      'uc',
      'y',
      'dan_mach',
      'dai_loan',
      'duc',
      'a_rap_xe_ut',
      'an_do',
    ];
    final expectations = <Locale, (String, String)>{
      const Locale('de'): ('Action', 'Vietnam'),
      const Locale('en'): ('Action', 'Vietnam'),
      const Locale('es'): ('Acción', 'Vietnam'),
      const Locale('fr'): ('Action', 'Vietnam'),
      const Locale('hi'): ('एक्शन', 'वियतनाम'),
      const Locale('id'): ('Aksi', 'Vietnam'),
      const Locale('ja'): ('アクション', 'ベトナム'),
      const Locale('ko'): ('액션', '베트남'),
      const Locale('ru'): ('Боевик', 'Вьетнам'),
      const Locale('th'): ('แอ็กชัน', 'เวียดนาม'),
      const Locale('vi'): ('Hành động', 'Việt Nam'),
      const Locale('zh'): ('动作', '越南'),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'): (
        '动作',
        '越南',
      ),
      const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'): (
        '動作',
        '越南',
      ),
    };

    for (final MapEntry(key: locale, value: expected) in expectations.entries) {
      final l10n = lookupAppLocalizations(locale);
      for (final slug in genreSlugs) {
        expect(
          l10n.filterGenreName(slug, '__fallback__'),
          isNot('__fallback__'),
          reason: '${locale.toLanguageTag()} genre $slug',
        );
      }
      for (final slug in countrySlugs) {
        expect(
          l10n.filterCountryName(slug, '__fallback__'),
          isNot('__fallback__'),
          reason: '${locale.toLanguageTag()} country $slug',
        );
      }
      expect(
        l10n.filterGenreName('hanh_dong', 'Hành Động'),
        expected.$1,
        reason: locale.toLanguageTag(),
      );
      expect(
        l10n.filterCountryName('viet_nam', 'Việt Nam'),
        expected.$2,
        reason: locale.toLanguageTag(),
      );
    }
  });
}
