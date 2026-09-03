// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'Trải nghiệm xem phim mọi lúc mọi nơi';

  @override
  String get commonAgree => 'Đồng ý';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonDone => 'Xong';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonEdit => 'Chỉnh sửa';

  @override
  String get commonReport => 'Báo cáo';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonReset => 'Đặt lại';

  @override
  String get commonAll => 'Tất cả';

  @override
  String get commonSeeMore => 'Xem thêm';

  @override
  String get commonCollapse => 'Thu gọn';

  @override
  String get commonLoading => 'Đang tải...';

  @override
  String get commonUpdating => 'Đang cập nhật';

  @override
  String get commonUnderstood => 'Đã hiểu';

  @override
  String get commonNoData => 'Không có dữ liệu';

  @override
  String get commonNotAvailable => 'Không có thông tin';

  @override
  String get commonWarningTitle => 'Cảnh báo';

  @override
  String get commonNoticeTitle => 'Thông báo';

  @override
  String get commonCongratulationsTitle => 'Chúc mừng!';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonGoHome => 'Về trang chủ';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count đã chọn',
      zero: 'Chưa chọn mục nào',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'Lỗi: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    return '$hours giờ $minutes phút';
  }

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get settingsLanguageSystem => 'Theo ngôn ngữ thiết bị';

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
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsGeneralSection => 'Cài đặt chung';

  @override
  String get settingsAppLanguage => 'Ngôn ngữ ứng dụng';

  @override
  String get settingsAccountSection => 'Tài khoản';

  @override
  String get settingsSwitchAccount => 'Chuyển đổi tài khoản';

  @override
  String get settingsAddAccount => 'Thêm tài khoản';

  @override
  String get settingsAccountSwitchFailed =>
      'Không thể chuyển tài khoản. Vui lòng đăng nhập lại tài khoản đó.';

  @override
  String get settingsSignOutFailed => 'Không thể đăng xuất. Vui lòng thử lại.';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navSearch => 'Tìm kiếm';

  @override
  String get navFavorites => 'Yêu thích';

  @override
  String get navProfile => 'Hồ sơ';

  @override
  String get navNotifications => 'Thông báo';

  @override
  String get internetOffline => 'Không có Internet';

  @override
  String get internetBackOnline => 'Quay lại trực tuyến';

  @override
  String get authJoinMember => 'Tham gia thành viên';

  @override
  String get authSignInTitle => 'Đăng nhập Liquid Phim';

  @override
  String get authSignIn => 'Đăng nhập';

  @override
  String get authSignInFailed => 'Đăng nhập chưa thành công. Hãy thử lại.';

  @override
  String get authSignInToComment =>
      'Đăng nhập để bình luận và tương tác cùng mọi người.';

  @override
  String get authGoogleSyncDescription =>
      'Tiếp tục với Google để đồng bộ tài khoản và tham gia cộng đồng.';

  @override
  String get authGoogleConsent =>
      'Bằng việc tiếp tục, bạn đồng ý sử dụng tài khoản Google cho Liquid Phim.';

  @override
  String get authContinueWithGoogle => 'Tiếp tục với Google';

  @override
  String get authGoogleSignInFailed =>
      'Không thể đăng nhập với Google. Vui lòng thử lại.';

  @override
  String get authGoogleSignInCheckFailed =>
      'Không thể đăng nhập với Google. Vui lòng kiểm tra và thử lại.';

  @override
  String get authSessionUpdateFailed => 'Không thể cập nhật phiên đăng nhập.';

  @override
  String get authLoginRequired => 'Bạn cần đăng nhập.';

  @override
  String get authLoginRequiredForAction =>
      'Bạn cần đăng nhập để thực hiện thao tác này.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Mật khẩu';

  @override
  String get authFullName => 'Họ và tên';

  @override
  String get authForgotPassword => 'Quên mật khẩu?';

  @override
  String get authOrContinueWith => 'Hoặc tiếp tục với';

  @override
  String get authAlreadyHaveAccount => 'Bạn đã có tài khoản?';

  @override
  String get authFullNameRequired => 'Họ và tên không được để trống.';

  @override
  String get authFullNameLength => 'Họ và tên phải có từ 3 đến 15 ký tự.';

  @override
  String get authEmailRequired => 'Email không được để trống.';

  @override
  String get authEmailInvalid => 'Vui lòng nhập đúng định dạng email.';

  @override
  String get authPasswordRequired => 'Mật khẩu không được để trống.';

  @override
  String get authPasswordLength => 'Mật khẩu phải có từ 6 đến 15 ký tự.';

  @override
  String get authAccountAlreadyExists =>
      'Tài khoản này đã tồn tại. Vui lòng chọn email khác.';

  @override
  String get authWeakPassword =>
      'Mật khẩu này chưa đủ mạnh. Vui lòng nhập mật khẩu mạnh hơn.';

  @override
  String get authInvalidCredentials =>
      'Email hoặc mật khẩu không đúng. Vui lòng thử lại.';

  @override
  String get authUnexpectedError => 'Đã xảy ra lỗi. Vui lòng thử lại.';

  @override
  String get authSignUpFailed => 'Không thể tạo tài khoản. Vui lòng thử lại.';

  @override
  String get authSignUpSucceeded => 'Tài khoản của bạn đã được tạo.';

  @override
  String get authSignInSucceeded => 'Đăng nhập thành công.';

  @override
  String get authSignOutSucceeded => 'Đăng xuất thành công.';

  @override
  String get authTokenConfirmed => 'Đã xác nhận mã xác minh.';

  @override
  String get authTokenInvalid => 'Mã xác minh không đúng.';

  @override
  String get homeEnableNewMovieNotificationsTitle => 'Nhận thông báo phim mới?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim có thể kiểm tra định kỳ trong nền và thông báo khi phát hiện phim mới. Hệ điều hành có thể thực hiện việc kiểm tra trễ hơn 20 phút để tiết kiệm pin.';

  @override
  String get homeEnableNotifications => 'Bật thông báo';

  @override
  String get homeDoNotEnable => 'Không bật';

  @override
  String get homeNotificationPermissionDisabled =>
      'Quyền thông báo chưa được bật. Bạn có thể bật lại trong Cài đặt của điện thoại.';

  @override
  String get homeLoadMoviesFailed =>
      'Không thể tải dữ liệu phim.\nKéo xuống để thử lại.';

  @override
  String get homeRecommended => 'Đề xuất';

  @override
  String get homeGenres => 'Thể loại';

  @override
  String get homeCountries => 'Quốc gia';

  @override
  String get homeYear => 'Năm';

  @override
  String get homeFreshMovies => 'Phim mới coóng!';

  @override
  String get homeKoreanMovies => 'Phim Hàn Quốc';

  @override
  String get homeChineseMovies => 'Phim Trung Quốc';

  @override
  String get homeUsUkMovies => 'Phim Mỹ - UK';

  @override
  String get homeWatchMovie => 'Xem phim';

  @override
  String get homeInformation => 'Thông tin';

  @override
  String get homeViewAll => 'Xem tất cả';

  @override
  String get homeWhatToWatch => 'Bạn muốn xem gì hôm nay?';

  @override
  String get homeViewMore => 'Xem thêm';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'Phiên bản: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'Loại phim';

  @override
  String get filterSeries => 'Phim bộ';

  @override
  String get filterSingleMovies => 'Phim lẻ';

  @override
  String get filterAnimation => 'Hoạt hình';

  @override
  String get filterTvShows => 'TV Shows';

  @override
  String get filterSubtitled => 'Phim Vietsub';

  @override
  String get filterVoiceOver => 'Phim thuyết minh';

  @override
  String get filterDubbed => 'Phim lồng tiếng';

  @override
  String get filterChooseMovieType => 'Làm ơn hãy chọn loại phim!';

  @override
  String get filterChooseGenre => 'Làm ơn hãy chọn thể loại!';

  @override
  String get filterChooseCountry => 'Chọn quốc gia để lọc!';

  @override
  String get filterChooseYear => 'Chọn năm để lọc!';

  @override
  String get filterLanguage => 'Ngôn ngữ';

  @override
  String get filterSortBy => 'Sắp xếp';

  @override
  String get filterSortDirection => 'Chiều sắp xếp';

  @override
  String get filterDescending => 'Giảm dần';

  @override
  String get filterAscending => 'Tăng dần';

  @override
  String get filterMostViewed => 'Xem nhiều';

  @override
  String get filterNewest => 'Mới nhất';

  @override
  String get filterReleaseYear => 'Năm phát hành';

  @override
  String get filterApply => 'Áp dụng bộ lọc';

  @override
  String get filterResults => 'Lọc kết quả';

  @override
  String get searchAttentionTitle => 'Chú ý!';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'Nhập từ khóa trước khi lọc phim.';

  @override
  String get searchNoResults => 'Không tìm thấy kết quả nào';

  @override
  String get searchMovieActorHint => 'Tìm kiếm phim, diễn viên...';

  @override
  String get searchFilterTooltip => 'Bộ lọc tìm kiếm';

  @override
  String get searchStartPrompt => 'Hãy nhập tên phim để tìm kiếm';

  @override
  String get searchRecent => 'Tìm kiếm gần đây';

  @override
  String get searchLoadingGenres => 'Đang tải thể loại...';

  @override
  String get searchLoadingCountries => 'Đang tải quốc gia...';

  @override
  String get searchNoMovies => 'Không có phim';

  @override
  String get searchTryDifferentFilters => 'Thử lại với bộ lọc khác';

  @override
  String get librarySignOutTitle => 'Đăng xuất?';

  @override
  String get librarySignOutConfirmation =>
      'Bạn có chắc muốn đăng xuất khỏi tài khoản này?';

  @override
  String get librarySignOut => 'Đăng xuất';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phim đã chọn?',
      one: 'phim đã chọn?',
    );
    return 'Xóa $_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => 'Xóa lịch sử phim này?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phim',
      one: 'phim này',
    );
    return 'Bạn có đồng ý xóa $_temp0 khỏi lịch sử xem không?';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle =>
      'Xóa phim này khỏi danh sách yêu thích?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phim',
      one: 'phim này',
    );
    return 'Bạn có đồng ý xóa $_temp0 khỏi danh sách yêu thích không?';
  }

  @override
  String get libraryCancelSelection => 'Hủy chọn';

  @override
  String get libraryDeleteSelectedMovies => 'Xóa phim đã chọn';

  @override
  String get libraryCannotResumeMovie => 'Không thể mở lại phim lúc này.';

  @override
  String get libraryYourProfile => 'Hồ sơ của bạn';

  @override
  String get librarySignInProfileDescription =>
      'Đăng nhập để chỉnh sửa hồ sơ và đồng bộ lịch sử xem.';

  @override
  String get libraryWatchHistory => 'Lịch sử xem';

  @override
  String get libraryNoWatchHistory => 'Chưa có lịch sử xem';

  @override
  String get libraryFavorites => 'Yêu thích';

  @override
  String get librarySignInToSaveFavorites => 'Đăng nhập để lưu phim yêu thích';

  @override
  String get libraryFavoritesSyncDescription =>
      'Danh sách của bạn sẽ được đồng bộ trên các thiết bị.';

  @override
  String get libraryNoFavorites => 'Chưa có phim yêu thích';

  @override
  String get libraryRemoveFromList => 'Xóa khỏi danh sách';

  @override
  String libraryContinueProgress(int progress) {
    return 'Tiếp tục $progress%';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed => 'Không thể tải thư viện. Hãy thử lại.';

  @override
  String get libraryFavoriteUpdateFailed =>
      'Không thể cập nhật yêu thích. Hãy thử lại.';

  @override
  String get libraryFavoriteRemoveFailed =>
      'Không thể bỏ yêu thích. Hãy thử lại.';

  @override
  String get libraryHistorySyncLater => 'Lịch sử sẽ được đồng bộ lại sau.';

  @override
  String get libraryHistoryDeleteFailed =>
      'Không thể xóa lịch sử. Hãy thử lại.';

  @override
  String get profileEdit => 'Sửa hồ sơ';

  @override
  String get profileChangePhoto => 'Thay đổi ảnh';

  @override
  String get profileName => 'Tên';

  @override
  String get profileNameDescription =>
      'Tên này sẽ hiển thị trên hồ sơ Liquid Phim của bạn.';

  @override
  String get profileNameHint => 'Nhập tên hiển thị';

  @override
  String get profileClearName => 'Xóa tên';

  @override
  String get profileEmailDescription =>
      'Email được liên kết với tài khoản và chỉ hiển thị tại đây.';

  @override
  String get profileChangeAvatar => 'Thay đổi ảnh đại diện';

  @override
  String get profileTakePhoto => 'Chụp ảnh';

  @override
  String get profileUploadPhoto => 'Tải ảnh lên';

  @override
  String get profileViewPhoto => 'Xem ảnh';

  @override
  String get profileAvatar => 'Ảnh đại diện';

  @override
  String get profileCropAvatar => 'Cắt ảnh đại diện';

  @override
  String get profileAvatarUpdated => 'Đã cập nhật ảnh đại diện.';

  @override
  String get profileAvatarUpdateFailed =>
      'Không thể cập nhật ảnh đại diện. Hãy thử lại.';

  @override
  String get profilePhotoOpenFailed =>
      'Không thể mở ảnh. Hãy kiểm tra quyền truy cập.';

  @override
  String get profileNameUpdated => 'Đã cập nhật tên hiển thị.';

  @override
  String get profileNameUpdateFailed => 'Không thể cập nhật tên. Hãy thử lại.';

  @override
  String get profileNameRequired => 'Tên không được để trống.';

  @override
  String get profileUpdatedProfileReadFailed =>
      'Không thể đọc hồ sơ vừa cập nhật.';

  @override
  String get detailCastUnavailable => 'Không có thông tin diễn viên';

  @override
  String get detailCast => 'Diễn viên';

  @override
  String get detailRecommendationsLoadFailed => 'Không thể tải đề xuất';

  @override
  String get detailNoRecommendations => 'Không có đề xuất';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'Không tìm thấy tập $episode trên server hiện tại.';
  }

  @override
  String get detailNoEpisodes => 'Chưa có tập phim nào';

  @override
  String get detailWatchThisVersion => 'Xem bản này';

  @override
  String get detailServer => 'Server';

  @override
  String detailServerNumber(int number) {
    return 'Server $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'Tập 1–$count';
  }

  @override
  String get detailEnterEpisode => 'Nhập tập';

  @override
  String get detailLoadMovieError => 'Lỗi tải phim';

  @override
  String get detailEpisodesTab => 'Tập phim';

  @override
  String get detailRecommendationsTab => 'Đề xuất';

  @override
  String get detailCommentsTab => 'Bình luận';

  @override
  String get detailInTheaters => 'Chiếu rạp';

  @override
  String get detailExclusiveSubtitles => 'Sub độc quyền';

  @override
  String get detailDirectorLabel => 'Đạo diễn:';

  @override
  String get detailCreatedDateLabel => 'Ngày tạo:';

  @override
  String get detailProductionYearLabel => 'Năm sản xuất:';

  @override
  String get detailCountryLabel => 'Quốc gia:';

  @override
  String get detailWatchLatestEpisode => 'Xem tập mới';

  @override
  String get detailWatchMovie => 'Xem phim';

  @override
  String get detailIntroduction => 'Giới thiệu';

  @override
  String get detailFavorite => 'Yêu thích';

  @override
  String get detailContent => 'Nội dung';

  @override
  String get detailNoPlayableEpisodes =>
      'Phim hiện chưa có tập để xem. Vui lòng thử lại sau nhé!';

  @override
  String get detailDetails => 'Chi tiết';

  @override
  String get detailVideoQuality => 'Chất lượng video';

  @override
  String detailViews(String count) {
    return '$count lượt xem';
  }

  @override
  String detailLikes(String count) {
    return '$count lượt thích';
  }

  @override
  String get detailUpdatedJustNow => 'Vừa cập nhật';

  @override
  String get playerSubtitleServer => 'Phụ đề';

  @override
  String get playerNowPlaying => 'Đang phát';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'Đang phát: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode - $server';
  }

  @override
  String get playerSourceUnavailable => 'Server này chưa có nguồn phát.';

  @override
  String get playerSourceLoadFailed => 'Không tải được nguồn phim này.';

  @override
  String get playerAutoplayEnabled => 'Đã bật tự động phát';

  @override
  String get playerAutoplayDisabled => 'Đã tắt tự động phát';

  @override
  String get playerNoMoreEpisodes => 'Đã hết tập phim';

  @override
  String get playerFirstEpisode => 'Đây là tập đầu tiên';

  @override
  String get playerPlaybackFailed => 'Không thể phát video. Vui lòng thử lại.';

  @override
  String get playerPlay => 'Phát';

  @override
  String get playerPause => 'Tạm dừng';

  @override
  String get playerPullDownToCloseComments => 'Kéo xuống để đóng bình luận';

  @override
  String get playerPlayOnTv => 'Phát trên TV';

  @override
  String get playerEpisodeList => 'Danh sách tập';

  @override
  String get playerVideoProgress => 'Thanh tiến trình video';

  @override
  String get playerClose => 'Đóng trình phát';

  @override
  String get playerContinueWatchingTitle => 'Tiếp tục xem?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'Bạn đang xem $episode. Bạn muốn xem tiếp tập này hay xem lại từ tập 1?';
  }

  @override
  String get playerRestartFromBeginning => 'Xem lại từ đầu';

  @override
  String get playerContinue => 'Xem tiếp';

  @override
  String get commentsReply => 'Trả lời';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count phản hồi',
      zero: 'Chưa có phản hồi',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'Chưa tải được bình luận';

  @override
  String get commentsEmptyTitle => 'Chưa có bình luận';

  @override
  String get commentsEmptySubtitle => 'Hãy là người đầu tiên chia sẻ cảm nhận.';

  @override
  String get commentsEditHint => 'Chỉnh sửa bình luận...';

  @override
  String commentsReplyToHint(String name) {
    return 'Trả lời $name...';
  }

  @override
  String get commentsAddReplyHint => 'Thêm phản hồi...';

  @override
  String get commentsComposerHint => 'Bình luận...';

  @override
  String get commentsEditingStatus => 'Đang chỉnh sửa bình luận';

  @override
  String commentsReplyingStatus(String name) {
    return 'Đang trả lời $name';
  }

  @override
  String get commentsWrite => 'Viết bình luận';

  @override
  String get commentsSend => 'Gửi';

  @override
  String get commentsCloseMenu => 'Đóng menu bình luận';

  @override
  String get commentsCopied => 'Đã sao chép bình luận';

  @override
  String get commentsYourComment => 'Bình luận của bạn';

  @override
  String get commentsReportReasonTitle => 'Vì sao bạn báo cáo bình luận này?';

  @override
  String get commentsReportSent => 'Đã gửi báo cáo. Cảm ơn bạn.';

  @override
  String get commentsDeleteTitle => 'Xóa bình luận?';

  @override
  String get commentsRepliesPreserved => 'Các phản hồi vẫn được giữ lại.';

  @override
  String get commentsDeleteAction => 'Xóa bình luận';

  @override
  String get commentsSortTitle => 'Sắp xếp bình luận';

  @override
  String get commentsPopular => 'Phổ biến';

  @override
  String get commentsNewest => 'Mới nhất';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bình luận',
      zero: 'Bình luận',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'Sao chép bình luận';

  @override
  String get commentsEdited => 'Đã chỉnh sửa';

  @override
  String get commentsDeleted => 'Bình luận đã bị xóa';

  @override
  String get commentsJustNow => 'vừa xong';

  @override
  String commentsMinutesAgo(int count) {
    return '$count phút trước';
  }

  @override
  String commentsHoursAgo(int count) {
    return '$count giờ trước';
  }

  @override
  String commentsDaysAgo(int count) {
    return '$count ngày trước';
  }

  @override
  String commentsWeeksAgo(int count) {
    return '$count tuần trước';
  }

  @override
  String commentsMonthsAgo(int count) {
    return '$count tháng trước';
  }

  @override
  String commentsYearsAgo(int count) {
    return '$count năm trước';
  }

  @override
  String get commentsSpamReason => 'Nội dung rác';

  @override
  String get commentsHarassmentReason => 'Quấy rối hoặc công kích';

  @override
  String get commentsSpoilerReason => 'Tiết lộ nội dung phim';

  @override
  String get commentsInappropriateReason => 'Nội dung không phù hợp';

  @override
  String get commentsOtherReason => 'Lý do khác';

  @override
  String get commentsLoadFailed => 'Không tải được bình luận. Hãy thử lại.';

  @override
  String get commentsLoadMoreFailed => 'Chưa tải thêm được bình luận.';

  @override
  String get commentsRepliesLoadFailed => 'Không tải được phần trả lời.';

  @override
  String get commentsRepliesLoadMoreFailed =>
      'Chưa tải thêm được phần trả lời.';

  @override
  String get commentsSendFailed =>
      'Chưa gửi được bình luận. Nội dung vẫn được giữ lại.';

  @override
  String get commentsEditFailed => 'Không thể chỉnh sửa bình luận.';

  @override
  String get commentsDeleteFailed => 'Không thể xóa bình luận.';

  @override
  String get commentsReactionFailed => 'Không thể cập nhật cảm xúc.';

  @override
  String get commentsReportFailed =>
      'Bình luận này đã được báo cáo hoặc chưa thể gửi.';

  @override
  String get commentsOperationInProgress => 'Thao tác này đang được xử lý.';

  @override
  String get notificationsEmpty => 'Chưa có thông báo mới';

  @override
  String get notificationsRepliedToYourComment =>
      'đã trả lời bình luận của bạn';

  @override
  String get notificationsLikedYourComment => 'đã thích bình luận của bạn';

  @override
  String get notificationsToday => 'Hôm nay';

  @override
  String get notificationsYesterday => 'Hôm qua';

  @override
  String get notificationsUnknownUser => 'Một người dùng';

  @override
  String get notificationsNewMovieTitle => 'Có phim mới';

  @override
  String notificationsNewMoviesTitle(int count) {
    return 'Có $count phim mới';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName vừa được thêm vào Liquid Phim.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Thông báo khi Liquid Phim phát hiện phim mới';

  @override
  String get castChooseDevice => 'Chọn thiết bị';

  @override
  String get castAirPlayUnavailableTitle => 'Không thể mở AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      'Hãy kiểm tra iPhone và TV/Mac đang cùng Wi-Fi rồi thử lại.';

  @override
  String get castVideoUnavailableTitle => 'Chưa có video để phát';

  @override
  String get castVideoUnavailableBody =>
      'Hãy chờ video tải xong rồi chọn thiết bị Google Cast.';

  @override
  String get castConnectionFailedTitle => 'Không thể kết nối Google Cast';

  @override
  String get castConnectionFailedBody =>
      'Hãy kiểm tra Google Play services và bảo đảm điện thoại, Chromecast hoặc Google TV đang cùng Wi-Fi.';

  @override
  String get castAirPlayAndBluetoothDevices =>
      'Các thiết bị AirPlay và Bluetooth';

  @override
  String get castConnecting => 'Đang kết nối...';

  @override
  String get castSearching => 'Đang tìm thiết bị Google Cast...';

  @override
  String get castNoDevices => 'Không tìm thấy thiết bị';

  @override
  String get castSameWifiGuidance =>
      'Hãy bảo đảm điện thoại và Chromecast hoặc Google TV đang cùng Wi-Fi.';

  @override
  String get castSearchAgain => 'Tìm lại';

  @override
  String get castDefaultDeviceName => 'Thiết bị Google Cast';

  @override
  String shareMovieSubject(String movieName) {
    return 'Xem $movieName trên Liquid Phim';
  }

  @override
  String get shareOpenFailed => 'Không thể mở bảng chia sẻ.';

  @override
  String get rankingTopFavorites => 'TOP Phim yêu thích';

  @override
  String get rankingTopLiquidPhim => 'TOP 30 của Liquid Phim';

  @override
  String get rankingTopHotMovies => 'TOP 30 Phim Lẻ Hot';

  @override
  String get rankingMostViewed => 'XEM NHIỀU NHẤT';

  @override
  String get rankingMostLiked => 'THÍCH NHIỀU NHẤT';

  @override
  String get rankingEmptyLikes =>
      'Bảng xếp hạng sẽ xuất hiện khi có lượt thích.';

  @override
  String get rankingEmptyViews => 'Bảng xếp hạng sẽ xuất hiện khi có lượt xem.';

  @override
  String get rankingLoadFailed => 'Chưa thể tải bảng xếp hạng.';

  @override
  String playerEpisodeNumber(int number) {
    return 'Tập $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'tháng $month';
  }
}
