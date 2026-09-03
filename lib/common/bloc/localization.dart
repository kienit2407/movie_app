import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/core/enum/language_enum.dart';

class LocalizationCubit extends HydratedCubit<Language> {
  LocalizationCubit() : super(Language.vietnamese);

  void changeLanguage(Language language) {
    if (language != state) emit(language);
  }

  @override
  Language fromJson(Map<String, dynamic> json) {
    final localeTag = json['localeTag'];
    if (localeTag is String) {
      for (final language in Language.values) {
        if (language.localeTag.toLowerCase() == localeTag.toLowerCase()) {
          return language;
        }
      }
    }

    // Migration cho dữ liệu đã lưu trước khi locale dùng BCP-47.
    final languageCode = json['languageCode'];
    if (languageCode == 'am') return Language.chineseSimplified;
    if (languageCode == 'zh') return Language.chineseTraditional;
    return Language.values.firstWhere(
      (language) => language.languageCode == languageCode,
      orElse: () => Language.vietnamese,
    );
  }

  @override
  Map<String, dynamic> toJson(Language state) => <String, dynamic>{
    'localeTag': state.localeTag,
  };
}
