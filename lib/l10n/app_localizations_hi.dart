// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'फ़िल्में कभी भी, कहीं भी';

  @override
  String get commonAgree => 'ठीक है';

  @override
  String get commonCancel => 'रद्द करें';

  @override
  String get commonClose => 'बंद करें';

  @override
  String get commonDone => 'हो गया';

  @override
  String get commonSave => 'सहेजें';

  @override
  String get commonDelete => 'हटाएँ';

  @override
  String get commonEdit => 'संपादित करें';

  @override
  String get commonReport => 'रिपोर्ट करें';

  @override
  String get commonRetry => 'फिर से कोशिश करें';

  @override
  String get commonReset => 'रीसेट करें';

  @override
  String get commonAll => 'सभी';

  @override
  String get commonSeeMore => 'और देखें';

  @override
  String get commonCollapse => 'कम दिखाएँ';

  @override
  String get commonLoading => 'लोड हो रहा है...';

  @override
  String get commonUpdating => 'अपडेट हो रहा है';

  @override
  String get commonUnderstood => 'समझ गया';

  @override
  String get commonNoData => 'कोई डेटा नहीं';

  @override
  String get commonNotAvailable => 'उपलब्ध नहीं';

  @override
  String get commonWarningTitle => 'चेतावनी';

  @override
  String get commonNoticeTitle => 'सूचना';

  @override
  String get commonCongratulationsTitle => 'बधाई!';

  @override
  String get commonBack => 'वापस';

  @override
  String get commonGoHome => 'होम पर जाएँ';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चयनित',
      one: '1 चयनित',
      zero: 'कुछ भी चयनित नहीं',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'त्रुटि: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours घंटे',
      one: '1 घंटा',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes मिनट',
      one: '1 मिनट',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsLanguageSystem => 'डिवाइस की भाषा का उपयोग करें';

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
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsGeneralSection => 'सामान्य';

  @override
  String get settingsAppLanguage => 'ऐप की भाषा';

  @override
  String get settingsAccountSection => 'खाता';

  @override
  String get settingsSwitchAccount => 'खाता बदलें';

  @override
  String get settingsAddAccount => 'खाता जोड़ें';

  @override
  String get settingsAccountSwitchFailed =>
      'खाता बदला नहीं जा सका। कृपया उस खाते में फिर से साइन इन करें।';

  @override
  String get settingsSignOutFailed =>
      'साइन आउट नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get navHome => 'होम';

  @override
  String get navSearch => 'खोजें';

  @override
  String get navFavorites => 'पसंदीदा';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get navNotifications => 'सूचनाएँ';

  @override
  String get internetOffline => 'इंटरनेट कनेक्शन नहीं है';

  @override
  String get internetBackOnline => 'फिर से ऑनलाइन';

  @override
  String get authJoinMember => 'सदस्य के रूप में जुड़ें';

  @override
  String get authSignInTitle => 'Liquid Phim में साइन इन करें';

  @override
  String get authSignIn => 'साइन इन करें';

  @override
  String get authSignInFailed =>
      'साइन इन सफल नहीं हुआ। कृपया फिर से कोशिश करें।';

  @override
  String get authSignInToComment =>
      'टिप्पणी करने और समुदाय से जुड़ने के लिए साइन इन करें।';

  @override
  String get authGoogleSyncDescription =>
      'अपना खाता सिंक करने और समुदाय से जुड़ने के लिए Google के साथ जारी रखें।';

  @override
  String get authGoogleConsent =>
      'जारी रखकर, आप Liquid Phim के साथ अपने Google खाते का उपयोग करने के लिए सहमत होते हैं।';

  @override
  String get authContinueWithGoogle => 'Google के साथ जारी रखें';

  @override
  String get authGoogleSignInFailed =>
      'Google से साइन इन नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get authGoogleSignInCheckFailed =>
      'Google से साइन इन नहीं हो सका। अपना कनेक्शन जाँचें और फिर से कोशिश करें।';

  @override
  String get authSessionUpdateFailed => 'आपका साइन-इन सत्र अपडेट नहीं हो सका।';

  @override
  String get authLoginRequired => 'आपको साइन इन करना होगा।';

  @override
  String get authLoginRequiredForAction =>
      'यह कार्रवाई करने के लिए आपको साइन इन करना होगा।';

  @override
  String get authEmail => 'ईमेल';

  @override
  String get authPassword => 'पासवर्ड';

  @override
  String get authFullName => 'पूरा नाम';

  @override
  String get authForgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get authOrContinueWith => 'या इसके साथ जारी रखें';

  @override
  String get authAlreadyHaveAccount => 'क्या आपका खाता पहले से है?';

  @override
  String get authFullNameRequired => 'पूरा नाम खाली नहीं हो सकता।';

  @override
  String get authFullNameLength =>
      'पूरा नाम 3 से 15 अक्षरों के बीच होना चाहिए।';

  @override
  String get authEmailRequired => 'ईमेल खाली नहीं हो सकता।';

  @override
  String get authEmailInvalid => 'मान्य ईमेल पता दर्ज करें।';

  @override
  String get authPasswordRequired => 'पासवर्ड खाली नहीं हो सकता।';

  @override
  String get authPasswordLength => 'पासवर्ड 6 से 15 अक्षरों के बीच होना चाहिए।';

  @override
  String get authAccountAlreadyExists =>
      'यह खाता पहले से मौजूद है। कृपया दूसरा ईमेल चुनें।';

  @override
  String get authWeakPassword =>
      'यह पासवर्ड बहुत कमजोर है। कृपया अधिक मजबूत पासवर्ड दर्ज करें।';

  @override
  String get authInvalidCredentials =>
      'ईमेल या पासवर्ड गलत है। कृपया फिर से कोशिश करें।';

  @override
  String get authUnexpectedError => 'कुछ गलत हो गया। कृपया फिर से कोशिश करें।';

  @override
  String get authSignUpFailed =>
      'आपका खाता नहीं बनाया जा सका। कृपया फिर से कोशिश करें।';

  @override
  String get authSignUpSucceeded => 'आपका खाता बना दिया गया है।';

  @override
  String get authSignInSucceeded => 'सफलतापूर्वक साइन इन किया गया।';

  @override
  String get authSignOutSucceeded => 'सफलतापूर्वक साइन आउट किया गया।';

  @override
  String get authTokenConfirmed => 'सत्यापन कोड की पुष्टि हो गई।';

  @override
  String get authTokenInvalid => 'सत्यापन कोड गलत है।';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      'नई फ़िल्मों की सूचनाएँ प्राप्त करें?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim समय-समय पर बैकग्राउंड में जाँच कर सकता है और नई फ़िल्में मिलने पर आपको सूचित कर सकता है। बैटरी बचाने के लिए ऑपरेटिंग सिस्टम जाँच में 20 मिनट से अधिक की देरी कर सकता है।';

  @override
  String get homeEnableNotifications => 'सूचनाएँ चालू करें';

  @override
  String get homeDoNotEnable => 'अभी नहीं';

  @override
  String get homeNotificationPermissionDisabled =>
      'सूचना की अनुमति बंद है। आप इसे अपने फ़ोन की सेटिंग्स में फिर से चालू कर सकते हैं।';

  @override
  String get homeLoadMoviesFailed =>
      'फ़िल्में लोड नहीं हो सकीं।\nफिर से कोशिश करने के लिए नीचे खींचें।';

  @override
  String get homeRecommended => 'सुझाए गए';

  @override
  String get homeGenres => 'शैलियाँ';

  @override
  String get homeCountries => 'देश';

  @override
  String get homeYear => 'वर्ष';

  @override
  String get homeFreshMovies => 'नई रिलीज़!';

  @override
  String get homeKoreanMovies => 'कोरियाई फ़िल्में';

  @override
  String get homeChineseMovies => 'चीनी फ़िल्में';

  @override
  String get homeUsUkMovies => 'अमेरिकी और ब्रिटिश फ़िल्में';

  @override
  String get homeWatchMovie => 'देखें';

  @override
  String get homeInformation => 'जानकारी';

  @override
  String get homeViewAll => 'सभी देखें';

  @override
  String get homeWhatToWatch => 'आज आप क्या देखना चाहेंगे?';

  @override
  String get homeViewMore => 'और देखें';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'संस्करण: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'फ़िल्म का प्रकार';

  @override
  String get filterSeries => 'सीरीज़';

  @override
  String get filterSingleMovies => 'फ़िल्में';

  @override
  String get filterAnimation => 'एनीमेशन';

  @override
  String get filterTvShows => 'टीवी शो';

  @override
  String get filterSubtitled => 'उपशीर्षक सहित';

  @override
  String get filterVoiceOver => 'वॉइस-ओवर';

  @override
  String get filterDubbed => 'डब किया हुआ';

  @override
  String get filterChooseMovieType => 'कृपया फ़िल्म का प्रकार चुनें।';

  @override
  String get filterChooseGenre => 'कृपया कोई शैली चुनें।';

  @override
  String get filterChooseCountry => 'फ़िल्टर करने के लिए कोई देश चुनें।';

  @override
  String get filterChooseYear => 'फ़िल्टर करने के लिए कोई वर्ष चुनें।';

  @override
  String get filterLanguage => 'भाषा';

  @override
  String get filterSortBy => 'इसके अनुसार क्रमबद्ध करें';

  @override
  String get filterSortDirection => 'क्रमबद्ध करने की दिशा';

  @override
  String get filterDescending => 'घटते क्रम में';

  @override
  String get filterAscending => 'बढ़ते क्रम में';

  @override
  String get filterMostViewed => 'सबसे अधिक देखी गई';

  @override
  String get filterNewest => 'नवीनतम';

  @override
  String get filterReleaseYear => 'रिलीज़ वर्ष';

  @override
  String get filterApply => 'फ़िल्टर लागू करें';

  @override
  String get filterResults => 'परिणाम फ़िल्टर करें';

  @override
  String get searchAttentionTitle => 'ध्यान दें';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'फ़िल्मों को फ़िल्टर करने से पहले कोई कीवर्ड दर्ज करें।';

  @override
  String get searchNoResults => 'कोई परिणाम नहीं मिला';

  @override
  String get searchMovieActorHint => 'फ़िल्में, अभिनेता खोजें...';

  @override
  String get searchFilterTooltip => 'खोज फ़िल्टर';

  @override
  String get searchStartPrompt =>
      'खोज शुरू करने के लिए फ़िल्म का शीर्षक दर्ज करें';

  @override
  String get searchRecent => 'हाल की खोजें';

  @override
  String get searchLoadingGenres => 'शैलियाँ लोड हो रही हैं...';

  @override
  String get searchLoadingCountries => 'देश लोड हो रहे हैं...';

  @override
  String get searchNoMovies => 'कोई फ़िल्म नहीं';

  @override
  String get searchTryDifferentFilters => 'अलग फ़िल्टर आज़माएँ';

  @override
  String get librarySignOutTitle => 'साइन आउट करें?';

  @override
  String get librarySignOutConfirmation =>
      'क्या आप वाकई इस खाते से साइन आउट करना चाहते हैं?';

  @override
  String get librarySignOut => 'साइन आउट करें';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count चुनी गई फ़िल्में हटाएँ?',
      one: 'चुनी गई फ़िल्म हटाएँ?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => 'इस फ़िल्म को इतिहास से हटाएँ?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़िल्मों को देखने के इतिहास से हटाएँ?',
      one: 'इस फ़िल्म को देखने के इतिहास से हटाएँ?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle =>
      'इस फ़िल्म को पसंदीदा से हटाएँ?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count फ़िल्मों को पसंदीदा से हटाएँ?',
      one: 'इस फ़िल्म को पसंदीदा से हटाएँ?',
    );
    return '$_temp0';
  }

  @override
  String get libraryCancelSelection => 'चयन रद्द करें';

  @override
  String get libraryDeleteSelectedMovies => 'चुनी गई फ़िल्में हटाएँ';

  @override
  String get libraryCannotResumeMovie =>
      'अभी इस फ़िल्म को वहीं से जारी नहीं किया जा सकता।';

  @override
  String get libraryYourProfile => 'आपकी प्रोफ़ाइल';

  @override
  String get librarySignInProfileDescription =>
      'अपनी प्रोफ़ाइल संपादित करने और देखने का इतिहास सिंक करने के लिए साइन इन करें।';

  @override
  String get libraryWatchHistory => 'देखने का इतिहास';

  @override
  String get libraryNoWatchHistory => 'अभी तक देखने का कोई इतिहास नहीं';

  @override
  String get libraryFavorites => 'पसंदीदा';

  @override
  String get librarySignInToSaveFavorites =>
      'पसंदीदा फ़िल्में सहेजने के लिए साइन इन करें';

  @override
  String get libraryFavoritesSyncDescription =>
      'आपकी सूची आपके सभी डिवाइसों पर सिंक की जाएगी।';

  @override
  String get libraryNoFavorites => 'अभी तक कोई पसंदीदा फ़िल्म नहीं';

  @override
  String get libraryRemoveFromList => 'सूची से हटाएँ';

  @override
  String libraryContinueProgress(int progress) {
    return '$progress% से जारी रखें';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed =>
      'आपकी लाइब्रेरी लोड नहीं हो सकी। कृपया फिर से कोशिश करें।';

  @override
  String get libraryFavoriteUpdateFailed =>
      'पसंदीदा अपडेट नहीं हो सके। कृपया फिर से कोशिश करें।';

  @override
  String get libraryFavoriteRemoveFailed =>
      'पसंदीदा से हटाया नहीं जा सका। कृपया फिर से कोशिश करें।';

  @override
  String get libraryHistorySyncLater =>
      'आपका इतिहास बाद में फिर से सिंक किया जाएगा।';

  @override
  String get libraryHistoryDeleteFailed =>
      'देखने का इतिहास हटाया नहीं जा सका। कृपया फिर से कोशिश करें।';

  @override
  String get profileEdit => 'प्रोफ़ाइल संपादित करें';

  @override
  String get profileChangePhoto => 'फ़ोटो बदलें';

  @override
  String get profileName => 'नाम';

  @override
  String get profileNameDescription =>
      'यह नाम आपकी Liquid Phim प्रोफ़ाइल पर दिखाई देगा।';

  @override
  String get profileNameHint => 'दिखाने के लिए नाम दर्ज करें';

  @override
  String get profileClearName => 'नाम साफ़ करें';

  @override
  String get profileEmailDescription =>
      'यह ईमेल आपके खाते से जुड़ा है और केवल यहाँ दिखाया जाता है।';

  @override
  String get profileChangeAvatar => 'प्रोफ़ाइल फ़ोटो बदलें';

  @override
  String get profileTakePhoto => 'फ़ोटो लें';

  @override
  String get profileUploadPhoto => 'फ़ोटो अपलोड करें';

  @override
  String get profileViewPhoto => 'फ़ोटो देखें';

  @override
  String get profileAvatar => 'प्रोफ़ाइल फ़ोटो';

  @override
  String get profileCropAvatar => 'प्रोफ़ाइल फ़ोटो क्रॉप करें';

  @override
  String get profileAvatarUpdated => 'प्रोफ़ाइल फ़ोटो अपडेट हो गई।';

  @override
  String get profileAvatarUpdateFailed =>
      'प्रोफ़ाइल फ़ोटो अपडेट नहीं हो सकी। कृपया फिर से कोशिश करें।';

  @override
  String get profilePhotoOpenFailed =>
      'फ़ोटो नहीं खुल सकी। फ़ोटो एक्सेस की अनुमति जाँचें।';

  @override
  String get profileNameUpdated => 'दिखाने वाला नाम अपडेट हो गया।';

  @override
  String get profileNameUpdateFailed =>
      'नाम अपडेट नहीं हो सका। कृपया फिर से कोशिश करें।';

  @override
  String get profileNameRequired => 'नाम खाली नहीं हो सकता।';

  @override
  String get profileUpdatedProfileReadFailed =>
      'अपडेट की गई प्रोफ़ाइल पढ़ी नहीं जा सकी।';

  @override
  String get detailCastUnavailable => 'कलाकारों की जानकारी उपलब्ध नहीं है';

  @override
  String get detailCast => 'कलाकार';

  @override
  String get detailRecommendationsLoadFailed => 'सुझाव लोड नहीं हो सके';

  @override
  String get detailNoRecommendations => 'कोई सुझाव नहीं';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'एपिसोड $episode मौजूदा सर्वर पर उपलब्ध नहीं है।';
  }

  @override
  String get detailNoEpisodes => 'कोई एपिसोड उपलब्ध नहीं';

  @override
  String get detailWatchThisVersion => 'यह संस्करण देखें';

  @override
  String get detailServer => 'सर्वर';

  @override
  String detailServerNumber(int number) {
    return 'सर्वर $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'एपिसोड 1–$count';
  }

  @override
  String get detailEnterEpisode => 'एपिसोड दर्ज करें';

  @override
  String get detailLoadMovieError => 'फ़िल्म लोड नहीं हो सकी';

  @override
  String get detailEpisodesTab => 'एपिसोड';

  @override
  String get detailRecommendationsTab => 'सुझाव';

  @override
  String get detailCommentsTab => 'टिप्पणियाँ';

  @override
  String get detailInTheaters => 'सिनेमाघरों में';

  @override
  String get detailExclusiveSubtitles => 'विशेष उपशीर्षक';

  @override
  String get detailDirectorLabel => 'निर्देशक:';

  @override
  String get detailCreatedDateLabel => 'जोड़ा गया:';

  @override
  String get detailProductionYearLabel => 'निर्माण वर्ष:';

  @override
  String get detailCountryLabel => 'देश:';

  @override
  String get detailWatchLatestEpisode => 'नवीनतम एपिसोड देखें';

  @override
  String get detailWatchMovie => 'फ़िल्म देखें';

  @override
  String get detailIntroduction => 'सारांश';

  @override
  String get detailFavorite => 'पसंदीदा';

  @override
  String get detailContent => 'कथासार';

  @override
  String get detailNoPlayableEpisodes =>
      'इस फ़िल्म में अभी कोई चलाने योग्य एपिसोड नहीं है। कृपया बाद में फिर कोशिश करें।';

  @override
  String get detailDetails => 'विवरण';

  @override
  String get detailVideoQuality => 'वीडियो गुणवत्ता';

  @override
  String detailViews(String count) {
    return '$count बार देखा गया';
  }

  @override
  String detailLikes(String count) {
    return '$count लाइक';
  }

  @override
  String get detailUpdatedJustNow => 'अभी-अभी अपडेट किया गया';

  @override
  String get playerSubtitleServer => 'उपशीर्षक सहित';

  @override
  String get playerNowPlaying => 'अभी चल रहा है';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'अभी चल रहा है: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable =>
      'इस सर्वर पर चलाने योग्य स्रोत नहीं है।';

  @override
  String get playerSourceLoadFailed => 'इस फ़िल्म का स्रोत लोड नहीं हो सका।';

  @override
  String get playerAutoplayEnabled => 'ऑटोप्ले चालू है';

  @override
  String get playerAutoplayDisabled => 'ऑटोप्ले बंद है';

  @override
  String get playerNoMoreEpisodes => 'आप अंतिम एपिसोड तक पहुँच गए हैं';

  @override
  String get playerFirstEpisode => 'यह पहला एपिसोड है';

  @override
  String get playerPlaybackFailed =>
      'वीडियो चलाया नहीं जा सका। कृपया फिर से कोशिश करें।';

  @override
  String get playerPlay => 'चलाएँ';

  @override
  String get playerPause => 'रोकें';

  @override
  String get playerPullDownToCloseComments =>
      'टिप्पणियाँ बंद करने के लिए नीचे खींचें';

  @override
  String get playerPlayOnTv => 'टीवी पर चलाएँ';

  @override
  String get playerEpisodeList => 'एपिसोड सूची';

  @override
  String get playerVideoProgress => 'वीडियो प्रगति';

  @override
  String get playerClose => 'प्लेयर बंद करें';

  @override
  String get playerContinueWatchingTitle => 'देखना जारी रखें?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'आप $episode देख रहे थे। क्या आप वहीं से जारी रखना चाहते हैं या एपिसोड 1 से फिर शुरू करना चाहते हैं?';
  }

  @override
  String get playerRestartFromBeginning => 'शुरू से फिर चलाएँ';

  @override
  String get playerContinue => 'जारी रखें';

  @override
  String get commentsReply => 'जवाब दें';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count जवाब',
      one: '1 जवाब',
      zero: 'कोई जवाब नहीं',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'टिप्पणियाँ लोड नहीं हो सकीं';

  @override
  String get commentsEmptyTitle => 'अभी तक कोई टिप्पणी नहीं';

  @override
  String get commentsEmptySubtitle =>
      'अपनी राय साझा करने वाले पहले व्यक्ति बनें।';

  @override
  String get commentsEditHint => 'टिप्पणी संपादित करें...';

  @override
  String commentsReplyToHint(String name) {
    return '$name को जवाब दें...';
  }

  @override
  String get commentsAddReplyHint => 'जवाब जोड़ें...';

  @override
  String get commentsComposerHint => 'टिप्पणी लिखें...';

  @override
  String get commentsEditingStatus => 'टिप्पणी संपादित की जा रही है';

  @override
  String commentsReplyingStatus(String name) {
    return '$name को जवाब दिया जा रहा है';
  }

  @override
  String get commentsWrite => 'टिप्पणी लिखें';

  @override
  String get commentsSend => 'भेजें';

  @override
  String get commentsCloseMenu => 'टिप्पणी मेनू बंद करें';

  @override
  String get commentsCopied => 'टिप्पणी कॉपी की गई';

  @override
  String get commentsYourComment => 'आपकी टिप्पणी';

  @override
  String get commentsReportReasonTitle =>
      'आप इस टिप्पणी की रिपोर्ट क्यों कर रहे हैं?';

  @override
  String get commentsReportSent => 'रिपोर्ट भेज दी गई। धन्यवाद।';

  @override
  String get commentsDeleteTitle => 'टिप्पणी हटाएँ?';

  @override
  String get commentsRepliesPreserved => 'जवाब सुरक्षित रहेंगे।';

  @override
  String get commentsDeleteAction => 'टिप्पणी हटाएँ';

  @override
  String get commentsSortTitle => 'टिप्पणियाँ क्रमबद्ध करें';

  @override
  String get commentsPopular => 'लोकप्रिय';

  @override
  String get commentsNewest => 'नवीनतम';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count टिप्पणियाँ',
      one: '1 टिप्पणी',
      zero: 'टिप्पणियाँ',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'टिप्पणी कॉपी करें';

  @override
  String get commentsEdited => 'संपादित';

  @override
  String get commentsDeleted => 'टिप्पणी हटाई गई';

  @override
  String get commentsJustNow => 'अभी-अभी';

  @override
  String commentsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count मिनट पहले',
      one: '1 मिनट पहले',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count घंटे पहले',
      one: '1 घंटे पहले',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन पहले',
      one: '1 दिन पहले',
    );
    return '$_temp0';
  }

  @override
  String commentsWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सप्ताह पहले',
      one: '1 सप्ताह पहले',
    );
    return '$_temp0';
  }

  @override
  String commentsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count महीने पहले',
      one: '1 महीने पहले',
    );
    return '$_temp0';
  }

  @override
  String commentsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count वर्ष पहले',
      one: '1 वर्ष पहले',
    );
    return '$_temp0';
  }

  @override
  String get commentsSpamReason => 'स्पैम';

  @override
  String get commentsHarassmentReason => 'उत्पीड़न या दुर्व्यवहार';

  @override
  String get commentsSpoilerReason => 'फ़िल्म स्पॉइलर';

  @override
  String get commentsInappropriateReason => 'अनुचित सामग्री';

  @override
  String get commentsOtherReason => 'अन्य कारण';

  @override
  String get commentsLoadFailed =>
      'टिप्पणियाँ लोड नहीं हो सकीं। कृपया फिर से कोशिश करें।';

  @override
  String get commentsLoadMoreFailed => 'और टिप्पणियाँ लोड नहीं हो सकीं।';

  @override
  String get commentsRepliesLoadFailed => 'जवाब लोड नहीं हो सके।';

  @override
  String get commentsRepliesLoadMoreFailed => 'और जवाब लोड नहीं हो सके।';

  @override
  String get commentsSendFailed =>
      'टिप्पणी भेजी नहीं जा सकी। आपका टेक्स्ट सुरक्षित रखा गया है।';

  @override
  String get commentsEditFailed => 'टिप्पणी संपादित नहीं की जा सकी।';

  @override
  String get commentsDeleteFailed => 'टिप्पणी हटाई नहीं जा सकी।';

  @override
  String get commentsReactionFailed => 'प्रतिक्रिया अपडेट नहीं हो सकी।';

  @override
  String get commentsReportFailed =>
      'इस टिप्पणी की रिपोर्ट पहले ही की जा चुकी है या रिपोर्ट भेजी नहीं जा सकी।';

  @override
  String get commentsOperationInProgress => 'यह कार्रवाई पहले से चल रही है।';

  @override
  String get notificationsEmpty => 'कोई नई सूचना नहीं';

  @override
  String get notificationsRepliedToYourComment =>
      'ने आपकी टिप्पणी का जवाब दिया';

  @override
  String get notificationsLikedYourComment => 'ने आपकी टिप्पणी को लाइक किया';

  @override
  String get notificationsToday => 'आज';

  @override
  String get notificationsYesterday => 'कल';

  @override
  String get notificationsUnknownUser => 'कोई व्यक्ति';

  @override
  String get notificationsNewMovieTitle => 'नई फ़िल्म';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count नई फ़िल्में';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName को अभी Liquid Phim में जोड़ा गया है।';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'जब Liquid Phim नई फ़िल्में खोजे तब सूचनाएँ';

  @override
  String get castChooseDevice => 'डिवाइस चुनें';

  @override
  String get castAirPlayUnavailableTitle => 'AirPlay नहीं खुल सका';

  @override
  String get castAirPlayUnavailableBody =>
      'सुनिश्चित करें कि आपका iPhone और TV या Mac एक ही Wi-Fi नेटवर्क पर हैं, फिर से कोशिश करें।';

  @override
  String get castVideoUnavailableTitle => 'कोई वीडियो उपलब्ध नहीं';

  @override
  String get castVideoUnavailableBody =>
      'वीडियो के लोड होने की प्रतीक्षा करें, फिर Google Cast डिवाइस चुनें।';

  @override
  String get castConnectionFailedTitle => 'Google Cast से कनेक्ट नहीं हो सका';

  @override
  String get castConnectionFailedBody =>
      'Google Play services जाँचें और सुनिश्चित करें कि आपका फ़ोन और Chromecast या Google TV एक ही Wi-Fi नेटवर्क पर हैं।';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay और Bluetooth डिवाइस';

  @override
  String get castConnecting => 'कनेक्ट हो रहा है...';

  @override
  String get castSearching => 'Google Cast डिवाइस खोजे जा रहे हैं...';

  @override
  String get castNoDevices => 'कोई डिवाइस नहीं मिला';

  @override
  String get castSameWifiGuidance =>
      'सुनिश्चित करें कि आपका फ़ोन और Chromecast या Google TV एक ही Wi-Fi नेटवर्क पर हैं।';

  @override
  String get castSearchAgain => 'फिर खोजें';

  @override
  String get castDefaultDeviceName => 'Google Cast डिवाइस';

  @override
  String shareMovieSubject(String movieName) {
    return 'Liquid Phim पर $movieName देखें';
  }

  @override
  String get shareOpenFailed => 'शेयर शीट नहीं खुल सकी।';

  @override
  String get rankingTopFavorites => 'टॉप पसंदीदा फ़िल्में';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim टॉप 30';

  @override
  String get rankingTopHotMovies => 'टॉप 30 लोकप्रिय फ़िल्में';

  @override
  String get rankingMostViewed => 'सबसे अधिक देखी गई';

  @override
  String get rankingMostLiked => 'सबसे अधिक लाइक की गई';

  @override
  String get rankingEmptyLikes =>
      'फ़िल्मों को लाइक मिलने के बाद रैंकिंग दिखाई देगी।';

  @override
  String get rankingEmptyViews =>
      'फ़िल्मों को व्यू मिलने के बाद रैंकिंग दिखाई देगी।';

  @override
  String get rankingLoadFailed => 'रैंकिंग लोड नहीं हो सकी।';

  @override
  String playerEpisodeNumber(int number) {
    return 'एपिसोड $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'महीना $month';
  }
}
