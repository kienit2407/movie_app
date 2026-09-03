// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'Movies anytime, anywhere';

  @override
  String get commonAgree => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDone => 'Done';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonReport => 'Report';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonAll => 'All';

  @override
  String get commonSeeMore => 'See more';

  @override
  String get commonCollapse => 'Show less';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonUpdating => 'Updating';

  @override
  String get commonUnderstood => 'Got it';

  @override
  String get commonNoData => 'No data';

  @override
  String get commonNotAvailable => 'N/A';

  @override
  String get commonWarningTitle => 'Warning';

  @override
  String get commonNoticeTitle => 'Notice';

  @override
  String get commonCongratulationsTitle => 'Congratulations!';

  @override
  String get commonBack => 'Back';

  @override
  String get commonGoHome => 'Go to home';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected',
      one: '1 selected',
      zero: 'Nothing selected',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'Error: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours hours',
      one: '1 hour',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'Use device language';

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
  String get settingsTitle => 'Settings';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsAppLanguage => 'App language';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsSwitchAccount => 'Switch account';

  @override
  String get settingsAddAccount => 'Add account';

  @override
  String get settingsAccountSwitchFailed =>
      'Could not switch accounts. Please sign in to that account again.';

  @override
  String get settingsSignOutFailed => 'Could not sign out. Please try again.';

  @override
  String get navHome => 'Home';

  @override
  String get navSearch => 'Search';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get internetOffline => 'No Internet connection';

  @override
  String get internetBackOnline => 'Back online';

  @override
  String get authJoinMember => 'Join as a member';

  @override
  String get authSignInTitle => 'Sign in to Liquid Phim';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignInFailed => 'Sign-in was unsuccessful. Please try again.';

  @override
  String get authSignInToComment =>
      'Sign in to comment and interact with the community.';

  @override
  String get authGoogleSyncDescription =>
      'Continue with Google to sync your account and join the community.';

  @override
  String get authGoogleConsent =>
      'By continuing, you agree to use your Google account with Liquid Phim.';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authGoogleSignInFailed =>
      'Could not sign in with Google. Please try again.';

  @override
  String get authGoogleSignInCheckFailed =>
      'Could not sign in with Google. Please check your connection and try again.';

  @override
  String get authSessionUpdateFailed =>
      'Could not update your sign-in session.';

  @override
  String get authLoginRequired => 'You need to sign in.';

  @override
  String get authLoginRequiredForAction =>
      'You need to sign in to perform this action.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authFullName => 'Full name';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authOrContinueWith => 'Or continue with';

  @override
  String get authAlreadyHaveAccount => 'Already have an account?';

  @override
  String get authFullNameRequired => 'Full name cannot be blank.';

  @override
  String get authFullNameLength =>
      'Full name must contain between 3 and 15 characters.';

  @override
  String get authEmailRequired => 'Email cannot be blank.';

  @override
  String get authEmailInvalid => 'Enter a valid email address.';

  @override
  String get authPasswordRequired => 'Password cannot be blank.';

  @override
  String get authPasswordLength =>
      'Password must contain between 6 and 15 characters.';

  @override
  String get authAccountAlreadyExists =>
      'This account already exists. Please choose another email.';

  @override
  String get authWeakPassword =>
      'This password is too weak. Please enter a stronger password.';

  @override
  String get authInvalidCredentials =>
      'The email or password is incorrect. Please try again.';

  @override
  String get authUnexpectedError => 'Something went wrong. Please try again.';

  @override
  String get authSignUpFailed =>
      'Could not create your account. Please try again.';

  @override
  String get authSignUpSucceeded => 'Your account has been created.';

  @override
  String get authSignInSucceeded => 'Signed in successfully.';

  @override
  String get authSignOutSucceeded => 'Signed out successfully.';

  @override
  String get authTokenConfirmed => 'Verification code confirmed.';

  @override
  String get authTokenInvalid => 'The verification code is incorrect.';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      'Get new movie notifications?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim can check periodically in the background and notify you when new movies are found. The operating system might delay checks by more than 20 minutes to save battery.';

  @override
  String get homeEnableNotifications => 'Enable notifications';

  @override
  String get homeDoNotEnable => 'Not now';

  @override
  String get homeNotificationPermissionDisabled =>
      'Notification permission is disabled. You can enable it again in your phone settings.';

  @override
  String get homeLoadMoviesFailed =>
      'Could not load movies.\nPull down to try again.';

  @override
  String get homeRecommended => 'Recommended';

  @override
  String get homeGenres => 'Genres';

  @override
  String get homeCountries => 'Countries';

  @override
  String get homeYear => 'Year';

  @override
  String get homeFreshMovies => 'Fresh releases!';

  @override
  String get homeKoreanMovies => 'Korean movies';

  @override
  String get homeChineseMovies => 'Chinese movies';

  @override
  String get homeUsUkMovies => 'US & UK movies';

  @override
  String get homeWatchMovie => 'Watch';

  @override
  String get homeInformation => 'Info';

  @override
  String get homeViewAll => 'View all';

  @override
  String get homeWhatToWatch => 'What would you like to watch today?';

  @override
  String get homeViewMore => 'View more';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'Version: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'Movie type';

  @override
  String get filterSeries => 'Series';

  @override
  String get filterSingleMovies => 'Movies';

  @override
  String get filterAnimation => 'Animation';

  @override
  String get filterTvShows => 'TV shows';

  @override
  String get filterSubtitled => 'Subtitled';

  @override
  String get filterVoiceOver => 'Voice-over';

  @override
  String get filterDubbed => 'Dubbed';

  @override
  String get filterChooseMovieType => 'Please select a movie type.';

  @override
  String get filterChooseGenre => 'Please select a genre.';

  @override
  String get filterChooseCountry => 'Select a country to filter by.';

  @override
  String get filterChooseYear => 'Select a year to filter by.';

  @override
  String get filterLanguage => 'Language';

  @override
  String get filterSortBy => 'Sort by';

  @override
  String get filterSortDirection => 'Sort direction';

  @override
  String get filterDescending => 'Descending';

  @override
  String get filterAscending => 'Ascending';

  @override
  String get filterMostViewed => 'Most viewed';

  @override
  String get filterNewest => 'Newest';

  @override
  String get filterReleaseYear => 'Release year';

  @override
  String get filterApply => 'Apply filters';

  @override
  String get filterResults => 'Filter results';

  @override
  String get searchAttentionTitle => 'Attention';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'Enter a keyword before filtering movies.';

  @override
  String get searchNoResults => 'No results found';

  @override
  String get searchMovieActorHint => 'Search movies, actors...';

  @override
  String get searchFilterTooltip => 'Search filters';

  @override
  String get searchStartPrompt => 'Enter a movie title to start searching';

  @override
  String get searchRecent => 'Recent searches';

  @override
  String get searchLoadingGenres => 'Loading genres...';

  @override
  String get searchLoadingCountries => 'Loading countries...';

  @override
  String get searchNoMovies => 'No movies';

  @override
  String get searchTryDifferentFilters => 'Try different filters';

  @override
  String get librarySignOutTitle => 'Sign out?';

  @override
  String get librarySignOutConfirmation =>
      'Are you sure you want to sign out of this account?';

  @override
  String get librarySignOut => 'Sign out';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selected movies?',
      one: 'the selected movie?',
    );
    return 'Delete $_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle =>
      'Delete this movie from history?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies',
      one: 'this movie',
    );
    return 'Remove $_temp0 from watch history?';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle =>
      'Remove this movie from favorites?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count movies',
      one: 'this movie',
    );
    return 'Remove $_temp0 from favorites?';
  }

  @override
  String get libraryCancelSelection => 'Cancel selection';

  @override
  String get libraryDeleteSelectedMovies => 'Delete selected movies';

  @override
  String get libraryCannotResumeMovie => 'Cannot resume this movie right now.';

  @override
  String get libraryYourProfile => 'Your profile';

  @override
  String get librarySignInProfileDescription =>
      'Sign in to edit your profile and sync your watch history.';

  @override
  String get libraryWatchHistory => 'Watch history';

  @override
  String get libraryNoWatchHistory => 'No watch history yet';

  @override
  String get libraryFavorites => 'Favorites';

  @override
  String get librarySignInToSaveFavorites => 'Sign in to save favorite movies';

  @override
  String get libraryFavoritesSyncDescription =>
      'Your list will be synced across your devices.';

  @override
  String get libraryNoFavorites => 'No favorite movies yet';

  @override
  String get libraryRemoveFromList => 'Remove from list';

  @override
  String libraryContinueProgress(int progress) {
    return 'Continue $progress%';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed =>
      'Could not load your library. Please try again.';

  @override
  String get libraryFavoriteUpdateFailed =>
      'Could not update favorites. Please try again.';

  @override
  String get libraryFavoriteRemoveFailed =>
      'Could not remove the favorite. Please try again.';

  @override
  String get libraryHistorySyncLater =>
      'Your history will be synced again later.';

  @override
  String get libraryHistoryDeleteFailed =>
      'Could not delete watch history. Please try again.';

  @override
  String get profileEdit => 'Edit profile';

  @override
  String get profileChangePhoto => 'Change photo';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameDescription =>
      'This name will appear on your Liquid Phim profile.';

  @override
  String get profileNameHint => 'Enter a display name';

  @override
  String get profileClearName => 'Clear name';

  @override
  String get profileEmailDescription =>
      'This email is linked to your account and is only shown here.';

  @override
  String get profileChangeAvatar => 'Change profile photo';

  @override
  String get profileTakePhoto => 'Take photo';

  @override
  String get profileUploadPhoto => 'Upload photo';

  @override
  String get profileViewPhoto => 'View photo';

  @override
  String get profileAvatar => 'Profile photo';

  @override
  String get profileCropAvatar => 'Crop profile photo';

  @override
  String get profileAvatarUpdated => 'Profile photo updated.';

  @override
  String get profileAvatarUpdateFailed =>
      'Could not update the profile photo. Please try again.';

  @override
  String get profilePhotoOpenFailed =>
      'Could not open the photo. Check photo access permission.';

  @override
  String get profileNameUpdated => 'Display name updated.';

  @override
  String get profileNameUpdateFailed =>
      'Could not update the name. Please try again.';

  @override
  String get profileNameRequired => 'Name cannot be blank.';

  @override
  String get profileUpdatedProfileReadFailed =>
      'Could not read the updated profile.';

  @override
  String get detailCastUnavailable => 'Cast information is unavailable';

  @override
  String get detailCast => 'Cast';

  @override
  String get detailRecommendationsLoadFailed =>
      'Could not load recommendations';

  @override
  String get detailNoRecommendations => 'No recommendations';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'Episode $episode is unavailable on the current server.';
  }

  @override
  String get detailNoEpisodes => 'No episodes available';

  @override
  String get detailWatchThisVersion => 'Watch this version';

  @override
  String get detailServer => 'Server';

  @override
  String detailServerNumber(int number) {
    return 'Server $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'Episodes 1–$count';
  }

  @override
  String get detailEnterEpisode => 'Enter episode';

  @override
  String get detailLoadMovieError => 'Could not load movie';

  @override
  String get detailEpisodesTab => 'Episodes';

  @override
  String get detailRecommendationsTab => 'Recommendations';

  @override
  String get detailCommentsTab => 'Comments';

  @override
  String get detailInTheaters => 'In theaters';

  @override
  String get detailExclusiveSubtitles => 'Exclusive subtitles';

  @override
  String get detailDirectorLabel => 'Director:';

  @override
  String get detailCreatedDateLabel => 'Added on:';

  @override
  String get detailProductionYearLabel => 'Production year:';

  @override
  String get detailCountryLabel => 'Country:';

  @override
  String get detailWatchLatestEpisode => 'Watch latest episode';

  @override
  String get detailWatchMovie => 'Watch movie';

  @override
  String get detailIntroduction => 'Overview';

  @override
  String get detailFavorite => 'Favorite';

  @override
  String get detailContent => 'Synopsis';

  @override
  String get detailNoPlayableEpisodes =>
      'This movie does not have any playable episodes yet. Please try again later.';

  @override
  String get detailDetails => 'Details';

  @override
  String get detailVideoQuality => 'Video quality';

  @override
  String detailViews(String count) {
    return '$count views';
  }

  @override
  String detailLikes(String count) {
    return '$count likes';
  }

  @override
  String get detailUpdatedJustNow => 'Updated just now';

  @override
  String get playerSubtitleServer => 'Subtitled';

  @override
  String get playerNowPlaying => 'Now playing';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'Now playing: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable => 'This server has no playable source.';

  @override
  String get playerSourceLoadFailed => 'Could not load this movie source.';

  @override
  String get playerAutoplayEnabled => 'Autoplay enabled';

  @override
  String get playerAutoplayDisabled => 'Autoplay disabled';

  @override
  String get playerNoMoreEpisodes => 'You have reached the last episode';

  @override
  String get playerFirstEpisode => 'This is the first episode';

  @override
  String get playerPlaybackFailed =>
      'Could not play the video. Please try again.';

  @override
  String get playerPlay => 'Play';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPullDownToCloseComments => 'Pull down to close comments';

  @override
  String get playerPlayOnTv => 'Play on TV';

  @override
  String get playerEpisodeList => 'Episode list';

  @override
  String get playerVideoProgress => 'Video progress';

  @override
  String get playerClose => 'Close player';

  @override
  String get playerContinueWatchingTitle => 'Continue watching?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'You were watching $episode. Would you like to continue or restart from episode 1?';
  }

  @override
  String get playerRestartFromBeginning => 'Restart from the beginning';

  @override
  String get playerContinue => 'Continue';

  @override
  String get commentsReply => 'Reply';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count replies',
      one: '1 reply',
      zero: 'No replies',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'Could not load comments';

  @override
  String get commentsEmptyTitle => 'No comments yet';

  @override
  String get commentsEmptySubtitle => 'Be the first to share your thoughts.';

  @override
  String get commentsEditHint => 'Edit comment...';

  @override
  String commentsReplyToHint(String name) {
    return 'Reply to $name...';
  }

  @override
  String get commentsAddReplyHint => 'Add a reply...';

  @override
  String get commentsComposerHint => 'Write a comment...';

  @override
  String get commentsEditingStatus => 'Editing comment';

  @override
  String commentsReplyingStatus(String name) {
    return 'Replying to $name';
  }

  @override
  String get commentsWrite => 'Write a comment';

  @override
  String get commentsSend => 'Send';

  @override
  String get commentsCloseMenu => 'Close comment menu';

  @override
  String get commentsCopied => 'Comment copied';

  @override
  String get commentsYourComment => 'Your comment';

  @override
  String get commentsReportReasonTitle => 'Why are you reporting this comment?';

  @override
  String get commentsReportSent => 'Report sent. Thank you.';

  @override
  String get commentsDeleteTitle => 'Delete comment?';

  @override
  String get commentsRepliesPreserved => 'Replies will be preserved.';

  @override
  String get commentsDeleteAction => 'Delete comment';

  @override
  String get commentsSortTitle => 'Sort comments';

  @override
  String get commentsPopular => 'Popular';

  @override
  String get commentsNewest => 'Newest';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comments',
      one: '1 comment',
      zero: 'Comments',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'Copy comment';

  @override
  String get commentsEdited => 'Edited';

  @override
  String get commentsDeleted => 'Comment deleted';

  @override
  String get commentsJustNow => 'just now';

  @override
  String commentsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String commentsWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count weeks ago',
      one: '1 week ago',
    );
    return '$_temp0';
  }

  @override
  String commentsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months ago',
      one: '1 month ago',
    );
    return '$_temp0';
  }

  @override
  String commentsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years ago',
      one: '1 year ago',
    );
    return '$_temp0';
  }

  @override
  String get commentsSpamReason => 'Spam';

  @override
  String get commentsHarassmentReason => 'Harassment or abuse';

  @override
  String get commentsSpoilerReason => 'Movie spoiler';

  @override
  String get commentsInappropriateReason => 'Inappropriate content';

  @override
  String get commentsOtherReason => 'Other reason';

  @override
  String get commentsLoadFailed => 'Could not load comments. Please try again.';

  @override
  String get commentsLoadMoreFailed => 'Could not load more comments.';

  @override
  String get commentsRepliesLoadFailed => 'Could not load replies.';

  @override
  String get commentsRepliesLoadMoreFailed => 'Could not load more replies.';

  @override
  String get commentsSendFailed =>
      'Could not send the comment. Your text has been preserved.';

  @override
  String get commentsEditFailed => 'Could not edit the comment.';

  @override
  String get commentsDeleteFailed => 'Could not delete the comment.';

  @override
  String get commentsReactionFailed => 'Could not update the reaction.';

  @override
  String get commentsReportFailed =>
      'This comment has already been reported or the report could not be sent.';

  @override
  String get commentsOperationInProgress =>
      'This action is already in progress.';

  @override
  String get notificationsEmpty => 'No new notifications';

  @override
  String get notificationsRepliedToYourComment => 'replied to your comment';

  @override
  String get notificationsLikedYourComment => 'liked your comment';

  @override
  String get notificationsToday => 'Today';

  @override
  String get notificationsYesterday => 'Yesterday';

  @override
  String get notificationsUnknownUser => 'Someone';

  @override
  String get notificationsNewMovieTitle => 'New movie';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count new movies';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName was just added to Liquid Phim.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Notifications when Liquid Phim discovers new movies';

  @override
  String get castChooseDevice => 'Choose a device';

  @override
  String get castAirPlayUnavailableTitle => 'Could not open AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      'Make sure your iPhone and TV or Mac are on the same Wi-Fi network, then try again.';

  @override
  String get castVideoUnavailableTitle => 'No video available';

  @override
  String get castVideoUnavailableBody =>
      'Wait for the video to load, then choose a Google Cast device.';

  @override
  String get castConnectionFailedTitle => 'Could not connect to Google Cast';

  @override
  String get castConnectionFailedBody =>
      'Check Google Play services and make sure your phone and Chromecast or Google TV are on the same Wi-Fi network.';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay and Bluetooth devices';

  @override
  String get castConnecting => 'Connecting...';

  @override
  String get castSearching => 'Searching for Google Cast devices...';

  @override
  String get castNoDevices => 'No devices found';

  @override
  String get castSameWifiGuidance =>
      'Make sure your phone and Chromecast or Google TV are on the same Wi-Fi network.';

  @override
  String get castSearchAgain => 'Search again';

  @override
  String get castDefaultDeviceName => 'Google Cast device';

  @override
  String shareMovieSubject(String movieName) {
    return 'Watch $movieName on Liquid Phim';
  }

  @override
  String get shareOpenFailed => 'Could not open the share sheet.';

  @override
  String get rankingTopFavorites => 'TOP favorite movies';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => 'TOP 30 hot movies';

  @override
  String get rankingMostViewed => 'MOST VIEWED';

  @override
  String get rankingMostLiked => 'MOST LIKED';

  @override
  String get rankingEmptyLikes =>
      'The ranking will appear after movies receive likes.';

  @override
  String get rankingEmptyViews =>
      'The ranking will appear after movies receive views.';

  @override
  String get rankingLoadFailed => 'Could not load the ranking.';

  @override
  String playerEpisodeNumber(int number) {
    return 'Episode $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'Month $month';
  }
}
