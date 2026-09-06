import 'dart:ui';

enum Language {
  system(languageName: 'System'),
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
  spanish(
    languageName: 'Spanish',
    languageCode: 'es', //Tây Ban Nha
    nativeLanguage: 'Española',
  ),
  french(
    languageName: 'French',
    languageCode: 'fr', //Pháp
    nativeLanguage: 'Français',
  ),
  hindi(
    languageName: 'Hindi',
    languageCode: 'hi', //Hindi
    nativeLanguage: 'हिंदी',
  ),
  russian(
    languageName: 'Russian',
    nativeLanguage: 'Pусский', //tiếng Nga
    languageCode: 'ru',
  ),
  german(
    languageName: 'German',
    nativeLanguage: 'Deutsch', //tiếng Đức
    languageCode: 'de',
  ),
  indonesian(
    languageName: 'Indonesian',
    nativeLanguage: 'Indonesian', //tiếng Indonesia
    languageCode: 'id',
  ),
  vietnamese(
    languageName: 'Vietnamese',
    languageCode: 'vi',
    nativeLanguage: 'Tiếng Việt',
  );

  const Language({
    required this.languageName,
    this.languageCode,
    this.scriptCode,
    this.nativeLanguage,
  });

  final String? languageCode;
  final String? scriptCode;
  final String languageName;
  final String? nativeLanguage;

  /// `null` lets Flutter resolve the locale from the operating system.
  Locale? get locale {
    final code = languageCode;
    if (code == null) return null;

    return Locale.fromSubtags(languageCode: code, scriptCode: scriptCode);
  }

  /// Stable value persisted by [LocalizationCubit].
  String get localeTag => locale?.toLanguageTag() ?? 'system';

  String get displayName => nativeLanguage ?? languageName;

  @override
  String toString() => languageName;
}

extension LanguageExtension on Language {
  String? get flagPath {
    switch (this) {
      case Language.system:
        return null;
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
      case Language.spanish:
        return 'es';
      case Language.french:
        return 'fr';
      case Language.hindi:
        return 'hi';
      case Language.russian:
        return 'ru';
      case Language.german:
        return 'de';
      case Language.indonesian:
        return 'id';
    }
  }
}
