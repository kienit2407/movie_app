import 'dart:ui';

enum Language {
  english(languageName: 'English', languageCode: 'en'),
  chineseSimplified(
    languageName: 'Chinese (Simplified)',
    languageCode: 'zh',
    scriptCode: 'Hans',
    nativeLanguage: '简体中文',
  ),
  chineseTraditional(
    languageName: 'Chinese (Traditional)',
    languageCode: 'zh',
    scriptCode: 'Hant',
    nativeLanguage: '繁體中文',
  ),
  korean(languageName: 'Korean', nativeLanguage: '한국어', languageCode: 'ko'),
  japanese(languageName: 'Japanese', nativeLanguage: '日本語', languageCode: 'ja'),
  thai(languageName: 'Thai', nativeLanguage: 'ไทย', languageCode: 'th'),
  vietnamese(
    languageName: 'Vietnamese',
    languageCode: 'vi',
    nativeLanguage: 'Tiếng Việt',
  );

  const Language({
    required this.languageCode,
    required this.languageName,
    this.scriptCode,
    this.countryCode,
    this.nativeLanguage,
  });

  final String languageCode;
  final String? scriptCode;
  final String? countryCode;
  final String languageName;
  final String? nativeLanguage;

  Locale get locale => Locale.fromSubtags(
    languageCode: languageCode,
    scriptCode: scriptCode,
    countryCode: countryCode,
  );

  /// Mã BCP-47 dùng để lưu cấu hình, ví dụ `zh-Hans`, `pt-BR`, `pt-PT`.
  String get localeTag => locale.toLanguageTag();

  String get displayName => nativeLanguage ?? languageName;

  @override
  String toString() => languageName;
}

extension LanguageExtension on Language {
  String get flagPath {
    switch (this) {
      case Language.english:
        return 'en';
      case Language.japanese:
        return 'ja';
      case Language.korean:
        return 'ko';
      case Language.chineseSimplified:
        return 'zh';
      case Language.chineseTraditional:
        return 'zh';
      case Language.thai:
        return 'th';
      case Language.vietnamese:
        return 'vi';
    }
  }
}
