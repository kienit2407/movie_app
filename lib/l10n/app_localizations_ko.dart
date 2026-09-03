// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => '언제 어디서나 영화를 즐기세요';

  @override
  String get commonAgree => '확인';

  @override
  String get commonCancel => '취소';

  @override
  String get commonClose => '닫기';

  @override
  String get commonDone => '완료';

  @override
  String get commonSave => '저장';

  @override
  String get commonDelete => '삭제';

  @override
  String get commonEdit => '수정';

  @override
  String get commonReport => '신고';

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonReset => '초기화';

  @override
  String get commonAll => '전체';

  @override
  String get commonSeeMore => '더 보기';

  @override
  String get commonCollapse => '접기';

  @override
  String get commonLoading => '불러오는 중...';

  @override
  String get commonUpdating => '업데이트 중';

  @override
  String get commonUnderstood => '알겠습니다';

  @override
  String get commonNoData => '데이터 없음';

  @override
  String get commonNotAvailable => '정보 없음';

  @override
  String get commonWarningTitle => '경고';

  @override
  String get commonNoticeTitle => '알림';

  @override
  String get commonCongratulationsTitle => '축하합니다!';

  @override
  String get commonBack => '뒤로';

  @override
  String get commonGoHome => '홈으로';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count개 선택',
      zero: '선택 없음',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return '오류: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String get settingsLanguage => '언어';

  @override
  String get settingsLanguageSystem => '기기 언어 사용';

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
  String get settingsTitle => '설정';

  @override
  String get settingsGeneralSection => '일반';

  @override
  String get settingsAppLanguage => '앱 언어';

  @override
  String get settingsAccountSection => '계정';

  @override
  String get settingsSwitchAccount => '계정 전환';

  @override
  String get settingsAddAccount => '계정 추가';

  @override
  String get settingsAccountSwitchFailed =>
      '계정을 전환할 수 없습니다. 해당 계정으로 다시 로그인해 주세요.';

  @override
  String get settingsSignOutFailed => '로그아웃할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get navHome => '홈';

  @override
  String get navSearch => '검색';

  @override
  String get navFavorites => '즐겨찾기';

  @override
  String get navProfile => '프로필';

  @override
  String get navNotifications => '알림';

  @override
  String get internetOffline => '인터넷에 연결되어 있지 않습니다';

  @override
  String get internetBackOnline => '인터넷에 다시 연결되었습니다';

  @override
  String get authJoinMember => '회원으로 참여';

  @override
  String get authSignInTitle => 'Liquid Phim 로그인';

  @override
  String get authSignIn => '로그인';

  @override
  String get authSignInFailed => '로그인에 실패했습니다. 다시 시도해 주세요.';

  @override
  String get authSignInToComment => '댓글을 작성하고 커뮤니티와 소통하려면 로그인하세요.';

  @override
  String get authGoogleSyncDescription => 'Google로 계속하여 계정을 동기화하고 커뮤니티에 참여하세요.';

  @override
  String get authGoogleConsent =>
      '계속하면 Google 계정을 Liquid Phim에서 사용하는 데 동의하게 됩니다.';

  @override
  String get authContinueWithGoogle => 'Google로 계속';

  @override
  String get authGoogleSignInFailed => 'Google로 로그인할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get authGoogleSignInCheckFailed =>
      'Google로 로그인할 수 없습니다. 연결 상태를 확인하고 다시 시도해 주세요.';

  @override
  String get authSessionUpdateFailed => '로그인 세션을 업데이트할 수 없습니다.';

  @override
  String get authLoginRequired => '로그인이 필요합니다.';

  @override
  String get authLoginRequiredForAction => '이 작업을 수행하려면 로그인해야 합니다.';

  @override
  String get authEmail => '이메일';

  @override
  String get authPassword => '비밀번호';

  @override
  String get authFullName => '이름';

  @override
  String get authForgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get authOrContinueWith => '또는 다음으로 계속';

  @override
  String get authAlreadyHaveAccount => '이미 계정이 있으신가요?';

  @override
  String get authFullNameRequired => '이름을 입력해 주세요.';

  @override
  String get authFullNameLength => '이름은 3~15자로 입력해 주세요.';

  @override
  String get authEmailRequired => '이메일을 입력해 주세요.';

  @override
  String get authEmailInvalid => '올바른 이메일 주소를 입력해 주세요.';

  @override
  String get authPasswordRequired => '비밀번호를 입력해 주세요.';

  @override
  String get authPasswordLength => '비밀번호는 6~15자로 입력해 주세요.';

  @override
  String get authAccountAlreadyExists => '이미 존재하는 계정입니다. 다른 이메일을 사용해 주세요.';

  @override
  String get authWeakPassword => '비밀번호가 너무 약합니다. 더 강력한 비밀번호를 입력해 주세요.';

  @override
  String get authInvalidCredentials => '이메일 또는 비밀번호가 올바르지 않습니다. 다시 시도해 주세요.';

  @override
  String get authUnexpectedError => '문제가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get authSignUpFailed => '계정을 만들 수 없습니다. 다시 시도해 주세요.';

  @override
  String get authSignUpSucceeded => '계정이 생성되었습니다.';

  @override
  String get authSignInSucceeded => '로그인했습니다.';

  @override
  String get authSignOutSucceeded => '로그아웃했습니다.';

  @override
  String get authTokenConfirmed => '인증 코드가 확인되었습니다.';

  @override
  String get authTokenInvalid => '인증 코드가 올바르지 않습니다.';

  @override
  String get homeEnableNewMovieNotificationsTitle => '새 영화 알림을 받으시겠어요?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim은 백그라운드에서 주기적으로 확인하여 새 영화가 발견되면 알려드릴 수 있습니다. 배터리 절약을 위해 운영체제가 확인을 20분 이상 지연할 수 있습니다.';

  @override
  String get homeEnableNotifications => '알림 켜기';

  @override
  String get homeDoNotEnable => '나중에';

  @override
  String get homeNotificationPermissionDisabled =>
      '알림 권한이 꺼져 있습니다. 휴대전화 설정에서 다시 켤 수 있습니다.';

  @override
  String get homeLoadMoviesFailed => '영화를 불러올 수 없습니다.\n아래로 당겨 다시 시도하세요.';

  @override
  String get homeRecommended => '추천';

  @override
  String get homeGenres => '장르';

  @override
  String get homeCountries => '국가';

  @override
  String get homeYear => '연도';

  @override
  String get homeFreshMovies => '최신 영화!';

  @override
  String get homeKoreanMovies => '한국 영화';

  @override
  String get homeChineseMovies => '중국 영화';

  @override
  String get homeUsUkMovies => '미국·영국 영화';

  @override
  String get homeWatchMovie => '시청';

  @override
  String get homeInformation => '정보';

  @override
  String get homeViewAll => '전체 보기';

  @override
  String get homeWhatToWatch => '오늘은 무엇을 볼까요?';

  @override
  String get homeViewMore => '더 보기';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return '버전: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => '콘텐츠 유형';

  @override
  String get filterSeries => '시리즈';

  @override
  String get filterSingleMovies => '영화';

  @override
  String get filterAnimation => '애니메이션';

  @override
  String get filterTvShows => 'TV 프로그램';

  @override
  String get filterSubtitled => '자막';

  @override
  String get filterVoiceOver => '보이스오버';

  @override
  String get filterDubbed => '더빙';

  @override
  String get filterChooseMovieType => '콘텐츠 유형을 선택해 주세요.';

  @override
  String get filterChooseGenre => '장르를 선택해 주세요.';

  @override
  String get filterChooseCountry => '필터링할 국가를 선택해 주세요.';

  @override
  String get filterChooseYear => '필터링할 연도를 선택해 주세요.';

  @override
  String get filterLanguage => '언어';

  @override
  String get filterSortBy => '정렬 기준';

  @override
  String get filterSortDirection => '정렬 방향';

  @override
  String get filterDescending => '내림차순';

  @override
  String get filterAscending => '오름차순';

  @override
  String get filterMostViewed => '조회수 많은 순';

  @override
  String get filterNewest => '최신순';

  @override
  String get filterReleaseYear => '개봉 연도';

  @override
  String get filterApply => '필터 적용';

  @override
  String get filterResults => '필터 결과';

  @override
  String get searchAttentionTitle => '주의';

  @override
  String get searchEnterKeywordBeforeFiltering => '영화를 필터링하기 전에 검색어를 입력해 주세요.';

  @override
  String get searchNoResults => '검색 결과가 없습니다';

  @override
  String get searchMovieActorHint => '영화, 배우 검색...';

  @override
  String get searchFilterTooltip => '검색 필터';

  @override
  String get searchStartPrompt => '영화 제목을 입력하여 검색을 시작하세요';

  @override
  String get searchRecent => '최근 검색';

  @override
  String get searchLoadingGenres => '장르 불러오는 중...';

  @override
  String get searchLoadingCountries => '국가 불러오는 중...';

  @override
  String get searchNoMovies => '영화 없음';

  @override
  String get searchTryDifferentFilters => '다른 필터를 사용해 보세요';

  @override
  String get librarySignOutTitle => '로그아웃하시겠어요?';

  @override
  String get librarySignOutConfirmation => '이 계정에서 로그아웃하시겠습니까?';

  @override
  String get librarySignOut => '로그아웃';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    return '선택한 영화 $count개를 삭제하시겠습니까?';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => '이 영화를 시청 기록에서 삭제하시겠습니까?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    return '시청 기록에서 영화 $count개를 삭제하시겠습니까?';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle => '이 영화를 즐겨찾기에서 삭제하시겠습니까?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    return '즐겨찾기에서 영화 $count개를 삭제하시겠습니까?';
  }

  @override
  String get libraryCancelSelection => '선택 취소';

  @override
  String get libraryDeleteSelectedMovies => '선택한 영화 삭제';

  @override
  String get libraryCannotResumeMovie => '지금은 이 영화를 이어서 재생할 수 없습니다.';

  @override
  String get libraryYourProfile => '내 프로필';

  @override
  String get librarySignInProfileDescription =>
      '프로필을 수정하고 시청 기록을 동기화하려면 로그인하세요.';

  @override
  String get libraryWatchHistory => '시청 기록';

  @override
  String get libraryNoWatchHistory => '아직 시청 기록이 없습니다';

  @override
  String get libraryFavorites => '즐겨찾기';

  @override
  String get librarySignInToSaveFavorites => '좋아하는 영화를 저장하려면 로그인하세요';

  @override
  String get libraryFavoritesSyncDescription => '목록이 여러 기기에서 동기화됩니다.';

  @override
  String get libraryNoFavorites => '아직 즐겨찾기한 영화가 없습니다';

  @override
  String get libraryRemoveFromList => '목록에서 삭제';

  @override
  String libraryContinueProgress(int progress) {
    return '$progress%부터 계속';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed => '라이브러리를 불러올 수 없습니다. 다시 시도해 주세요.';

  @override
  String get libraryFavoriteUpdateFailed => '즐겨찾기를 업데이트할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get libraryFavoriteRemoveFailed => '즐겨찾기에서 삭제할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get libraryHistorySyncLater => '시청 기록은 나중에 다시 동기화됩니다.';

  @override
  String get libraryHistoryDeleteFailed => '시청 기록을 삭제할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get profileEdit => '프로필 수정';

  @override
  String get profileChangePhoto => '사진 변경';

  @override
  String get profileName => '이름';

  @override
  String get profileNameDescription => '이 이름은 Liquid Phim 프로필에 표시됩니다.';

  @override
  String get profileNameHint => '표시 이름 입력';

  @override
  String get profileClearName => '이름 지우기';

  @override
  String get profileEmailDescription => '이 이메일은 계정에 연결되어 있으며 여기에서만 표시됩니다.';

  @override
  String get profileChangeAvatar => '프로필 사진 변경';

  @override
  String get profileTakePhoto => '사진 촬영';

  @override
  String get profileUploadPhoto => '사진 업로드';

  @override
  String get profileViewPhoto => '사진 보기';

  @override
  String get profileAvatar => '프로필 사진';

  @override
  String get profileCropAvatar => '프로필 사진 자르기';

  @override
  String get profileAvatarUpdated => '프로필 사진이 업데이트되었습니다.';

  @override
  String get profileAvatarUpdateFailed => '프로필 사진을 업데이트할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get profilePhotoOpenFailed => '사진을 열 수 없습니다. 사진 접근 권한을 확인해 주세요.';

  @override
  String get profileNameUpdated => '표시 이름이 업데이트되었습니다.';

  @override
  String get profileNameUpdateFailed => '이름을 업데이트할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get profileNameRequired => '이름을 입력해 주세요.';

  @override
  String get profileUpdatedProfileReadFailed => '업데이트된 프로필을 읽을 수 없습니다.';

  @override
  String get detailCastUnavailable => '출연진 정보가 없습니다';

  @override
  String get detailCast => '출연진';

  @override
  String get detailRecommendationsLoadFailed => '추천 콘텐츠를 불러올 수 없습니다';

  @override
  String get detailNoRecommendations => '추천 콘텐츠가 없습니다';

  @override
  String detailEpisodeNotFound(int episode) {
    return '현재 서버에서 $episode화를 이용할 수 없습니다.';
  }

  @override
  String get detailNoEpisodes => '이용 가능한 에피소드가 없습니다';

  @override
  String get detailWatchThisVersion => '이 버전 시청';

  @override
  String get detailServer => '서버';

  @override
  String detailServerNumber(int number) {
    return '서버 $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return '1–$count화';
  }

  @override
  String get detailEnterEpisode => '회차 입력';

  @override
  String get detailLoadMovieError => '영화를 불러올 수 없습니다';

  @override
  String get detailEpisodesTab => '에피소드';

  @override
  String get detailRecommendationsTab => '추천';

  @override
  String get detailCommentsTab => '댓글';

  @override
  String get detailInTheaters => '극장 상영';

  @override
  String get detailExclusiveSubtitles => '독점 자막';

  @override
  String get detailDirectorLabel => '감독:';

  @override
  String get detailCreatedDateLabel => '추가일:';

  @override
  String get detailProductionYearLabel => '제작 연도:';

  @override
  String get detailCountryLabel => '국가:';

  @override
  String get detailWatchLatestEpisode => '최신화 시청';

  @override
  String get detailWatchMovie => '영화 시청';

  @override
  String get detailIntroduction => '개요';

  @override
  String get detailFavorite => '즐겨찾기';

  @override
  String get detailContent => '줄거리';

  @override
  String get detailNoPlayableEpisodes =>
      '아직 재생 가능한 에피소드가 없습니다. 나중에 다시 시도해 주세요.';

  @override
  String get detailDetails => '상세 정보';

  @override
  String get detailVideoQuality => '화질';

  @override
  String detailViews(String count) {
    return '조회 $count회';
  }

  @override
  String detailLikes(String count) {
    return '좋아요 $count개';
  }

  @override
  String get detailUpdatedJustNow => '방금 업데이트됨';

  @override
  String get playerSubtitleServer => '자막';

  @override
  String get playerNowPlaying => '재생 중';

  @override
  String playerNowPlayingEpisode(String episode) {
    return '재생 중: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable => '이 서버에는 재생 가능한 소스가 없습니다.';

  @override
  String get playerSourceLoadFailed => '이 영상 소스를 불러올 수 없습니다.';

  @override
  String get playerAutoplayEnabled => '자동 재생이 켜졌습니다';

  @override
  String get playerAutoplayDisabled => '자동 재생이 꺼졌습니다';

  @override
  String get playerNoMoreEpisodes => '마지막 에피소드입니다';

  @override
  String get playerFirstEpisode => '첫 번째 에피소드입니다';

  @override
  String get playerPlaybackFailed => '영상을 재생할 수 없습니다. 다시 시도해 주세요.';

  @override
  String get playerPlay => '재생';

  @override
  String get playerPause => '일시정지';

  @override
  String get playerPullDownToCloseComments => '아래로 당겨 댓글 닫기';

  @override
  String get playerPlayOnTv => 'TV에서 재생';

  @override
  String get playerEpisodeList => '에피소드 목록';

  @override
  String get playerVideoProgress => '재생 위치';

  @override
  String get playerClose => '플레이어 닫기';

  @override
  String get playerContinueWatchingTitle => '계속 시청하시겠어요?';

  @override
  String playerContinueWatchingBody(String episode) {
    return '$episode을(를) 시청하고 있었습니다. 이어서 시청할까요, 아니면 1화부터 다시 시작할까요?';
  }

  @override
  String get playerRestartFromBeginning => '처음부터 다시 시작';

  @override
  String get playerContinue => '계속';

  @override
  String get commentsReply => '답글';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '답글 $count개',
      zero: '답글 없음',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => '댓글을 불러올 수 없습니다';

  @override
  String get commentsEmptyTitle => '아직 댓글이 없습니다';

  @override
  String get commentsEmptySubtitle => '첫 번째로 의견을 남겨보세요.';

  @override
  String get commentsEditHint => '댓글 수정...';

  @override
  String commentsReplyToHint(String name) {
    return '$name님에게 답글...';
  }

  @override
  String get commentsAddReplyHint => '답글 추가...';

  @override
  String get commentsComposerHint => '댓글 작성...';

  @override
  String get commentsEditingStatus => '댓글 수정 중';

  @override
  String commentsReplyingStatus(String name) {
    return '$name님에게 답글 작성 중';
  }

  @override
  String get commentsWrite => '댓글 작성';

  @override
  String get commentsSend => '보내기';

  @override
  String get commentsCloseMenu => '댓글 메뉴 닫기';

  @override
  String get commentsCopied => '댓글이 복사되었습니다';

  @override
  String get commentsYourComment => '내 댓글';

  @override
  String get commentsReportReasonTitle => '이 댓글을 신고하는 이유는 무엇인가요?';

  @override
  String get commentsReportSent => '신고가 전송되었습니다. 감사합니다.';

  @override
  String get commentsDeleteTitle => '댓글을 삭제하시겠습니까?';

  @override
  String get commentsRepliesPreserved => '답글은 유지됩니다.';

  @override
  String get commentsDeleteAction => '댓글 삭제';

  @override
  String get commentsSortTitle => '댓글 정렬';

  @override
  String get commentsPopular => '인기순';

  @override
  String get commentsNewest => '최신순';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '댓글 $count개',
      zero: '댓글',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => '댓글 복사';

  @override
  String get commentsEdited => '수정됨';

  @override
  String get commentsDeleted => '삭제된 댓글';

  @override
  String get commentsJustNow => '방금';

  @override
  String commentsMinutesAgo(int count) {
    return '$count분 전';
  }

  @override
  String commentsHoursAgo(int count) {
    return '$count시간 전';
  }

  @override
  String commentsDaysAgo(int count) {
    return '$count일 전';
  }

  @override
  String commentsWeeksAgo(int count) {
    return '$count주 전';
  }

  @override
  String commentsMonthsAgo(int count) {
    return '$count개월 전';
  }

  @override
  String commentsYearsAgo(int count) {
    return '$count년 전';
  }

  @override
  String get commentsSpamReason => '스팸';

  @override
  String get commentsHarassmentReason => '괴롭힘 또는 악성 행위';

  @override
  String get commentsSpoilerReason => '영화 스포일러';

  @override
  String get commentsInappropriateReason => '부적절한 콘텐츠';

  @override
  String get commentsOtherReason => '기타';

  @override
  String get commentsLoadFailed => '댓글을 불러올 수 없습니다. 다시 시도해 주세요.';

  @override
  String get commentsLoadMoreFailed => '댓글을 더 불러올 수 없습니다.';

  @override
  String get commentsRepliesLoadFailed => '답글을 불러올 수 없습니다.';

  @override
  String get commentsRepliesLoadMoreFailed => '답글을 더 불러올 수 없습니다.';

  @override
  String get commentsSendFailed => '댓글을 보낼 수 없습니다. 작성한 내용은 유지되었습니다.';

  @override
  String get commentsEditFailed => '댓글을 수정할 수 없습니다.';

  @override
  String get commentsDeleteFailed => '댓글을 삭제할 수 없습니다.';

  @override
  String get commentsReactionFailed => '반응을 업데이트할 수 없습니다.';

  @override
  String get commentsReportFailed => '이미 신고된 댓글이거나 신고를 전송할 수 없습니다.';

  @override
  String get commentsOperationInProgress => '이 작업은 이미 진행 중입니다.';

  @override
  String get notificationsEmpty => '새 알림이 없습니다';

  @override
  String get notificationsRepliedToYourComment => '회원님의 댓글에 답글을 남겼습니다';

  @override
  String get notificationsLikedYourComment => '회원님의 댓글을 좋아합니다';

  @override
  String get notificationsToday => '오늘';

  @override
  String get notificationsYesterday => '어제';

  @override
  String get notificationsUnknownUser => '누군가';

  @override
  String get notificationsNewMovieTitle => '새 영화';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '새 영화 $count편';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName이(가) Liquid Phim에 추가되었습니다.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Liquid Phim에서 새 영화를 발견했을 때 알림';

  @override
  String get castChooseDevice => '기기 선택';

  @override
  String get castAirPlayUnavailableTitle => 'AirPlay를 열 수 없습니다';

  @override
  String get castAirPlayUnavailableBody =>
      'iPhone과 TV 또는 Mac이 같은 Wi-Fi 네트워크에 연결되어 있는지 확인한 후 다시 시도해 주세요.';

  @override
  String get castVideoUnavailableTitle => '사용 가능한 영상 없음';

  @override
  String get castVideoUnavailableBody =>
      '영상이 로드될 때까지 기다린 다음 Google Cast 기기를 선택하세요.';

  @override
  String get castConnectionFailedTitle => 'Google Cast에 연결할 수 없습니다';

  @override
  String get castConnectionFailedBody =>
      'Google Play 서비스를 확인하고 휴대전화와 Chromecast 또는 Google TV가 같은 Wi-Fi 네트워크에 연결되어 있는지 확인하세요.';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay 및 Bluetooth 기기';

  @override
  String get castConnecting => '연결 중...';

  @override
  String get castSearching => 'Google Cast 기기 검색 중...';

  @override
  String get castNoDevices => '기기를 찾을 수 없습니다';

  @override
  String get castSameWifiGuidance =>
      '휴대전화와 Chromecast 또는 Google TV가 같은 Wi-Fi 네트워크에 연결되어 있는지 확인하세요.';

  @override
  String get castSearchAgain => '다시 검색';

  @override
  String get castDefaultDeviceName => 'Google Cast 기기';

  @override
  String shareMovieSubject(String movieName) {
    return 'Liquid Phim에서 $movieName 시청하기';
  }

  @override
  String get shareOpenFailed => '공유 화면을 열 수 없습니다.';

  @override
  String get rankingTopFavorites => '즐겨찾기 영화 TOP';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => '인기 영화 TOP 30';

  @override
  String get rankingMostViewed => '최다 조회';

  @override
  String get rankingMostLiked => '최다 좋아요';

  @override
  String get rankingEmptyLikes => '영화에 좋아요가 생기면 순위가 표시됩니다.';

  @override
  String get rankingEmptyViews => '영화 조회수가 생기면 순위가 표시됩니다.';

  @override
  String get rankingLoadFailed => '순위를 불러올 수 없습니다.';

  @override
  String playerEpisodeNumber(int number) {
    return '$number화';
  }

  @override
  String libraryMonthLabel(int month) {
    return '$month월';
  }
}
