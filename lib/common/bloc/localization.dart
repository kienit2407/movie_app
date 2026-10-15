import 'dart:ui';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/core/enum/language_enum.dart';

/// Chỉ được dùng làm giá trị mặc định khi HydratedBloc
/// chưa lưu ngôn ngữ trước đó.
Language _getInitialLanguage() {
  // Ví dụ:
  // Thiết bị Việt Nam     -> Locale('vi')
  // Thiết bị Nhật Bản     -> Locale('ja')
  // Thiết bị Trung Quốc   -> Locale('zh', 'CN')
  final deviceLocale = PlatformDispatcher.instance.locale;

  // Chỉ lấy mã chính:
  // vi-VN -> vi
  // en-US -> en
  // ja-JP -> ja
  final languageCode = deviceLocale.languageCode.toLowerCase();

  // Vì tiếng Trung có giản thể và phồn thể nên phải kiểm tra thêm.
  if (languageCode == 'zh') {
    final scriptCode = deviceLocale.scriptCode?.toLowerCase();
    final countryCode = deviceLocale.countryCode?.toUpperCase();

    // zh-Hant, zh-TW, zh-HK, zh-MO -> phồn thể.
    final isTraditional =
        scriptCode == 'hant' ||
        countryCode == 'TW' ||
        countryCode == 'HK' ||
        countryCode == 'MO';

    if (isTraditional) {
      return Language.chineseTraditional;
    }

    // Những locale zh còn lại mặc định là giản thể.
    return Language.chineseSimplified;
  }

  // Tìm ngôn ngữ thiết bị trong Language.values.
  //
  // Ví dụ thiết bị là vi:
  // Language.english.languageCode    == 'vi' -> false
  // Language.japanese.languageCode   == 'vi' -> false
  // Language.vietnamese.languageCode == 'vi' -> true
  //
  // Kết quả: Language.vietnamese
  return Language.values.firstWhere(
    (language) {
      return language.languageCode?.toLowerCase() == languageCode;
    },

    // Không tìm thấy nghĩa là app không hỗ trợ ngôn ngữ thiết bị.
    //
    // Ví dụ thiết bị dùng Arabic (`ar`) nhưng Language.values
    // không có Arabic -> trả về English.
    orElse: () => Language.english,
  );
}

class LocalizationCubit extends HydratedCubit<Language> {
  LocalizationCubit()
      // Bước 1: tạo giá trị mặc định từ ngôn ngữ thiết bị.
      //
      // Sau đó HydratedCubit tự kiểm tra storage:
      //
      // Có dữ liệu đã lưu:
      //   state = fromJson(dữ liệu đã lưu)
      //
      // Không có dữ liệu:
      //   state = _getInitialLanguage()
      //
      // HydratedCubit cũng tự lưu state này vào storage.
      : super(_getInitialLanguage());

  void changeLanguage(Language language) {
    // Ví dụ state hiện tại là Vietnamese.
    // Người dùng chọn Japanese:
    //
    // emit(Language.japanese)
    //          ↓
    // state đổi thành Japanese
    //          ↓
    // HydratedCubit gọi toJson(Language.japanese)
    //          ↓
    // Lưu {"localeTag": "ja"}
    if (language != state) {
      emit(language);
    }
  }

  @override
  Language fromJson(Map<String, dynamic> json) {
    // Ví dụ dữ liệu trong storage:
    //
    // {
    //   "localeTag": "vi"
    // }
    final localeTag = json['localeTag'];

    if (localeTag is String) {
      for (final language in Language.values) {
        // Vietnamese.localeTag == 'vi'
        // localeTag đã lưu       == 'vi'
        //
        // Khớp nhau -> trả về Language.vietnamese.
        if (language.localeTag.toLowerCase() ==
            localeTag.toLowerCase()) {
          return language;
        }
      }
    }

    // Dữ liệu cũ là "system", bị lỗi hoặc không còn được hỗ trợ:
    // đọc lại ngôn ngữ thiết bị.
    return _getInitialLanguage();
  }

  @override
  Map<String, dynamic> toJson(Language state) {
    // Language.vietnamese -> {"localeTag": "vi"}
    // Language.english    -> {"localeTag": "en"}
    // Chinese Simplified  -> {"localeTag": "zh-Hans"}
    // Chinese Traditional -> {"localeTag": "zh-Hant"}
    return {
      'localeTag': state.localeTag,
    };
  }
}
// TRƯỜNG HỢP 1
//
// Cài app lần đầu.
// Thiết bị dùng Vietnamese.
// Storage chưa có dữ liệu.
//
// _getInitialLanguage() -> Language.vietnamese
// HydratedBloc không tìm thấy dữ liệu cũ.
// state -> Language.vietnamese
// storage -> {"localeTag": "vi"}

// TRƯỜNG HỢP 2
//
// App đã lưu Vietnamese.
// Sau đó người dùng đổi thiết bị sang Japanese.
//
// _getInitialLanguage() -> Language.japanese
// Nhưng HydratedBloc tìm thấy {"localeTag": "vi"}.
// fromJson(...) -> Language.vietnamese
// state cuối cùng -> Language.vietnamese
//
// App không chạy theo ngôn ngữ thiết bị nữa.

// TRƯỜNG HỢP 3
//
// Cài app lần đầu.
// Thiết bị dùng Arabic (`ar`).
// App không hỗ trợ Arabic.
//
// Không tìm thấy `ar` trong Language.values.
// orElse() -> Language.english
// state -> Language.english
// storage -> {"localeTag": "en"}