// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'ดูหนังได้ทุกที่ ทุกเวลา';

  @override
  String get commonAgree => 'ตกลง';

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonClose => 'ปิด';

  @override
  String get commonDone => 'เสร็จสิ้น';

  @override
  String get commonSave => 'บันทึก';

  @override
  String get commonDelete => 'ลบ';

  @override
  String get commonEdit => 'แก้ไข';

  @override
  String get commonReport => 'รายงาน';

  @override
  String get commonRetry => 'ลองอีกครั้ง';

  @override
  String get commonReset => 'รีเซ็ต';

  @override
  String get commonAll => 'ทั้งหมด';

  @override
  String get commonSeeMore => 'ดูเพิ่มเติม';

  @override
  String get commonCollapse => 'ย่อ';

  @override
  String get commonLoading => 'กำลังโหลด...';

  @override
  String get commonUpdating => 'กำลังอัปเดต';

  @override
  String get commonUnderstood => 'เข้าใจแล้ว';

  @override
  String get commonNoData => 'ไม่มีข้อมูล';

  @override
  String get commonNotAvailable => 'ไม่มีข้อมูล';

  @override
  String get commonWarningTitle => 'คำเตือน';

  @override
  String get commonNoticeTitle => 'แจ้งเตือน';

  @override
  String get commonCongratulationsTitle => 'ยินดีด้วย!';

  @override
  String get commonBack => 'ย้อนกลับ';

  @override
  String get commonGoHome => 'ไปหน้าหลัก';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'เลือกแล้ว $count รายการ',
      zero: 'ยังไม่ได้เลือก',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'ข้อผิดพลาด: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    return '$hours ชั่วโมง $minutes นาที';
  }

  @override
  String get settingsLanguage => 'ภาษา';

  @override
  String get settingsLanguageSystem => 'ใช้ภาษาของอุปกรณ์';

  @override
  String get settingsLanguageVietnamese => 'Tiếng Việt';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageJapanese => '日本語';

  @override
  String get settingsLanguageThai => 'ไทย';

  @override
  String get settingsLanguageKorean => '한국어';

  @override
  String get settingsLanguageChineseSimplified => '简体中文';

  @override
  String get settingsLanguageChineseTraditional => '繁體中文';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String get settingsGeneralSection => 'ทั่วไป';

  @override
  String get settingsAppLanguage => 'ภาษาของแอป';

  @override
  String get settingsAccountSection => 'บัญชี';

  @override
  String get settingsSwitchAccount => 'สลับบัญชี';

  @override
  String get settingsAddAccount => 'เพิ่มบัญชี';

  @override
  String get settingsAccountSwitchFailed =>
      'ไม่สามารถสลับบัญชีได้ โปรดลงชื่อเข้าใช้บัญชีนั้นอีกครั้ง';

  @override
  String get settingsSignOutFailed => 'ไม่สามารถออกจากระบบได้ โปรดลองอีกครั้ง';

  @override
  String get navHome => 'หน้าหลัก';

  @override
  String get navSearch => 'ค้นหา';

  @override
  String get navFavorites => 'รายการโปรด';

  @override
  String get navProfile => 'โปรไฟล์';

  @override
  String get navNotifications => 'การแจ้งเตือน';

  @override
  String get internetOffline => 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';

  @override
  String get internetBackOnline => 'กลับมาออนไลน์แล้ว';

  @override
  String get authJoinMember => 'เข้าร่วมเป็นสมาชิก';

  @override
  String get authSignInTitle => 'ลงชื่อเข้าใช้ Liquid Phim';

  @override
  String get authSignIn => 'ลงชื่อเข้าใช้';

  @override
  String get authSignInFailed => 'ลงชื่อเข้าใช้ไม่สำเร็จ โปรดลองอีกครั้ง';

  @override
  String get authSignInToComment =>
      'ลงชื่อเข้าใช้เพื่อแสดงความคิดเห็นและมีส่วนร่วมกับชุมชน';

  @override
  String get authGoogleSyncDescription =>
      'ดำเนินการต่อด้วย Google เพื่อซิงค์บัญชีและเข้าร่วมชุมชน';

  @override
  String get authGoogleConsent =>
      'เมื่อดำเนินการต่อ คุณยอมรับการใช้บัญชี Google ของคุณกับ Liquid Phim';

  @override
  String get authContinueWithGoogle => 'ดำเนินการต่อด้วย Google';

  @override
  String get authGoogleSignInFailed =>
      'ไม่สามารถลงชื่อเข้าใช้ด้วย Google ได้ โปรดลองอีกครั้ง';

  @override
  String get authGoogleSignInCheckFailed =>
      'ไม่สามารถลงชื่อเข้าใช้ด้วย Google ได้ โปรดตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get authSessionUpdateFailed =>
      'ไม่สามารถอัปเดตเซสชันการลงชื่อเข้าใช้ได้';

  @override
  String get authLoginRequired => 'คุณต้องลงชื่อเข้าใช้';

  @override
  String get authLoginRequiredForAction =>
      'คุณต้องลงชื่อเข้าใช้เพื่อดำเนินการนี้';

  @override
  String get authEmail => 'อีเมล';

  @override
  String get authPassword => 'รหัสผ่าน';

  @override
  String get authFullName => 'ชื่อ-นามสกุล';

  @override
  String get authForgotPassword => 'ลืมรหัสผ่าน?';

  @override
  String get authOrContinueWith => 'หรือดำเนินการต่อด้วย';

  @override
  String get authAlreadyHaveAccount => 'มีบัญชีอยู่แล้ว?';

  @override
  String get authFullNameRequired => 'กรุณากรอกชื่อ-นามสกุล';

  @override
  String get authFullNameLength =>
      'ชื่อ-นามสกุลต้องมีความยาว 3 ถึง 15 ตัวอักษร';

  @override
  String get authEmailRequired => 'กรุณากรอกอีเมล';

  @override
  String get authEmailInvalid => 'กรุณากรอกอีเมลที่ถูกต้อง';

  @override
  String get authPasswordRequired => 'กรุณากรอกรหัสผ่าน';

  @override
  String get authPasswordLength => 'รหัสผ่านต้องมีความยาว 6 ถึง 15 ตัวอักษร';

  @override
  String get authAccountAlreadyExists => 'มีบัญชีนี้อยู่แล้ว โปรดใช้อีเมลอื่น';

  @override
  String get authWeakPassword =>
      'รหัสผ่านนี้ไม่ปลอดภัยเพียงพอ โปรดใช้รหัสผ่านที่แข็งแรงขึ้น';

  @override
  String get authInvalidCredentials =>
      'อีเมลหรือรหัสผ่านไม่ถูกต้อง โปรดลองอีกครั้ง';

  @override
  String get authUnexpectedError => 'เกิดข้อผิดพลาด โปรดลองอีกครั้ง';

  @override
  String get authSignUpFailed => 'ไม่สามารถสร้างบัญชีได้ โปรดลองอีกครั้ง';

  @override
  String get authSignUpSucceeded => 'สร้างบัญชีเรียบร้อยแล้ว';

  @override
  String get authSignInSucceeded => 'ลงชื่อเข้าใช้สำเร็จ';

  @override
  String get authSignOutSucceeded => 'ออกจากระบบสำเร็จ';

  @override
  String get authTokenConfirmed => 'ยืนยันรหัสเรียบร้อยแล้ว';

  @override
  String get authTokenInvalid => 'รหัสยืนยันไม่ถูกต้อง';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      'ต้องการรับการแจ้งเตือนหนังใหม่หรือไม่?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim สามารถตรวจสอบเป็นระยะในเบื้องหลังและแจ้งเตือนเมื่อพบหนังใหม่ ระบบปฏิบัติการอาจหน่วงการตรวจสอบเกิน 20 นาทีเพื่อประหยัดแบตเตอรี่';

  @override
  String get homeEnableNotifications => 'เปิดการแจ้งเตือน';

  @override
  String get homeDoNotEnable => 'ไว้ภายหลัง';

  @override
  String get homeNotificationPermissionDisabled =>
      'สิทธิ์การแจ้งเตือนถูกปิดอยู่ คุณสามารถเปิดอีกครั้งได้ในการตั้งค่าโทรศัพท์';

  @override
  String get homeLoadMoviesFailed =>
      'ไม่สามารถโหลดหนังได้\nลากลงเพื่อลองอีกครั้ง';

  @override
  String get homeRecommended => 'แนะนำ';

  @override
  String get homeGenres => 'ประเภท';

  @override
  String get homeCountries => 'ประเทศ';

  @override
  String get homeYear => 'ปี';

  @override
  String get homeFreshMovies => 'หนังมาใหม่!';

  @override
  String get homeKoreanMovies => 'หนังเกาหลี';

  @override
  String get homeChineseMovies => 'หนังจีน';

  @override
  String get homeUsUkMovies => 'หนังสหรัฐฯ และอังกฤษ';

  @override
  String get homeWatchMovie => 'รับชม';

  @override
  String get homeInformation => 'ข้อมูล';

  @override
  String get homeViewAll => 'ดูทั้งหมด';

  @override
  String get homeWhatToWatch => 'วันนี้อยากดูอะไร?';

  @override
  String get homeViewMore => 'ดูเพิ่มเติม';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'เวอร์ชัน: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'ประเภทเนื้อหา';

  @override
  String get filterSeries => 'ซีรีส์';

  @override
  String get filterSingleMovies => 'ภาพยนตร์';

  @override
  String get filterAnimation => 'แอนิเมชัน';

  @override
  String get filterTvShows => 'รายการทีวี';

  @override
  String get filterSubtitled => 'ซับไตเติล';

  @override
  String get filterVoiceOver => 'พากย์บรรยาย';

  @override
  String get filterDubbed => 'พากย์เสียง';

  @override
  String get filterChooseMovieType => 'โปรดเลือกประเภทเนื้อหา';

  @override
  String get filterChooseGenre => 'โปรดเลือกประเภท';

  @override
  String get filterChooseCountry => 'เลือกประเทศที่ต้องการกรอง';

  @override
  String get filterChooseYear => 'เลือกปีที่ต้องการกรอง';

  @override
  String get filterLanguage => 'ภาษา';

  @override
  String get filterSortBy => 'เรียงตาม';

  @override
  String get filterSortDirection => 'ทิศทางการเรียง';

  @override
  String get filterDescending => 'มากไปน้อย';

  @override
  String get filterAscending => 'น้อยไปมาก';

  @override
  String get filterMostViewed => 'ยอดชมสูงสุด';

  @override
  String get filterNewest => 'ใหม่ล่าสุด';

  @override
  String get filterReleaseYear => 'ปีที่ออกฉาย';

  @override
  String get filterApply => 'ใช้ตัวกรอง';

  @override
  String get filterResults => 'ผลการกรอง';

  @override
  String get searchAttentionTitle => 'โปรดทราบ';

  @override
  String get searchEnterKeywordBeforeFiltering => 'กรุณากรอกคำค้นก่อนกรองหนัง';

  @override
  String get searchNoResults => 'ไม่พบผลลัพธ์';

  @override
  String get searchMovieActorHint => 'ค้นหาหนัง นักแสดง...';

  @override
  String get searchFilterTooltip => 'ตัวกรองการค้นหา';

  @override
  String get searchStartPrompt => 'กรอกชื่อหนังเพื่อเริ่มค้นหา';

  @override
  String get searchRecent => 'การค้นหาล่าสุด';

  @override
  String get searchLoadingGenres => 'กำลังโหลดประเภท...';

  @override
  String get searchLoadingCountries => 'กำลังโหลดประเทศ...';

  @override
  String get searchNoMovies => 'ไม่มีหนัง';

  @override
  String get searchTryDifferentFilters => 'ลองใช้ตัวกรองอื่น';

  @override
  String get librarySignOutTitle => 'ออกจากระบบหรือไม่?';

  @override
  String get librarySignOutConfirmation =>
      'คุณแน่ใจหรือไม่ว่าต้องการออกจากบัญชีนี้?';

  @override
  String get librarySignOut => 'ออกจากระบบ';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    return 'ลบหนังที่เลือก $count เรื่องหรือไม่?';
  }

  @override
  String get libraryDeleteHistoryMovieTitle =>
      'ลบหนังเรื่องนี้ออกจากประวัติหรือไม่?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    return 'ลบหนัง $count เรื่องออกจากประวัติการรับชมหรือไม่?';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle =>
      'นำหนังเรื่องนี้ออกจากรายการโปรดหรือไม่?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    return 'นำหนัง $count เรื่องออกจากรายการโปรดหรือไม่?';
  }

  @override
  String get libraryCancelSelection => 'ยกเลิกการเลือก';

  @override
  String get libraryDeleteSelectedMovies => 'ลบหนังที่เลือก';

  @override
  String get libraryCannotResumeMovie =>
      'ไม่สามารถเล่นหนังเรื่องนี้ต่อได้ในขณะนี้';

  @override
  String get libraryYourProfile => 'โปรไฟล์ของคุณ';

  @override
  String get librarySignInProfileDescription =>
      'ลงชื่อเข้าใช้เพื่อแก้ไขโปรไฟล์และซิงค์ประวัติการรับชม';

  @override
  String get libraryWatchHistory => 'ประวัติการรับชม';

  @override
  String get libraryNoWatchHistory => 'ยังไม่มีประวัติการรับชม';

  @override
  String get libraryFavorites => 'รายการโปรด';

  @override
  String get librarySignInToSaveFavorites => 'ลงชื่อเข้าใช้เพื่อบันทึกหนังโปรด';

  @override
  String get libraryFavoritesSyncDescription =>
      'รายการของคุณจะซิงค์ระหว่างอุปกรณ์ต่าง ๆ';

  @override
  String get libraryNoFavorites => 'ยังไม่มีหนังในรายการโปรด';

  @override
  String get libraryRemoveFromList => 'นำออกจากรายการ';

  @override
  String libraryContinueProgress(int progress) {
    return 'ดูต่อจาก $progress%';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed => 'ไม่สามารถโหลดคลังของคุณได้ โปรดลองอีกครั้ง';

  @override
  String get libraryFavoriteUpdateFailed =>
      'ไม่สามารถอัปเดตรายการโปรดได้ โปรดลองอีกครั้ง';

  @override
  String get libraryFavoriteRemoveFailed =>
      'ไม่สามารถนำออกจากรายการโปรดได้ โปรดลองอีกครั้ง';

  @override
  String get libraryHistorySyncLater => 'ประวัติของคุณจะซิงค์อีกครั้งในภายหลัง';

  @override
  String get libraryHistoryDeleteFailed =>
      'ไม่สามารถลบประวัติการรับชมได้ โปรดลองอีกครั้ง';

  @override
  String get profileEdit => 'แก้ไขโปรไฟล์';

  @override
  String get profileChangePhoto => 'เปลี่ยนรูป';

  @override
  String get profileName => 'ชื่อ';

  @override
  String get profileNameDescription =>
      'ชื่อนี้จะแสดงบนโปรไฟล์ Liquid Phim ของคุณ';

  @override
  String get profileNameHint => 'กรอกชื่อที่แสดง';

  @override
  String get profileClearName => 'ล้างชื่อ';

  @override
  String get profileEmailDescription =>
      'อีเมลนี้เชื่อมโยงกับบัญชีของคุณและจะแสดงเฉพาะที่นี่';

  @override
  String get profileChangeAvatar => 'เปลี่ยนรูปโปรไฟล์';

  @override
  String get profileTakePhoto => 'ถ่ายรูป';

  @override
  String get profileUploadPhoto => 'อัปโหลดรูป';

  @override
  String get profileViewPhoto => 'ดูรูป';

  @override
  String get profileAvatar => 'รูปโปรไฟล์';

  @override
  String get profileCropAvatar => 'ครอปรูปโปรไฟล์';

  @override
  String get profileAvatarUpdated => 'อัปเดตรูปโปรไฟล์แล้ว';

  @override
  String get profileAvatarUpdateFailed =>
      'ไม่สามารถอัปเดตรูปโปรไฟล์ได้ โปรดลองอีกครั้ง';

  @override
  String get profilePhotoOpenFailed =>
      'ไม่สามารถเปิดรูปได้ โปรดตรวจสอบสิทธิ์การเข้าถึงรูปภาพ';

  @override
  String get profileNameUpdated => 'อัปเดตชื่อที่แสดงแล้ว';

  @override
  String get profileNameUpdateFailed =>
      'ไม่สามารถอัปเดตชื่อได้ โปรดลองอีกครั้ง';

  @override
  String get profileNameRequired => 'กรุณากรอกชื่อ';

  @override
  String get profileUpdatedProfileReadFailed =>
      'ไม่สามารถอ่านโปรไฟล์ที่อัปเดตแล้วได้';

  @override
  String get detailCastUnavailable => 'ไม่มีข้อมูลนักแสดง';

  @override
  String get detailCast => 'นักแสดง';

  @override
  String get detailRecommendationsLoadFailed => 'ไม่สามารถโหลดรายการแนะนำได้';

  @override
  String get detailNoRecommendations => 'ไม่มีรายการแนะนำ';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'ตอนที่ $episode ไม่มีในเซิร์ฟเวอร์ปัจจุบัน';
  }

  @override
  String get detailNoEpisodes => 'ไม่มีตอนที่พร้อมใช้งาน';

  @override
  String get detailWatchThisVersion => 'ดูเวอร์ชันนี้';

  @override
  String get detailServer => 'เซิร์ฟเวอร์';

  @override
  String detailServerNumber(int number) {
    return 'เซิร์ฟเวอร์ $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'ตอนที่ 1–$count';
  }

  @override
  String get detailEnterEpisode => 'กรอกเลขตอน';

  @override
  String get detailLoadMovieError => 'ไม่สามารถโหลดหนังได้';

  @override
  String get detailEpisodesTab => 'ตอน';

  @override
  String get detailRecommendationsTab => 'แนะนำ';

  @override
  String get detailCommentsTab => 'ความคิดเห็น';

  @override
  String get detailInTheaters => 'เข้าฉายในโรง';

  @override
  String get detailExclusiveSubtitles => 'ซับไตเติลพิเศษ';

  @override
  String get detailDirectorLabel => 'ผู้กำกับ:';

  @override
  String get detailCreatedDateLabel => 'เพิ่มเมื่อ:';

  @override
  String get detailProductionYearLabel => 'ปีที่ผลิต:';

  @override
  String get detailCountryLabel => 'ประเทศ:';

  @override
  String get detailWatchLatestEpisode => 'ดูตอนล่าสุด';

  @override
  String get detailWatchMovie => 'ดูหนัง';

  @override
  String get detailIntroduction => 'ภาพรวม';

  @override
  String get detailFavorite => 'รายการโปรด';

  @override
  String get detailContent => 'เรื่องย่อ';

  @override
  String get detailNoPlayableEpisodes =>
      'หนังเรื่องนี้ยังไม่มีตอนที่สามารถเล่นได้ โปรดลองอีกครั้งภายหลัง';

  @override
  String get detailDetails => 'รายละเอียด';

  @override
  String get detailVideoQuality => 'คุณภาพวิดีโอ';

  @override
  String detailViews(String count) {
    return 'รับชม $count ครั้ง';
  }

  @override
  String detailLikes(String count) {
    return 'ถูกใจ $count ครั้ง';
  }

  @override
  String get detailUpdatedJustNow => 'อัปเดตเมื่อสักครู่';

  @override
  String get playerSubtitleServer => 'ซับไตเติล';

  @override
  String get playerNowPlaying => 'กำลังเล่น';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'กำลังเล่น: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable =>
      'เซิร์ฟเวอร์นี้ไม่มีแหล่งวิดีโอที่เล่นได้';

  @override
  String get playerSourceLoadFailed => 'ไม่สามารถโหลดแหล่งวิดีโอนี้ได้';

  @override
  String get playerAutoplayEnabled => 'เปิดเล่นอัตโนมัติแล้ว';

  @override
  String get playerAutoplayDisabled => 'ปิดเล่นอัตโนมัติแล้ว';

  @override
  String get playerNoMoreEpisodes => 'ถึงตอนสุดท้ายแล้ว';

  @override
  String get playerFirstEpisode => 'นี่คือตอนแรก';

  @override
  String get playerPlaybackFailed => 'ไม่สามารถเล่นวิดีโอได้ โปรดลองอีกครั้ง';

  @override
  String get playerPlay => 'เล่น';

  @override
  String get playerPause => 'หยุดชั่วคราว';

  @override
  String get playerPullDownToCloseComments => 'ลากลงเพื่อปิดความคิดเห็น';

  @override
  String get playerPlayOnTv => 'เล่นบนทีวี';

  @override
  String get playerEpisodeList => 'รายการตอน';

  @override
  String get playerVideoProgress => 'ความคืบหน้าวิดีโอ';

  @override
  String get playerClose => 'ปิดโปรแกรมเล่น';

  @override
  String get playerContinueWatchingTitle => 'ดูต่อหรือไม่?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'คุณกำลังดู $episode ต้องการดูต่อหรือเริ่มใหม่จากตอนที่ 1?';
  }

  @override
  String get playerRestartFromBeginning => 'เริ่มใหม่ตั้งแต่ต้น';

  @override
  String get playerContinue => 'ดูต่อ';

  @override
  String get commentsReply => 'ตอบกลับ';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count คำตอบกลับ',
      zero: 'ยังไม่มีคำตอบกลับ',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'ไม่สามารถโหลดความคิดเห็นได้';

  @override
  String get commentsEmptyTitle => 'ยังไม่มีความคิดเห็น';

  @override
  String get commentsEmptySubtitle => 'เป็นคนแรกที่แชร์ความคิดเห็นของคุณ';

  @override
  String get commentsEditHint => 'แก้ไขความคิดเห็น...';

  @override
  String commentsReplyToHint(String name) {
    return 'ตอบกลับ $name...';
  }

  @override
  String get commentsAddReplyHint => 'เพิ่มคำตอบกลับ...';

  @override
  String get commentsComposerHint => 'เขียนความคิดเห็น...';

  @override
  String get commentsEditingStatus => 'กำลังแก้ไขความคิดเห็น';

  @override
  String commentsReplyingStatus(String name) {
    return 'กำลังตอบกลับ $name';
  }

  @override
  String get commentsWrite => 'เขียนความคิดเห็น';

  @override
  String get commentsSend => 'ส่ง';

  @override
  String get commentsCloseMenu => 'ปิดเมนูความคิดเห็น';

  @override
  String get commentsCopied => 'คัดลอกความคิดเห็นแล้ว';

  @override
  String get commentsYourComment => 'ความคิดเห็นของคุณ';

  @override
  String get commentsReportReasonTitle => 'เหตุใดคุณจึงรายงานความคิดเห็นนี้?';

  @override
  String get commentsReportSent => 'ส่งรายงานแล้ว ขอบคุณ';

  @override
  String get commentsDeleteTitle => 'ลบความคิดเห็นหรือไม่?';

  @override
  String get commentsRepliesPreserved => 'คำตอบกลับจะยังคงอยู่';

  @override
  String get commentsDeleteAction => 'ลบความคิดเห็น';

  @override
  String get commentsSortTitle => 'เรียงความคิดเห็น';

  @override
  String get commentsPopular => 'ยอดนิยม';

  @override
  String get commentsNewest => 'ใหม่ล่าสุด';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ความคิดเห็น',
      zero: 'ความคิดเห็น',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'คัดลอกความคิดเห็น';

  @override
  String get commentsEdited => 'แก้ไขแล้ว';

  @override
  String get commentsDeleted => 'ความคิดเห็นถูกลบแล้ว';

  @override
  String get commentsJustNow => 'เมื่อสักครู่';

  @override
  String commentsMinutesAgo(int count) {
    return '$count นาทีที่แล้ว';
  }

  @override
  String commentsHoursAgo(int count) {
    return '$count ชั่วโมงที่แล้ว';
  }

  @override
  String commentsDaysAgo(int count) {
    return '$count วันที่แล้ว';
  }

  @override
  String commentsWeeksAgo(int count) {
    return '$count สัปดาห์ที่แล้ว';
  }

  @override
  String commentsMonthsAgo(int count) {
    return '$count เดือนที่แล้ว';
  }

  @override
  String commentsYearsAgo(int count) {
    return '$count ปีที่แล้ว';
  }

  @override
  String get commentsSpamReason => 'สแปม';

  @override
  String get commentsHarassmentReason => 'คุกคามหรือกลั่นแกล้ง';

  @override
  String get commentsSpoilerReason => 'สปอยล์หนัง';

  @override
  String get commentsInappropriateReason => 'เนื้อหาไม่เหมาะสม';

  @override
  String get commentsOtherReason => 'เหตุผลอื่น';

  @override
  String get commentsLoadFailed =>
      'ไม่สามารถโหลดความคิดเห็นได้ โปรดลองอีกครั้ง';

  @override
  String get commentsLoadMoreFailed => 'ไม่สามารถโหลดความคิดเห็นเพิ่มเติมได้';

  @override
  String get commentsRepliesLoadFailed => 'ไม่สามารถโหลดคำตอบกลับได้';

  @override
  String get commentsRepliesLoadMoreFailed =>
      'ไม่สามารถโหลดคำตอบกลับเพิ่มเติมได้';

  @override
  String get commentsSendFailed =>
      'ไม่สามารถส่งความคิดเห็นได้ ข้อความของคุณยังถูกเก็บไว้';

  @override
  String get commentsEditFailed => 'ไม่สามารถแก้ไขความคิดเห็นได้';

  @override
  String get commentsDeleteFailed => 'ไม่สามารถลบความคิดเห็นได้';

  @override
  String get commentsReactionFailed => 'ไม่สามารถอัปเดตการโต้ตอบได้';

  @override
  String get commentsReportFailed =>
      'ความคิดเห็นนี้อาจถูกรายงานแล้ว หรือไม่สามารถส่งรายงานได้';

  @override
  String get commentsOperationInProgress => 'การดำเนินการนี้กำลังทำงานอยู่แล้ว';

  @override
  String get notificationsEmpty => 'ไม่มีการแจ้งเตือนใหม่';

  @override
  String get notificationsRepliedToYourComment => 'ตอบกลับความคิดเห็นของคุณ';

  @override
  String get notificationsLikedYourComment => 'ถูกใจความคิดเห็นของคุณ';

  @override
  String get notificationsToday => 'วันนี้';

  @override
  String get notificationsYesterday => 'เมื่อวาน';

  @override
  String get notificationsUnknownUser => 'ใครบางคน';

  @override
  String get notificationsNewMovieTitle => 'หนังใหม่';

  @override
  String notificationsNewMoviesTitle(int count) {
    return 'หนังใหม่ $count เรื่อง';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return 'เพิ่ม $movieName ลงใน Liquid Phim แล้ว';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'การแจ้งเตือนเมื่อ Liquid Phim พบหนังใหม่';

  @override
  String get castChooseDevice => 'เลือกอุปกรณ์';

  @override
  String get castAirPlayUnavailableTitle => 'ไม่สามารถเปิด AirPlay ได้';

  @override
  String get castAirPlayUnavailableBody =>
      'ตรวจสอบว่า iPhone และทีวีหรือ Mac อยู่บนเครือข่าย Wi-Fi เดียวกัน แล้วลองอีกครั้ง';

  @override
  String get castVideoUnavailableTitle => 'ไม่มีวิดีโอที่พร้อมใช้งาน';

  @override
  String get castVideoUnavailableBody =>
      'รอให้วิดีโอโหลดเสร็จ แล้วเลือกอุปกรณ์ Google Cast';

  @override
  String get castConnectionFailedTitle => 'ไม่สามารถเชื่อมต่อ Google Cast ได้';

  @override
  String get castConnectionFailedBody =>
      'ตรวจสอบ Google Play services และตรวจสอบว่าโทรศัพท์กับ Chromecast หรือ Google TV อยู่บนเครือข่าย Wi-Fi เดียวกัน';

  @override
  String get castAirPlayAndBluetoothDevices => 'อุปกรณ์ AirPlay และ Bluetooth';

  @override
  String get castConnecting => 'กำลังเชื่อมต่อ...';

  @override
  String get castSearching => 'กำลังค้นหาอุปกรณ์ Google Cast...';

  @override
  String get castNoDevices => 'ไม่พบอุปกรณ์';

  @override
  String get castSameWifiGuidance =>
      'ตรวจสอบว่าโทรศัพท์กับ Chromecast หรือ Google TV อยู่บนเครือข่าย Wi-Fi เดียวกัน';

  @override
  String get castSearchAgain => 'ค้นหาอีกครั้ง';

  @override
  String get castDefaultDeviceName => 'อุปกรณ์ Google Cast';

  @override
  String shareMovieSubject(String movieName) {
    return 'ดู $movieName บน Liquid Phim';
  }

  @override
  String get shareOpenFailed => 'ไม่สามารถเปิดหน้าต่างแชร์ได้';

  @override
  String get rankingTopFavorites => 'อันดับหนังโปรด';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => 'TOP 30 หนังยอดนิยม';

  @override
  String get rankingMostViewed => 'รับชมมากที่สุด';

  @override
  String get rankingMostLiked => 'ถูกใจมากที่สุด';

  @override
  String get rankingEmptyLikes => 'อันดับจะแสดงเมื่อมีผู้กดถูกใจหนัง';

  @override
  String get rankingEmptyViews => 'อันดับจะแสดงเมื่อมีผู้รับชมหนัง';

  @override
  String get rankingLoadFailed => 'ไม่สามารถโหลดอันดับได้';

  @override
  String playerEpisodeNumber(int number) {
    return 'ตอนที่ $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'เดือน $month';
  }
}
