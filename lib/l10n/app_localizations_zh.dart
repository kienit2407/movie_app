// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => '随时随地，畅享电影';

  @override
  String get commonAgree => '确定';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonDone => '完成';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonReport => '举报';

  @override
  String get commonRetry => '重试';

  @override
  String get commonReset => '重置';

  @override
  String get commonAll => '全部';

  @override
  String get commonSeeMore => '查看更多';

  @override
  String get commonCollapse => '收起';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonUpdating => '更新中';

  @override
  String get commonUnderstood => '知道了';

  @override
  String get commonNoData => '暂无数据';

  @override
  String get commonNotAvailable => '暂无';

  @override
  String get commonWarningTitle => '警告';

  @override
  String get commonNoticeTitle => '提示';

  @override
  String get commonCongratulationsTitle => '恭喜！';

  @override
  String get commonBack => '返回';

  @override
  String get commonGoHome => '返回首页';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选择 $count 项',
      zero: '未选择',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return '错误：$error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '使用设备语言';

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
  String get settingsTitle => '设置';

  @override
  String get settingsGeneralSection => '通用';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsSwitchAccount => '切换账户';

  @override
  String get settingsAddAccount => '添加账户';

  @override
  String get settingsAccountSwitchFailed => '无法切换账户。请重新登录该账户。';

  @override
  String get settingsSignOutFailed => '无法退出登录，请重试。';

  @override
  String get navHome => '首页';

  @override
  String get navSearch => '搜索';

  @override
  String get navFavorites => '收藏';

  @override
  String get navProfile => '个人资料';

  @override
  String get navNotifications => '通知';

  @override
  String get internetOffline => '无互联网连接';

  @override
  String get internetBackOnline => '已恢复网络连接';

  @override
  String get authJoinMember => '加入会员';

  @override
  String get authSignInTitle => '登录 Liquid Phim';

  @override
  String get authSignIn => '登录';

  @override
  String get authSignInFailed => '登录失败，请重试。';

  @override
  String get authSignInToComment => '登录后即可发表评论并与社区互动。';

  @override
  String get authGoogleSyncDescription => '使用 Google 继续以同步账户并加入社区。';

  @override
  String get authGoogleConsent => '继续即表示你同意在 Liquid Phim 中使用你的 Google 账户。';

  @override
  String get authContinueWithGoogle => '使用 Google 继续';

  @override
  String get authGoogleSignInFailed => '无法使用 Google 登录，请重试。';

  @override
  String get authGoogleSignInCheckFailed => '无法使用 Google 登录。请检查网络连接后重试。';

  @override
  String get authSessionUpdateFailed => '无法更新登录会话。';

  @override
  String get authLoginRequired => '你需要先登录。';

  @override
  String get authLoginRequiredForAction => '执行此操作需要先登录。';

  @override
  String get authEmail => '电子邮箱';

  @override
  String get authPassword => '密码';

  @override
  String get authFullName => '姓名';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authOrContinueWith => '或使用以下方式继续';

  @override
  String get authAlreadyHaveAccount => '已有账户？';

  @override
  String get authFullNameRequired => '姓名不能为空。';

  @override
  String get authFullNameLength => '姓名长度必须为 3 到 15 个字符。';

  @override
  String get authEmailRequired => '电子邮箱不能为空。';

  @override
  String get authEmailInvalid => '请输入有效的电子邮箱地址。';

  @override
  String get authPasswordRequired => '密码不能为空。';

  @override
  String get authPasswordLength => '密码长度必须为 6 到 15 个字符。';

  @override
  String get authAccountAlreadyExists => '该账户已存在，请使用其他电子邮箱。';

  @override
  String get authWeakPassword => '该密码过于简单，请使用更强的密码。';

  @override
  String get authInvalidCredentials => '电子邮箱或密码错误，请重试。';

  @override
  String get authUnexpectedError => '出现问题，请重试。';

  @override
  String get authSignUpFailed => '无法创建账户，请重试。';

  @override
  String get authSignUpSucceeded => '账户已创建。';

  @override
  String get authSignInSucceeded => '登录成功。';

  @override
  String get authSignOutSucceeded => '已退出登录。';

  @override
  String get authTokenConfirmed => '验证码已确认。';

  @override
  String get authTokenInvalid => '验证码不正确。';

  @override
  String get homeEnableNewMovieNotificationsTitle => '接收新电影通知？';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim 可以在后台定期检查，并在发现新电影时通知你。为节省电量，操作系统可能会将检查延迟 20 分钟以上。';

  @override
  String get homeEnableNotifications => '开启通知';

  @override
  String get homeDoNotEnable => '暂不开启';

  @override
  String get homeNotificationPermissionDisabled => '通知权限已关闭。你可以在手机设置中重新开启。';

  @override
  String get homeLoadMoviesFailed => '无法加载电影。\n下拉以重试。';

  @override
  String get homeRecommended => '推荐';

  @override
  String get homeGenres => '类型';

  @override
  String get homeCountries => '国家/地区';

  @override
  String get homeYear => '年份';

  @override
  String get homeFreshMovies => '最新上线！';

  @override
  String get homeKoreanMovies => '韩国电影';

  @override
  String get homeChineseMovies => '中国电影';

  @override
  String get homeUsUkMovies => '欧美电影';

  @override
  String get homeWatchMovie => '观看';

  @override
  String get homeInformation => '信息';

  @override
  String get homeViewAll => '查看全部';

  @override
  String get homeWhatToWatch => '今天想看什么？';

  @override
  String get homeViewMore => '查看更多';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return '版本：$version ($buildNumber)';
  }

  @override
  String get filterMovieType => '影片类型';

  @override
  String get filterSeries => '剧集';

  @override
  String get filterSingleMovies => '电影';

  @override
  String get filterAnimation => '动画';

  @override
  String get filterTvShows => '电视节目';

  @override
  String get filterSubtitled => '字幕';

  @override
  String get filterVoiceOver => '旁白配音';

  @override
  String get filterDubbed => '配音';

  @override
  String get filterChooseMovieType => '请选择影片类型。';

  @override
  String get filterChooseGenre => '请选择类型。';

  @override
  String get filterChooseCountry => '请选择要筛选的国家/地区。';

  @override
  String get filterChooseYear => '请选择要筛选的年份。';

  @override
  String get filterLanguage => '语言';

  @override
  String get filterSortBy => '排序依据';

  @override
  String get filterSortDirection => '排序方向';

  @override
  String get filterDescending => '降序';

  @override
  String get filterAscending => '升序';

  @override
  String get filterMostViewed => '最多观看';

  @override
  String get filterNewest => '最新';

  @override
  String get filterReleaseYear => '上映年份';

  @override
  String get filterApply => '应用筛选';

  @override
  String get filterResults => '筛选结果';

  @override
  String get searchAttentionTitle => '注意';

  @override
  String get searchEnterKeywordBeforeFiltering => '筛选电影前请先输入关键词。';

  @override
  String get searchNoResults => '未找到结果';

  @override
  String get searchMovieActorHint => '搜索电影、演员...';

  @override
  String get searchFilterTooltip => '搜索筛选';

  @override
  String get searchStartPrompt => '输入电影名称开始搜索';

  @override
  String get searchRecent => '最近搜索';

  @override
  String get searchLoadingGenres => '正在加载类型...';

  @override
  String get searchLoadingCountries => '正在加载国家/地区...';

  @override
  String get searchNoMovies => '暂无电影';

  @override
  String get searchTryDifferentFilters => '请尝试其他筛选条件';

  @override
  String get librarySignOutTitle => '退出登录？';

  @override
  String get librarySignOutConfirmation => '确定要退出此账户吗？';

  @override
  String get librarySignOut => '退出登录';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    return '删除已选择的 $count 部电影？';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => '从观看历史中删除这部电影？';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    return '从观看历史中删除 $count 部电影？';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle => '从收藏中移除这部电影？';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    return '从收藏中移除 $count 部电影？';
  }

  @override
  String get libraryCancelSelection => '取消选择';

  @override
  String get libraryDeleteSelectedMovies => '删除已选电影';

  @override
  String get libraryCannotResumeMovie => '目前无法继续播放这部电影。';

  @override
  String get libraryYourProfile => '你的个人资料';

  @override
  String get librarySignInProfileDescription => '登录后可编辑个人资料并同步观看历史。';

  @override
  String get libraryWatchHistory => '观看历史';

  @override
  String get libraryNoWatchHistory => '暂无观看历史';

  @override
  String get libraryFavorites => '收藏';

  @override
  String get librarySignInToSaveFavorites => '登录以保存收藏的电影';

  @override
  String get libraryFavoritesSyncDescription => '你的列表将在各设备间同步。';

  @override
  String get libraryNoFavorites => '暂无收藏电影';

  @override
  String get libraryRemoveFromList => '从列表中移除';

  @override
  String libraryContinueProgress(int progress) {
    return '从 $progress% 继续';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed => '无法加载你的媒体库，请重试。';

  @override
  String get libraryFavoriteUpdateFailed => '无法更新收藏，请重试。';

  @override
  String get libraryFavoriteRemoveFailed => '无法移除收藏，请重试。';

  @override
  String get libraryHistorySyncLater => '你的观看历史稍后会再次同步。';

  @override
  String get libraryHistoryDeleteFailed => '无法删除观看历史，请重试。';

  @override
  String get profileEdit => '编辑个人资料';

  @override
  String get profileChangePhoto => '更换照片';

  @override
  String get profileName => '姓名';

  @override
  String get profileNameDescription => '此名称将显示在你的 Liquid Phim 个人资料中。';

  @override
  String get profileNameHint => '输入显示名称';

  @override
  String get profileClearName => '清除名称';

  @override
  String get profileEmailDescription => '此电子邮箱已关联到你的账户，仅在此处显示。';

  @override
  String get profileChangeAvatar => '更换头像';

  @override
  String get profileTakePhoto => '拍照';

  @override
  String get profileUploadPhoto => '上传照片';

  @override
  String get profileViewPhoto => '查看照片';

  @override
  String get profileAvatar => '头像';

  @override
  String get profileCropAvatar => '裁剪头像';

  @override
  String get profileAvatarUpdated => '头像已更新。';

  @override
  String get profileAvatarUpdateFailed => '无法更新头像，请重试。';

  @override
  String get profilePhotoOpenFailed => '无法打开照片，请检查照片访问权限。';

  @override
  String get profileNameUpdated => '显示名称已更新。';

  @override
  String get profileNameUpdateFailed => '无法更新名称，请重试。';

  @override
  String get profileNameRequired => '名称不能为空。';

  @override
  String get profileUpdatedProfileReadFailed => '无法读取更新后的个人资料。';

  @override
  String get detailCastUnavailable => '暂无演员信息';

  @override
  String get detailCast => '演员';

  @override
  String get detailRecommendationsLoadFailed => '无法加载推荐内容';

  @override
  String get detailNoRecommendations => '暂无推荐';

  @override
  String detailEpisodeNotFound(int episode) {
    return '当前服务器无法提供第 $episode 集。';
  }

  @override
  String get detailNoEpisodes => '暂无可用剧集';

  @override
  String get detailWatchThisVersion => '观看此版本';

  @override
  String get detailServer => '服务器';

  @override
  String detailServerNumber(int number) {
    return '服务器 $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return '第 1–$count 集';
  }

  @override
  String get detailEnterEpisode => '输入集数';

  @override
  String get detailLoadMovieError => '无法加载电影';

  @override
  String get detailEpisodesTab => '剧集';

  @override
  String get detailRecommendationsTab => '推荐';

  @override
  String get detailCommentsTab => '评论';

  @override
  String get detailInTheaters => '院线上映';

  @override
  String get detailExclusiveSubtitles => '独家字幕';

  @override
  String get detailDirectorLabel => '导演：';

  @override
  String get detailCreatedDateLabel => '添加日期：';

  @override
  String get detailProductionYearLabel => '制作年份：';

  @override
  String get detailCountryLabel => '国家/地区：';

  @override
  String get detailWatchLatestEpisode => '观看最新一集';

  @override
  String get detailWatchMovie => '观看电影';

  @override
  String get detailIntroduction => '简介';

  @override
  String get detailFavorite => '收藏';

  @override
  String get detailContent => '剧情简介';

  @override
  String get detailNoPlayableEpisodes => '这部影片暂时没有可播放的剧集，请稍后重试。';

  @override
  String get detailDetails => '详情';

  @override
  String get detailVideoQuality => '视频质量';

  @override
  String detailViews(String count) {
    return '$count 次观看';
  }

  @override
  String detailLikes(String count) {
    return '$count 个赞';
  }

  @override
  String get detailUpdatedJustNow => '刚刚更新';

  @override
  String get playerSubtitleServer => '字幕';

  @override
  String get playerNowPlaying => '正在播放';

  @override
  String playerNowPlayingEpisode(String episode) {
    return '正在播放：$episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable => '此服务器没有可播放的视频源。';

  @override
  String get playerSourceLoadFailed => '无法加载此视频源。';

  @override
  String get playerAutoplayEnabled => '已开启自动播放';

  @override
  String get playerAutoplayDisabled => '已关闭自动播放';

  @override
  String get playerNoMoreEpisodes => '已经是最后一集';

  @override
  String get playerFirstEpisode => '这是第一集';

  @override
  String get playerPlaybackFailed => '无法播放视频，请重试。';

  @override
  String get playerPlay => '播放';

  @override
  String get playerPause => '暂停';

  @override
  String get playerPullDownToCloseComments => '下拉关闭评论';

  @override
  String get playerPlayOnTv => '在电视上播放';

  @override
  String get playerEpisodeList => '剧集列表';

  @override
  String get playerVideoProgress => '视频进度';

  @override
  String get playerClose => '关闭播放器';

  @override
  String get playerContinueWatchingTitle => '继续观看？';

  @override
  String playerContinueWatchingBody(String episode) {
    return '你上次看到 $episode。要继续观看，还是从第 1 集重新开始？';
  }

  @override
  String get playerRestartFromBeginning => '从头开始';

  @override
  String get playerContinue => '继续';

  @override
  String get commentsReply => '回复';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条回复',
      zero: '暂无回复',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => '无法加载评论';

  @override
  String get commentsEmptyTitle => '暂无评论';

  @override
  String get commentsEmptySubtitle => '来发表第一条评论吧。';

  @override
  String get commentsEditHint => '编辑评论...';

  @override
  String commentsReplyToHint(String name) {
    return '回复 $name...';
  }

  @override
  String get commentsAddReplyHint => '添加回复...';

  @override
  String get commentsComposerHint => '写评论...';

  @override
  String get commentsEditingStatus => '正在编辑评论';

  @override
  String commentsReplyingStatus(String name) {
    return '正在回复 $name';
  }

  @override
  String get commentsWrite => '写评论';

  @override
  String get commentsSend => '发送';

  @override
  String get commentsCloseMenu => '关闭评论菜单';

  @override
  String get commentsCopied => '评论已复制';

  @override
  String get commentsYourComment => '你的评论';

  @override
  String get commentsReportReasonTitle => '为什么要举报这条评论？';

  @override
  String get commentsReportSent => '举报已提交，谢谢。';

  @override
  String get commentsDeleteTitle => '删除评论？';

  @override
  String get commentsRepliesPreserved => '回复将会保留。';

  @override
  String get commentsDeleteAction => '删除评论';

  @override
  String get commentsSortTitle => '评论排序';

  @override
  String get commentsPopular => '热门';

  @override
  String get commentsNewest => '最新';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条评论',
      zero: '评论',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => '复制评论';

  @override
  String get commentsEdited => '已编辑';

  @override
  String get commentsDeleted => '评论已删除';

  @override
  String get commentsJustNow => '刚刚';

  @override
  String commentsMinutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String commentsHoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String commentsDaysAgo(int count) {
    return '$count 天前';
  }

  @override
  String commentsWeeksAgo(int count) {
    return '$count 周前';
  }

  @override
  String commentsMonthsAgo(int count) {
    return '$count 个月前';
  }

  @override
  String commentsYearsAgo(int count) {
    return '$count 年前';
  }

  @override
  String get commentsSpamReason => '垃圾信息';

  @override
  String get commentsHarassmentReason => '骚扰或辱骂';

  @override
  String get commentsSpoilerReason => '电影剧透';

  @override
  String get commentsInappropriateReason => '不当内容';

  @override
  String get commentsOtherReason => '其他原因';

  @override
  String get commentsLoadFailed => '无法加载评论，请重试。';

  @override
  String get commentsLoadMoreFailed => '无法加载更多评论。';

  @override
  String get commentsRepliesLoadFailed => '无法加载回复。';

  @override
  String get commentsRepliesLoadMoreFailed => '无法加载更多回复。';

  @override
  String get commentsSendFailed => '无法发送评论，你输入的内容已保留。';

  @override
  String get commentsEditFailed => '无法编辑评论。';

  @override
  String get commentsDeleteFailed => '无法删除评论。';

  @override
  String get commentsReactionFailed => '无法更新互动。';

  @override
  String get commentsReportFailed => '这条评论可能已被举报，或举报发送失败。';

  @override
  String get commentsOperationInProgress => '此操作正在进行中。';

  @override
  String get notificationsEmpty => '暂无新通知';

  @override
  String get notificationsRepliedToYourComment => '回复了你的评论';

  @override
  String get notificationsLikedYourComment => '赞了你的评论';

  @override
  String get notificationsToday => '今天';

  @override
  String get notificationsYesterday => '昨天';

  @override
  String get notificationsUnknownUser => '某位用户';

  @override
  String get notificationsNewMovieTitle => '新电影';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count 部新电影';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName 刚刚加入 Liquid Phim。';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Liquid Phim 发现新电影时发送通知';

  @override
  String get castChooseDevice => '选择设备';

  @override
  String get castAirPlayUnavailableTitle => '无法打开 AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      '请确保你的 iPhone 与电视或 Mac 连接到同一个 Wi-Fi 网络，然后重试。';

  @override
  String get castVideoUnavailableTitle => '暂无可用视频';

  @override
  String get castVideoUnavailableBody => '请等待视频加载完成，然后选择 Google Cast 设备。';

  @override
  String get castConnectionFailedTitle => '无法连接到 Google Cast';

  @override
  String get castConnectionFailedBody =>
      '请检查 Google Play 服务，并确保手机与 Chromecast 或 Google TV 连接到同一个 Wi-Fi 网络。';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay 和蓝牙设备';

  @override
  String get castConnecting => '连接中...';

  @override
  String get castSearching => '正在搜索 Google Cast 设备...';

  @override
  String get castNoDevices => '未找到设备';

  @override
  String get castSameWifiGuidance =>
      '请确保手机与 Chromecast 或 Google TV 连接到同一个 Wi-Fi 网络。';

  @override
  String get castSearchAgain => '重新搜索';

  @override
  String get castDefaultDeviceName => 'Google Cast 设备';

  @override
  String shareMovieSubject(String movieName) {
    return '在 Liquid Phim 上观看 $movieName';
  }

  @override
  String get shareOpenFailed => '无法打开分享面板。';

  @override
  String get rankingTopFavorites => '收藏电影 TOP';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => '热门电影 TOP 30';

  @override
  String get rankingMostViewed => '观看最多';

  @override
  String get rankingMostLiked => '点赞最多';

  @override
  String get rankingEmptyLikes => '电影获得点赞后会显示排行榜。';

  @override
  String get rankingEmptyViews => '电影获得观看次数后会显示排行榜。';

  @override
  String get rankingLoadFailed => '无法加载排行榜。';

  @override
  String playerEpisodeNumber(int number) {
    return '第 $number 集';
  }

  @override
  String libraryMonthLabel(int month) {
    return '$month 月';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => '随时随地，畅享电影';

  @override
  String get commonAgree => '确定';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '关闭';

  @override
  String get commonDone => '完成';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '删除';

  @override
  String get commonEdit => '编辑';

  @override
  String get commonReport => '举报';

  @override
  String get commonRetry => '重试';

  @override
  String get commonReset => '重置';

  @override
  String get commonAll => '全部';

  @override
  String get commonSeeMore => '查看更多';

  @override
  String get commonCollapse => '收起';

  @override
  String get commonLoading => '加载中...';

  @override
  String get commonUpdating => '更新中';

  @override
  String get commonUnderstood => '知道了';

  @override
  String get commonNoData => '暂无数据';

  @override
  String get commonNotAvailable => '暂无';

  @override
  String get commonWarningTitle => '警告';

  @override
  String get commonNoticeTitle => '提示';

  @override
  String get commonCongratulationsTitle => '恭喜！';

  @override
  String get commonBack => '返回';

  @override
  String get commonGoHome => '返回首页';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已选择 $count 项',
      zero: '未选择',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return '错误：$error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    return '$hours 小时 $minutes 分钟';
  }

  @override
  String get settingsLanguage => '语言';

  @override
  String get settingsLanguageSystem => '使用设备语言';

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
  String get settingsTitle => '设置';

  @override
  String get settingsGeneralSection => '通用';

  @override
  String get settingsAppLanguage => '应用语言';

  @override
  String get settingsAccountSection => '账户';

  @override
  String get settingsSwitchAccount => '切换账户';

  @override
  String get settingsAddAccount => '添加账户';

  @override
  String get settingsAccountSwitchFailed => '无法切换账户。请重新登录该账户。';

  @override
  String get settingsSignOutFailed => '无法退出登录，请重试。';

  @override
  String get navHome => '首页';

  @override
  String get navSearch => '搜索';

  @override
  String get navFavorites => '收藏';

  @override
  String get navProfile => '个人资料';

  @override
  String get navNotifications => '通知';

  @override
  String get internetOffline => '无互联网连接';

  @override
  String get internetBackOnline => '已恢复网络连接';

  @override
  String get authJoinMember => '加入会员';

  @override
  String get authSignInTitle => '登录 Liquid Phim';

  @override
  String get authSignIn => '登录';

  @override
  String get authSignInFailed => '登录失败，请重试。';

  @override
  String get authSignInToComment => '登录后即可发表评论并与社区互动。';

  @override
  String get authGoogleSyncDescription => '使用 Google 继续以同步账户并加入社区。';

  @override
  String get authGoogleConsent => '继续即表示你同意在 Liquid Phim 中使用你的 Google 账户。';

  @override
  String get authContinueWithGoogle => '使用 Google 继续';

  @override
  String get authGoogleSignInFailed => '无法使用 Google 登录，请重试。';

  @override
  String get authGoogleSignInCheckFailed => '无法使用 Google 登录。请检查网络连接后重试。';

  @override
  String get authSessionUpdateFailed => '无法更新登录会话。';

  @override
  String get authLoginRequired => '你需要先登录。';

  @override
  String get authLoginRequiredForAction => '执行此操作需要先登录。';

  @override
  String get authEmail => '电子邮箱';

  @override
  String get authPassword => '密码';

  @override
  String get authFullName => '姓名';

  @override
  String get authForgotPassword => '忘记密码？';

  @override
  String get authOrContinueWith => '或使用以下方式继续';

  @override
  String get authAlreadyHaveAccount => '已有账户？';

  @override
  String get authFullNameRequired => '姓名不能为空。';

  @override
  String get authFullNameLength => '姓名长度必须为 3 到 15 个字符。';

  @override
  String get authEmailRequired => '电子邮箱不能为空。';

  @override
  String get authEmailInvalid => '请输入有效的电子邮箱地址。';

  @override
  String get authPasswordRequired => '密码不能为空。';

  @override
  String get authPasswordLength => '密码长度必须为 6 到 15 个字符。';

  @override
  String get authAccountAlreadyExists => '该账户已存在，请使用其他电子邮箱。';

  @override
  String get authWeakPassword => '该密码过于简单，请使用更强的密码。';

  @override
  String get authInvalidCredentials => '电子邮箱或密码错误，请重试。';

  @override
  String get authUnexpectedError => '出现问题，请重试。';

  @override
  String get authSignUpFailed => '无法创建账户，请重试。';

  @override
  String get authSignUpSucceeded => '账户已创建。';

  @override
  String get authSignInSucceeded => '登录成功。';

  @override
  String get authSignOutSucceeded => '已退出登录。';

  @override
  String get authTokenConfirmed => '验证码已确认。';

  @override
  String get authTokenInvalid => '验证码不正确。';

  @override
  String get homeEnableNewMovieNotificationsTitle => '接收新电影通知？';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim 可以在后台定期检查，并在发现新电影时通知你。为节省电量，操作系统可能会将检查延迟 20 分钟以上。';

  @override
  String get homeEnableNotifications => '开启通知';

  @override
  String get homeDoNotEnable => '暂不开启';

  @override
  String get homeNotificationPermissionDisabled => '通知权限已关闭。你可以在手机设置中重新开启。';

  @override
  String get homeLoadMoviesFailed => '无法加载电影。\n下拉以重试。';

  @override
  String get homeRecommended => '推荐';

  @override
  String get homeGenres => '类型';

  @override
  String get homeCountries => '国家/地区';

  @override
  String get homeYear => '年份';

  @override
  String get homeFreshMovies => '最新上线！';

  @override
  String get homeKoreanMovies => '韩国电影';

  @override
  String get homeChineseMovies => '中国电影';

  @override
  String get homeUsUkMovies => '欧美电影';

  @override
  String get homeWatchMovie => '观看';

  @override
  String get homeInformation => '信息';

  @override
  String get homeViewAll => '查看全部';

  @override
  String get homeWhatToWatch => '今天想看什么？';

  @override
  String get homeViewMore => '查看更多';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return '版本：$version ($buildNumber)';
  }

  @override
  String get filterMovieType => '影片类型';

  @override
  String get filterSeries => '剧集';

  @override
  String get filterSingleMovies => '电影';

  @override
  String get filterAnimation => '动画';

  @override
  String get filterTvShows => '电视节目';

  @override
  String get filterSubtitled => '字幕';

  @override
  String get filterVoiceOver => '旁白配音';

  @override
  String get filterDubbed => '配音';

  @override
  String get filterChooseMovieType => '请选择影片类型。';

  @override
  String get filterChooseGenre => '请选择类型。';

  @override
  String get filterChooseCountry => '请选择要筛选的国家/地区。';

  @override
  String get filterChooseYear => '请选择要筛选的年份。';

  @override
  String get filterLanguage => '语言';

  @override
  String get filterSortBy => '排序依据';

  @override
  String get filterSortDirection => '排序方向';

  @override
  String get filterDescending => '降序';

  @override
  String get filterAscending => '升序';

  @override
  String get filterMostViewed => '最多观看';

  @override
  String get filterNewest => '最新';

  @override
  String get filterReleaseYear => '上映年份';

  @override
  String get filterApply => '应用筛选';

  @override
  String get filterResults => '筛选结果';

  @override
  String get searchAttentionTitle => '注意';

  @override
  String get searchEnterKeywordBeforeFiltering => '筛选电影前请先输入关键词。';

  @override
  String get searchNoResults => '未找到结果';

  @override
  String get searchMovieActorHint => '搜索电影、演员...';

  @override
  String get searchFilterTooltip => '搜索筛选';

  @override
  String get searchStartPrompt => '输入电影名称开始搜索';

  @override
  String get searchRecent => '最近搜索';

  @override
  String get searchLoadingGenres => '正在加载类型...';

  @override
  String get searchLoadingCountries => '正在加载国家/地区...';

  @override
  String get searchNoMovies => '暂无电影';

  @override
  String get searchTryDifferentFilters => '请尝试其他筛选条件';

  @override
  String get librarySignOutTitle => '退出登录？';

  @override
  String get librarySignOutConfirmation => '确定要退出此账户吗？';

  @override
  String get librarySignOut => '退出登录';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    return '删除已选择的 $count 部电影？';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => '从观看历史中删除这部电影？';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    return '从观看历史中删除 $count 部电影？';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle => '从收藏中移除这部电影？';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    return '从收藏中移除 $count 部电影？';
  }

  @override
  String get libraryCancelSelection => '取消选择';

  @override
  String get libraryDeleteSelectedMovies => '删除已选电影';

  @override
  String get libraryCannotResumeMovie => '目前无法继续播放这部电影。';

  @override
  String get libraryYourProfile => '你的个人资料';

  @override
  String get librarySignInProfileDescription => '登录后可编辑个人资料并同步观看历史。';

  @override
  String get libraryWatchHistory => '观看历史';

  @override
  String get libraryNoWatchHistory => '暂无观看历史';

  @override
  String get libraryFavorites => '收藏';

  @override
  String get librarySignInToSaveFavorites => '登录以保存收藏的电影';

  @override
  String get libraryFavoritesSyncDescription => '你的列表将在各设备间同步。';

  @override
  String get libraryNoFavorites => '暂无收藏电影';

  @override
  String get libraryRemoveFromList => '从列表中移除';

  @override
  String libraryContinueProgress(int progress) {
    return '从 $progress% 继续';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed => '无法加载你的媒体库，请重试。';

  @override
  String get libraryFavoriteUpdateFailed => '无法更新收藏，请重试。';

  @override
  String get libraryFavoriteRemoveFailed => '无法移除收藏，请重试。';

  @override
  String get libraryHistorySyncLater => '你的观看历史稍后会再次同步。';

  @override
  String get libraryHistoryDeleteFailed => '无法删除观看历史，请重试。';

  @override
  String get profileEdit => '编辑个人资料';

  @override
  String get profileChangePhoto => '更换照片';

  @override
  String get profileName => '姓名';

  @override
  String get profileNameDescription => '此名称将显示在你的 Liquid Phim 个人资料中。';

  @override
  String get profileNameHint => '输入显示名称';

  @override
  String get profileClearName => '清除名称';

  @override
  String get profileEmailDescription => '此电子邮箱已关联到你的账户，仅在此处显示。';

  @override
  String get profileChangeAvatar => '更换头像';

  @override
  String get profileTakePhoto => '拍照';

  @override
  String get profileUploadPhoto => '上传照片';

  @override
  String get profileViewPhoto => '查看照片';

  @override
  String get profileAvatar => '头像';

  @override
  String get profileCropAvatar => '裁剪头像';

  @override
  String get profileAvatarUpdated => '头像已更新。';

  @override
  String get profileAvatarUpdateFailed => '无法更新头像，请重试。';

  @override
  String get profilePhotoOpenFailed => '无法打开照片，请检查照片访问权限。';

  @override
  String get profileNameUpdated => '显示名称已更新。';

  @override
  String get profileNameUpdateFailed => '无法更新名称，请重试。';

  @override
  String get profileNameRequired => '名称不能为空。';

  @override
  String get profileUpdatedProfileReadFailed => '无法读取更新后的个人资料。';

  @override
  String get detailCastUnavailable => '暂无演员信息';

  @override
  String get detailCast => '演员';

  @override
  String get detailRecommendationsLoadFailed => '无法加载推荐内容';

  @override
  String get detailNoRecommendations => '暂无推荐';

  @override
  String detailEpisodeNotFound(int episode) {
    return '当前服务器无法提供第 $episode 集。';
  }

  @override
  String get detailNoEpisodes => '暂无可用剧集';

  @override
  String get detailWatchThisVersion => '观看此版本';

  @override
  String get detailServer => '服务器';

  @override
  String detailServerNumber(int number) {
    return '服务器 $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return '第 1–$count 集';
  }

  @override
  String get detailEnterEpisode => '输入集数';

  @override
  String get detailLoadMovieError => '无法加载电影';

  @override
  String get detailEpisodesTab => '剧集';

  @override
  String get detailRecommendationsTab => '推荐';

  @override
  String get detailCommentsTab => '评论';

  @override
  String get detailInTheaters => '院线上映';

  @override
  String get detailExclusiveSubtitles => '独家字幕';

  @override
  String get detailDirectorLabel => '导演：';

  @override
  String get detailCreatedDateLabel => '添加日期：';

  @override
  String get detailProductionYearLabel => '制作年份：';

  @override
  String get detailCountryLabel => '国家/地区：';

  @override
  String get detailWatchLatestEpisode => '观看最新一集';

  @override
  String get detailWatchMovie => '观看电影';

  @override
  String get detailIntroduction => '简介';

  @override
  String get detailFavorite => '收藏';

  @override
  String get detailContent => '剧情简介';

  @override
  String get detailNoPlayableEpisodes => '这部影片暂时没有可播放的剧集，请稍后重试。';

  @override
  String get detailDetails => '详情';

  @override
  String get detailVideoQuality => '视频质量';

  @override
  String detailViews(String count) {
    return '$count 次观看';
  }

  @override
  String detailLikes(String count) {
    return '$count 个赞';
  }

  @override
  String get detailUpdatedJustNow => '刚刚更新';

  @override
  String get playerSubtitleServer => '字幕';

  @override
  String get playerNowPlaying => '正在播放';

  @override
  String playerNowPlayingEpisode(String episode) {
    return '正在播放：$episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable => '此服务器没有可播放的视频源。';

  @override
  String get playerSourceLoadFailed => '无法加载此视频源。';

  @override
  String get playerAutoplayEnabled => '已开启自动播放';

  @override
  String get playerAutoplayDisabled => '已关闭自动播放';

  @override
  String get playerNoMoreEpisodes => '已经是最后一集';

  @override
  String get playerFirstEpisode => '这是第一集';

  @override
  String get playerPlaybackFailed => '无法播放视频，请重试。';

  @override
  String get playerPlay => '播放';

  @override
  String get playerPause => '暂停';

  @override
  String get playerPullDownToCloseComments => '下拉关闭评论';

  @override
  String get playerPlayOnTv => '在电视上播放';

  @override
  String get playerEpisodeList => '剧集列表';

  @override
  String get playerVideoProgress => '视频进度';

  @override
  String get playerClose => '关闭播放器';

  @override
  String get playerContinueWatchingTitle => '继续观看？';

  @override
  String playerContinueWatchingBody(String episode) {
    return '你上次看到 $episode。要继续观看，还是从第 1 集重新开始？';
  }

  @override
  String get playerRestartFromBeginning => '从头开始';

  @override
  String get playerContinue => '继续';

  @override
  String get commentsReply => '回复';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条回复',
      zero: '暂无回复',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => '无法加载评论';

  @override
  String get commentsEmptyTitle => '暂无评论';

  @override
  String get commentsEmptySubtitle => '来发表第一条评论吧。';

  @override
  String get commentsEditHint => '编辑评论...';

  @override
  String commentsReplyToHint(String name) {
    return '回复 $name...';
  }

  @override
  String get commentsAddReplyHint => '添加回复...';

  @override
  String get commentsComposerHint => '写评论...';

  @override
  String get commentsEditingStatus => '正在编辑评论';

  @override
  String commentsReplyingStatus(String name) {
    return '正在回复 $name';
  }

  @override
  String get commentsWrite => '写评论';

  @override
  String get commentsSend => '发送';

  @override
  String get commentsCloseMenu => '关闭评论菜单';

  @override
  String get commentsCopied => '评论已复制';

  @override
  String get commentsYourComment => '你的评论';

  @override
  String get commentsReportReasonTitle => '为什么要举报这条评论？';

  @override
  String get commentsReportSent => '举报已提交，谢谢。';

  @override
  String get commentsDeleteTitle => '删除评论？';

  @override
  String get commentsRepliesPreserved => '回复将会保留。';

  @override
  String get commentsDeleteAction => '删除评论';

  @override
  String get commentsSortTitle => '评论排序';

  @override
  String get commentsPopular => '热门';

  @override
  String get commentsNewest => '最新';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条评论',
      zero: '评论',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => '复制评论';

  @override
  String get commentsEdited => '已编辑';

  @override
  String get commentsDeleted => '评论已删除';

  @override
  String get commentsJustNow => '刚刚';

  @override
  String commentsMinutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String commentsHoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String commentsDaysAgo(int count) {
    return '$count 天前';
  }

  @override
  String commentsWeeksAgo(int count) {
    return '$count 周前';
  }

  @override
  String commentsMonthsAgo(int count) {
    return '$count 个月前';
  }

  @override
  String commentsYearsAgo(int count) {
    return '$count 年前';
  }

  @override
  String get commentsSpamReason => '垃圾信息';

  @override
  String get commentsHarassmentReason => '骚扰或辱骂';

  @override
  String get commentsSpoilerReason => '电影剧透';

  @override
  String get commentsInappropriateReason => '不当内容';

  @override
  String get commentsOtherReason => '其他原因';

  @override
  String get commentsLoadFailed => '无法加载评论，请重试。';

  @override
  String get commentsLoadMoreFailed => '无法加载更多评论。';

  @override
  String get commentsRepliesLoadFailed => '无法加载回复。';

  @override
  String get commentsRepliesLoadMoreFailed => '无法加载更多回复。';

  @override
  String get commentsSendFailed => '无法发送评论，你输入的内容已保留。';

  @override
  String get commentsEditFailed => '无法编辑评论。';

  @override
  String get commentsDeleteFailed => '无法删除评论。';

  @override
  String get commentsReactionFailed => '无法更新互动。';

  @override
  String get commentsReportFailed => '这条评论可能已被举报，或举报发送失败。';

  @override
  String get commentsOperationInProgress => '此操作正在进行中。';

  @override
  String get notificationsEmpty => '暂无新通知';

  @override
  String get notificationsRepliedToYourComment => '回复了你的评论';

  @override
  String get notificationsLikedYourComment => '赞了你的评论';

  @override
  String get notificationsToday => '今天';

  @override
  String get notificationsYesterday => '昨天';

  @override
  String get notificationsUnknownUser => '某位用户';

  @override
  String get notificationsNewMovieTitle => '新电影';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count 部新电影';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName 刚刚加入 Liquid Phim。';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Liquid Phim 发现新电影时发送通知';

  @override
  String get castChooseDevice => '选择设备';

  @override
  String get castAirPlayUnavailableTitle => '无法打开 AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      '请确保你的 iPhone 与电视或 Mac 连接到同一个 Wi-Fi 网络，然后重试。';

  @override
  String get castVideoUnavailableTitle => '暂无可用视频';

  @override
  String get castVideoUnavailableBody => '请等待视频加载完成，然后选择 Google Cast 设备。';

  @override
  String get castConnectionFailedTitle => '无法连接到 Google Cast';

  @override
  String get castConnectionFailedBody =>
      '请检查 Google Play 服务，并确保手机与 Chromecast 或 Google TV 连接到同一个 Wi-Fi 网络。';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay 和蓝牙设备';

  @override
  String get castConnecting => '连接中...';

  @override
  String get castSearching => '正在搜索 Google Cast 设备...';

  @override
  String get castNoDevices => '未找到设备';

  @override
  String get castSameWifiGuidance =>
      '请确保手机与 Chromecast 或 Google TV 连接到同一个 Wi-Fi 网络。';

  @override
  String get castSearchAgain => '重新搜索';

  @override
  String get castDefaultDeviceName => 'Google Cast 设备';

  @override
  String shareMovieSubject(String movieName) {
    return '在 Liquid Phim 上观看 $movieName';
  }

  @override
  String get shareOpenFailed => '无法打开分享面板。';

  @override
  String get rankingTopFavorites => '收藏电影 TOP';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => '热门电影 TOP 30';

  @override
  String get rankingMostViewed => '观看最多';

  @override
  String get rankingMostLiked => '点赞最多';

  @override
  String get rankingEmptyLikes => '电影获得点赞后会显示排行榜。';

  @override
  String get rankingEmptyViews => '电影获得观看次数后会显示排行榜。';

  @override
  String get rankingLoadFailed => '无法加载排行榜。';

  @override
  String playerEpisodeNumber(int number) {
    return '第 $number 集';
  }

  @override
  String libraryMonthLabel(int month) {
    return '$month 月';
  }
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => '隨時隨地，暢享電影';

  @override
  String get commonAgree => '確定';

  @override
  String get commonCancel => '取消';

  @override
  String get commonClose => '關閉';

  @override
  String get commonDone => '完成';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '刪除';

  @override
  String get commonEdit => '編輯';

  @override
  String get commonReport => '舉報';

  @override
  String get commonRetry => '重試';

  @override
  String get commonReset => '重置';

  @override
  String get commonAll => '全部';

  @override
  String get commonSeeMore => '查看更多';

  @override
  String get commonCollapse => '收起';

  @override
  String get commonLoading => '加載中...';

  @override
  String get commonUpdating => '更新中';

  @override
  String get commonUnderstood => '知道了';

  @override
  String get commonNoData => '暫無資料';

  @override
  String get commonNotAvailable => '暫無';

  @override
  String get commonWarningTitle => '警告';

  @override
  String get commonNoticeTitle => '提示';

  @override
  String get commonCongratulationsTitle => '恭喜！';

  @override
  String get commonBack => '返回';

  @override
  String get commonGoHome => '返回首頁';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已選擇 $count 項',
      zero: '未選擇',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return '錯誤：$error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    return '$hours 小時 $minutes 分鐘';
  }

  @override
  String get settingsLanguage => '語言';

  @override
  String get settingsLanguageSystem => '使用裝置語言';

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
  String get settingsTitle => '設定';

  @override
  String get settingsGeneralSection => '一般';

  @override
  String get settingsAppLanguage => '應用程式語言';

  @override
  String get settingsAccountSection => '帳號';

  @override
  String get settingsSwitchAccount => '切換帳號';

  @override
  String get settingsAddAccount => '新增帳號';

  @override
  String get settingsAccountSwitchFailed => '無法切換帳號。請重新登入該帳號。';

  @override
  String get settingsSignOutFailed => '無法登出，請再試一次。';

  @override
  String get navHome => '首頁';

  @override
  String get navSearch => '搜尋';

  @override
  String get navFavorites => '收藏';

  @override
  String get navProfile => '個人資料';

  @override
  String get navNotifications => '通知';

  @override
  String get internetOffline => '無網際網路連線';

  @override
  String get internetBackOnline => '已恢復網路連線';

  @override
  String get authJoinMember => '加入會員';

  @override
  String get authSignInTitle => '登入 Liquid Phim';

  @override
  String get authSignIn => '登入';

  @override
  String get authSignInFailed => '登入失敗，請再試一次。';

  @override
  String get authSignInToComment => '登入後即可留言並與社群互動。';

  @override
  String get authGoogleSyncDescription => '使用 Google 繼續，以同步帳號並加入社群。';

  @override
  String get authGoogleConsent => '繼續即表示你同意在 Liquid Phim 中使用你的 Google 帳號。';

  @override
  String get authContinueWithGoogle => '使用 Google 繼續';

  @override
  String get authGoogleSignInFailed => '無法使用 Google 登入，請再試一次。';

  @override
  String get authGoogleSignInCheckFailed => '無法使用 Google 登入。請檢查網路連線後再試一次。';

  @override
  String get authSessionUpdateFailed => '無法更新登入工作階段。';

  @override
  String get authLoginRequired => '你需要先登入。';

  @override
  String get authLoginRequiredForAction => '執行此操作需要先登入。';

  @override
  String get authEmail => '電子郵件';

  @override
  String get authPassword => '密碼';

  @override
  String get authFullName => '姓名';

  @override
  String get authForgotPassword => '忘記密碼？';

  @override
  String get authOrContinueWith => '或使用以下方式繼續';

  @override
  String get authAlreadyHaveAccount => '已有帳號？';

  @override
  String get authFullNameRequired => '姓名不能留空。';

  @override
  String get authFullNameLength => '姓名長度必須為 3 到 15 個字元。';

  @override
  String get authEmailRequired => '電子郵件不能留空。';

  @override
  String get authEmailInvalid => '請輸入有效的電子郵件地址。';

  @override
  String get authPasswordRequired => '密碼不能留空。';

  @override
  String get authPasswordLength => '密碼長度必須為 6 到 15 個字元。';

  @override
  String get authAccountAlreadyExists => '此帳號已存在，請使用其他電子郵件。';

  @override
  String get authWeakPassword => '此密碼過於簡單，請使用更強的密碼。';

  @override
  String get authInvalidCredentials => '電子郵件或密碼不正確，請再試一次。';

  @override
  String get authUnexpectedError => '發生問題，請再試一次。';

  @override
  String get authSignUpFailed => '無法建立帳號，請再試一次。';

  @override
  String get authSignUpSucceeded => '帳號已建立。';

  @override
  String get authSignInSucceeded => '登入成功。';

  @override
  String get authSignOutSucceeded => '已登出。';

  @override
  String get authTokenConfirmed => '驗證碼已確認。';

  @override
  String get authTokenInvalid => '驗證碼不正確。';

  @override
  String get homeEnableNewMovieNotificationsTitle => '接收新電影通知？';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim 可以在背景定期檢查，並在發現新電影時通知你。為了節省電量，作業系統可能會將檢查延遲 20 分鐘以上。';

  @override
  String get homeEnableNotifications => '開啟通知';

  @override
  String get homeDoNotEnable => '暫不開啟';

  @override
  String get homeNotificationPermissionDisabled => '通知權限已關閉。你可以在手機設定中重新開啟。';

  @override
  String get homeLoadMoviesFailed => '無法載入電影。\n下拉以重試。';

  @override
  String get homeRecommended => '推薦';

  @override
  String get homeGenres => '類型';

  @override
  String get homeCountries => '國家/地區';

  @override
  String get homeYear => '年份';

  @override
  String get homeFreshMovies => '最新上線！';

  @override
  String get homeKoreanMovies => '韓國電影';

  @override
  String get homeChineseMovies => '中國電影';

  @override
  String get homeUsUkMovies => '歐美電影';

  @override
  String get homeWatchMovie => '觀看';

  @override
  String get homeInformation => '資訊';

  @override
  String get homeViewAll => '查看全部';

  @override
  String get homeWhatToWatch => '今天想看什麼？';

  @override
  String get homeViewMore => '查看更多';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return '版本：$version ($buildNumber)';
  }

  @override
  String get filterMovieType => '影片類型';

  @override
  String get filterSeries => '影集';

  @override
  String get filterSingleMovies => '電影';

  @override
  String get filterAnimation => '動畫';

  @override
  String get filterTvShows => '電視節目';

  @override
  String get filterSubtitled => '字幕';

  @override
  String get filterVoiceOver => '旁白配音';

  @override
  String get filterDubbed => '配音';

  @override
  String get filterChooseMovieType => '請選擇影片類型。';

  @override
  String get filterChooseGenre => '請選擇類型。';

  @override
  String get filterChooseCountry => '請選擇要篩選的國家/地區。';

  @override
  String get filterChooseYear => '請選擇要篩選的年份。';

  @override
  String get filterLanguage => '語言';

  @override
  String get filterSortBy => '排序依據';

  @override
  String get filterSortDirection => '排序方向';

  @override
  String get filterDescending => '降冪';

  @override
  String get filterAscending => '升冪';

  @override
  String get filterMostViewed => '觀看次數最多';

  @override
  String get filterNewest => '最新';

  @override
  String get filterReleaseYear => '上映年份';

  @override
  String get filterApply => '套用篩選';

  @override
  String get filterResults => '篩選結果';

  @override
  String get searchAttentionTitle => '注意';

  @override
  String get searchEnterKeywordBeforeFiltering => '篩選電影前請先輸入關鍵字。';

  @override
  String get searchNoResults => '找不到結果';

  @override
  String get searchMovieActorHint => '搜尋電影、演員...';

  @override
  String get searchFilterTooltip => '搜尋篩選';

  @override
  String get searchStartPrompt => '輸入電影名稱開始搜尋';

  @override
  String get searchRecent => '最近搜尋';

  @override
  String get searchLoadingGenres => '正在載入類型...';

  @override
  String get searchLoadingCountries => '正在載入國家/地區...';

  @override
  String get searchNoMovies => '暫無電影';

  @override
  String get searchTryDifferentFilters => '請嘗試其他篩選條件';

  @override
  String get librarySignOutTitle => '要登出嗎？';

  @override
  String get librarySignOutConfirmation => '確定要登出此帳號嗎？';

  @override
  String get librarySignOut => '登出';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    return '要刪除已選擇的 $count 部電影嗎？';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => '要從觀看紀錄中刪除這部電影嗎？';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    return '要從觀看紀錄中刪除 $count 部電影嗎？';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle => '要從收藏中移除這部電影嗎？';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    return '要從收藏中移除 $count 部電影嗎？';
  }

  @override
  String get libraryCancelSelection => '取消選取';

  @override
  String get libraryDeleteSelectedMovies => '刪除已選電影';

  @override
  String get libraryCannotResumeMovie => '目前無法繼續播放這部電影。';

  @override
  String get libraryYourProfile => '你的個人資料';

  @override
  String get librarySignInProfileDescription => '登入後可編輯個人資料並同步觀看紀錄。';

  @override
  String get libraryWatchHistory => '觀看紀錄';

  @override
  String get libraryNoWatchHistory => '暫無觀看紀錄';

  @override
  String get libraryFavorites => '收藏';

  @override
  String get librarySignInToSaveFavorites => '登入以儲存收藏的電影';

  @override
  String get libraryFavoritesSyncDescription => '你的清單會在各裝置間同步。';

  @override
  String get libraryNoFavorites => '暫無收藏電影';

  @override
  String get libraryRemoveFromList => '從清單中移除';

  @override
  String libraryContinueProgress(int progress) {
    return '從 $progress% 繼續';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed => '無法載入你的媒體庫，請再試一次。';

  @override
  String get libraryFavoriteUpdateFailed => '無法更新收藏，請再試一次。';

  @override
  String get libraryFavoriteRemoveFailed => '無法移除收藏，請再試一次。';

  @override
  String get libraryHistorySyncLater => '你的觀看紀錄稍後會再次同步。';

  @override
  String get libraryHistoryDeleteFailed => '無法刪除觀看紀錄，請再試一次。';

  @override
  String get profileEdit => '編輯個人資料';

  @override
  String get profileChangePhoto => '更換照片';

  @override
  String get profileName => '姓名';

  @override
  String get profileNameDescription => '此名稱會顯示在你的 Liquid Phim 個人資料中。';

  @override
  String get profileNameHint => '輸入顯示名稱';

  @override
  String get profileClearName => '清除名稱';

  @override
  String get profileEmailDescription => '此電子郵件已連結到你的帳號，且只會顯示在這裡。';

  @override
  String get profileChangeAvatar => '更換大頭照';

  @override
  String get profileTakePhoto => '拍照';

  @override
  String get profileUploadPhoto => '上傳照片';

  @override
  String get profileViewPhoto => '查看照片';

  @override
  String get profileAvatar => '大頭照';

  @override
  String get profileCropAvatar => '裁切大頭照';

  @override
  String get profileAvatarUpdated => '大頭照已更新。';

  @override
  String get profileAvatarUpdateFailed => '無法更新大頭照，請再試一次。';

  @override
  String get profilePhotoOpenFailed => '無法開啟照片，請檢查照片存取權限。';

  @override
  String get profileNameUpdated => '顯示名稱已更新。';

  @override
  String get profileNameUpdateFailed => '無法更新名稱，請再試一次。';

  @override
  String get profileNameRequired => '名稱不能留空。';

  @override
  String get profileUpdatedProfileReadFailed => '無法讀取更新後的個人資料。';

  @override
  String get detailCastUnavailable => '暫無演員資訊';

  @override
  String get detailCast => '演員';

  @override
  String get detailRecommendationsLoadFailed => '無法載入推薦內容';

  @override
  String get detailNoRecommendations => '暫無推薦';

  @override
  String detailEpisodeNotFound(int episode) {
    return '目前伺服器無法提供第 $episode 集。';
  }

  @override
  String get detailNoEpisodes => '暫無可用集數';

  @override
  String get detailWatchThisVersion => '觀看此版本';

  @override
  String get detailServer => '伺服器';

  @override
  String detailServerNumber(int number) {
    return '伺服器 $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return '第 1–$count 集';
  }

  @override
  String get detailEnterEpisode => '輸入集數';

  @override
  String get detailLoadMovieError => '無法載入電影';

  @override
  String get detailEpisodesTab => '集數';

  @override
  String get detailRecommendationsTab => '推薦';

  @override
  String get detailCommentsTab => '留言';

  @override
  String get detailInTheaters => '院線上映';

  @override
  String get detailExclusiveSubtitles => '獨家字幕';

  @override
  String get detailDirectorLabel => '導演：';

  @override
  String get detailCreatedDateLabel => '新增日期：';

  @override
  String get detailProductionYearLabel => '製作年份：';

  @override
  String get detailCountryLabel => '國家/地區：';

  @override
  String get detailWatchLatestEpisode => '觀看最新一集';

  @override
  String get detailWatchMovie => '觀看電影';

  @override
  String get detailIntroduction => '簡介';

  @override
  String get detailFavorite => '收藏';

  @override
  String get detailContent => '劇情簡介';

  @override
  String get detailNoPlayableEpisodes => '這部影片目前沒有可播放的集數，請稍後再試。';

  @override
  String get detailDetails => '詳細資訊';

  @override
  String get detailVideoQuality => '影片畫質';

  @override
  String detailViews(String count) {
    return '$count 次觀看';
  }

  @override
  String detailLikes(String count) {
    return '$count 個讚';
  }

  @override
  String get detailUpdatedJustNow => '剛剛更新';

  @override
  String get playerSubtitleServer => '字幕';

  @override
  String get playerNowPlaying => '正在播放';

  @override
  String playerNowPlayingEpisode(String episode) {
    return '正在播放：$episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable => '此伺服器沒有可播放的影片來源。';

  @override
  String get playerSourceLoadFailed => '無法載入此影片來源。';

  @override
  String get playerAutoplayEnabled => '已開啟自動播放';

  @override
  String get playerAutoplayDisabled => '已關閉自動播放';

  @override
  String get playerNoMoreEpisodes => '已經是最後一集';

  @override
  String get playerFirstEpisode => '這是第一集';

  @override
  String get playerPlaybackFailed => '無法播放影片，請再試一次。';

  @override
  String get playerPlay => '播放';

  @override
  String get playerPause => '暫停';

  @override
  String get playerPullDownToCloseComments => '下拉關閉留言';

  @override
  String get playerPlayOnTv => '在電視上播放';

  @override
  String get playerEpisodeList => '集數清單';

  @override
  String get playerVideoProgress => '影片進度';

  @override
  String get playerClose => '關閉播放器';

  @override
  String get playerContinueWatchingTitle => '繼續觀看？';

  @override
  String playerContinueWatchingBody(String episode) {
    return '你上次看到 $episode。要繼續觀看，還是從第 1 集重新開始？';
  }

  @override
  String get playerRestartFromBeginning => '從頭開始';

  @override
  String get playerContinue => '繼續';

  @override
  String get commentsReply => '回覆';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則回覆',
      zero: '暫無回覆',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => '無法載入留言';

  @override
  String get commentsEmptyTitle => '暫無留言';

  @override
  String get commentsEmptySubtitle => '來留下第一則留言吧。';

  @override
  String get commentsEditHint => '編輯留言...';

  @override
  String commentsReplyToHint(String name) {
    return '回覆 $name...';
  }

  @override
  String get commentsAddReplyHint => '新增回覆...';

  @override
  String get commentsComposerHint => '寫下留言...';

  @override
  String get commentsEditingStatus => '正在編輯留言';

  @override
  String commentsReplyingStatus(String name) {
    return '正在回覆 $name';
  }

  @override
  String get commentsWrite => '寫留言';

  @override
  String get commentsSend => '傳送';

  @override
  String get commentsCloseMenu => '關閉留言選單';

  @override
  String get commentsCopied => '留言已複製';

  @override
  String get commentsYourComment => '你的留言';

  @override
  String get commentsReportReasonTitle => '為什麼要檢舉這則留言？';

  @override
  String get commentsReportSent => '檢舉已送出，謝謝。';

  @override
  String get commentsDeleteTitle => '刪除留言？';

  @override
  String get commentsRepliesPreserved => '回覆會保留。';

  @override
  String get commentsDeleteAction => '刪除留言';

  @override
  String get commentsSortTitle => '留言排序';

  @override
  String get commentsPopular => '熱門';

  @override
  String get commentsNewest => '最新';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 則留言',
      zero: '留言',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => '複製留言';

  @override
  String get commentsEdited => '已編輯';

  @override
  String get commentsDeleted => '留言已刪除';

  @override
  String get commentsJustNow => '剛剛';

  @override
  String commentsMinutesAgo(int count) {
    return '$count 分鐘前';
  }

  @override
  String commentsHoursAgo(int count) {
    return '$count 小時前';
  }

  @override
  String commentsDaysAgo(int count) {
    return '$count 天前';
  }

  @override
  String commentsWeeksAgo(int count) {
    return '$count 週前';
  }

  @override
  String commentsMonthsAgo(int count) {
    return '$count 個月前';
  }

  @override
  String commentsYearsAgo(int count) {
    return '$count 年前';
  }

  @override
  String get commentsSpamReason => '垃圾訊息';

  @override
  String get commentsHarassmentReason => '騷擾或辱罵';

  @override
  String get commentsSpoilerReason => '電影劇透';

  @override
  String get commentsInappropriateReason => '不當內容';

  @override
  String get commentsOtherReason => '其他原因';

  @override
  String get commentsLoadFailed => '無法載入留言，請再試一次。';

  @override
  String get commentsLoadMoreFailed => '無法載入更多留言。';

  @override
  String get commentsRepliesLoadFailed => '無法載入回覆。';

  @override
  String get commentsRepliesLoadMoreFailed => '無法載入更多回覆。';

  @override
  String get commentsSendFailed => '無法傳送留言，你輸入的內容已保留。';

  @override
  String get commentsEditFailed => '無法編輯留言。';

  @override
  String get commentsDeleteFailed => '無法刪除留言。';

  @override
  String get commentsReactionFailed => '無法更新互動。';

  @override
  String get commentsReportFailed => '這則留言可能已被檢舉，或檢舉無法送出。';

  @override
  String get commentsOperationInProgress => '此操作正在進行中。';

  @override
  String get notificationsEmpty => '暫無新通知';

  @override
  String get notificationsRepliedToYourComment => '回覆了你的留言';

  @override
  String get notificationsLikedYourComment => '對你的留言按讚';

  @override
  String get notificationsToday => '今天';

  @override
  String get notificationsYesterday => '昨天';

  @override
  String get notificationsUnknownUser => '某位使用者';

  @override
  String get notificationsNewMovieTitle => '新電影';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count 部新電影';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName 剛剛加入 Liquid Phim。';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Liquid Phim 發現新電影時傳送通知';

  @override
  String get castChooseDevice => '選擇裝置';

  @override
  String get castAirPlayUnavailableTitle => '無法開啟 AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      '請確認你的 iPhone 與電視或 Mac 連接到同一個 Wi-Fi 網路，然後再試一次。';

  @override
  String get castVideoUnavailableTitle => '暫無可用影片';

  @override
  String get castVideoUnavailableBody => '請等待影片載入完成，再選擇 Google Cast 裝置。';

  @override
  String get castConnectionFailedTitle => '無法連線至 Google Cast';

  @override
  String get castConnectionFailedBody =>
      '請檢查 Google Play 服務，並確認手機與 Chromecast 或 Google TV 連接到同一個 Wi-Fi 網路。';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay 與藍牙裝置';

  @override
  String get castConnecting => '連線中...';

  @override
  String get castSearching => '正在搜尋 Google Cast 裝置...';

  @override
  String get castNoDevices => '找不到裝置';

  @override
  String get castSameWifiGuidance =>
      '請確認手機與 Chromecast 或 Google TV 連接到同一個 Wi-Fi 網路。';

  @override
  String get castSearchAgain => '重新搜尋';

  @override
  String get castDefaultDeviceName => 'Google Cast 裝置';

  @override
  String shareMovieSubject(String movieName) {
    return '在 Liquid Phim 上觀看 $movieName';
  }

  @override
  String get shareOpenFailed => '無法開啟分享面板。';

  @override
  String get rankingTopFavorites => '收藏電影 TOP';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => '熱門電影 TOP 30';

  @override
  String get rankingMostViewed => '觀看最多';

  @override
  String get rankingMostLiked => '按讚最多';

  @override
  String get rankingEmptyLikes => '電影獲得按讚後會顯示排行榜。';

  @override
  String get rankingEmptyViews => '電影獲得觀看次數後會顯示排行榜。';

  @override
  String get rankingLoadFailed => '無法載入排行榜。';

  @override
  String playerEpisodeNumber(int number) {
    return '第 $number 集';
  }

  @override
  String libraryMonthLabel(int month) {
    return '$month 月';
  }
}
