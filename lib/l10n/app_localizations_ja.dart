// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'いつでも、どこでも映画を楽しもう';

  @override
  String get commonAgree => 'OK';

  @override
  String get commonCancel => 'キャンセル';

  @override
  String get commonClose => '閉じる';

  @override
  String get commonDone => '完了';

  @override
  String get commonSave => '保存';

  @override
  String get commonDelete => '削除';

  @override
  String get commonEdit => '編集';

  @override
  String get commonReport => '報告';

  @override
  String get commonRetry => 'もう一度試す';

  @override
  String get commonReset => 'リセット';

  @override
  String get commonAll => 'すべて';

  @override
  String get commonSeeMore => 'もっと見る';

  @override
  String get commonCollapse => '折りたたむ';

  @override
  String get commonLoading => '読み込み中...';

  @override
  String get commonUpdating => '更新中';

  @override
  String get commonUnderstood => 'わかりました';

  @override
  String get commonNoData => 'データがありません';

  @override
  String get commonNotAvailable => '利用不可';

  @override
  String get commonWarningTitle => '警告';

  @override
  String get commonNoticeTitle => 'お知らせ';

  @override
  String get commonCongratulationsTitle => 'おめでとうございます！';

  @override
  String get commonBack => '戻る';

  @override
  String get commonGoHome => 'ホームへ';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件選択',
      zero: '選択なし',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'エラー: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    return '$hours時間 $minutes分';
  }

  @override
  String get settingsLanguage => '言語';

  @override
  String get settingsLanguageSystem => '端末の言語を使用';

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
  String get settingsAppLanguage => 'アプリの言語';

  @override
  String get settingsAccountSection => 'アカウント';

  @override
  String get settingsSwitchAccount => 'アカウントを切り替える';

  @override
  String get settingsAddAccount => 'アカウントを追加';

  @override
  String get settingsAccountSwitchFailed =>
      'アカウントを切り替えられませんでした。もう一度そのアカウントにサインインしてください。';

  @override
  String get settingsSignOutFailed => 'サインアウトできませんでした。もう一度お試しください。';

  @override
  String get navHome => 'ホーム';

  @override
  String get navSearch => '検索';

  @override
  String get navFavorites => 'お気に入り';

  @override
  String get navProfile => 'プロフィール';

  @override
  String get navNotifications => '通知';

  @override
  String get internetOffline => 'インターネットに接続されていません';

  @override
  String get internetBackOnline => 'オンラインに戻りました';

  @override
  String get authJoinMember => 'メンバーとして参加';

  @override
  String get authSignInTitle => 'Liquid Phim にサインイン';

  @override
  String get authSignIn => 'サインイン';

  @override
  String get authSignInFailed => 'サインインに失敗しました。もう一度お試しください。';

  @override
  String get authSignInToComment => 'コメントやコミュニティ交流を利用するにはサインインしてください。';

  @override
  String get authGoogleSyncDescription => 'Google で続行してアカウントを同期し、コミュニティに参加します。';

  @override
  String get authGoogleConsent =>
      '続行すると、Google アカウントを Liquid Phim で使用することに同意したものとみなされます。';

  @override
  String get authContinueWithGoogle => 'Google で続行';

  @override
  String get authGoogleSignInFailed => 'Google でサインインできませんでした。もう一度お試しください。';

  @override
  String get authGoogleSignInCheckFailed =>
      'Google でサインインできませんでした。接続を確認してもう一度お試しください。';

  @override
  String get authSessionUpdateFailed => 'サインインセッションを更新できませんでした。';

  @override
  String get authLoginRequired => 'サインインが必要です。';

  @override
  String get authLoginRequiredForAction => 'この操作を行うにはサインインが必要です。';

  @override
  String get authEmail => 'メールアドレス';

  @override
  String get authPassword => 'パスワード';

  @override
  String get authFullName => '氏名';

  @override
  String get authForgotPassword => 'パスワードをお忘れですか？';

  @override
  String get authOrContinueWith => 'または次で続行';

  @override
  String get authAlreadyHaveAccount => 'すでにアカウントをお持ちですか？';

  @override
  String get authFullNameRequired => '氏名を入力してください。';

  @override
  String get authFullNameLength => '氏名は3〜15文字で入力してください。';

  @override
  String get authEmailRequired => 'メールアドレスを入力してください。';

  @override
  String get authEmailInvalid => '有効なメールアドレスを入力してください。';

  @override
  String get authPasswordRequired => 'パスワードを入力してください。';

  @override
  String get authPasswordLength => 'パスワードは6〜15文字で入力してください。';

  @override
  String get authAccountAlreadyExists => 'このアカウントはすでに存在します。別のメールアドレスを選択してください。';

  @override
  String get authWeakPassword => 'このパスワードは弱すぎます。より強力なパスワードを入力してください。';

  @override
  String get authInvalidCredentials => 'メールアドレスまたはパスワードが正しくありません。もう一度お試しください。';

  @override
  String get authUnexpectedError => '問題が発生しました。もう一度お試しください。';

  @override
  String get authSignUpFailed => 'アカウントを作成できませんでした。もう一度お試しください。';

  @override
  String get authSignUpSucceeded => 'アカウントが作成されました。';

  @override
  String get authSignInSucceeded => 'サインインしました。';

  @override
  String get authSignOutSucceeded => 'サインアウトしました。';

  @override
  String get authTokenConfirmed => '確認コードを確認しました。';

  @override
  String get authTokenInvalid => '確認コードが正しくありません。';

  @override
  String get homeEnableNewMovieNotificationsTitle => '新着映画の通知を受け取りますか？';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim はバックグラウンドで定期的に確認し、新しい映画が見つかったときに通知できます。バッテリー節約のため、OS により確認が20分以上遅れる場合があります。';

  @override
  String get homeEnableNotifications => '通知を有効にする';

  @override
  String get homeDoNotEnable => '今はしない';

  @override
  String get homeNotificationPermissionDisabled =>
      '通知権限が無効です。端末の設定から再度有効にできます。';

  @override
  String get homeLoadMoviesFailed => '映画を読み込めませんでした。\n下に引っ張ってもう一度お試しください。';

  @override
  String get homeRecommended => 'おすすめ';

  @override
  String get homeGenres => 'ジャンル';

  @override
  String get homeCountries => '国';

  @override
  String get homeYear => '年';

  @override
  String get homeFreshMovies => '新着作品！';

  @override
  String get homeKoreanMovies => '韓国映画';

  @override
  String get homeChineseMovies => '中国映画';

  @override
  String get homeUsUkMovies => '欧米映画';

  @override
  String get homeWatchMovie => '視聴';

  @override
  String get homeInformation => '情報';

  @override
  String get homeViewAll => 'すべて表示';

  @override
  String get homeWhatToWatch => '今日は何を観ますか？';

  @override
  String get homeViewMore => 'もっと見る';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'バージョン: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => '作品タイプ';

  @override
  String get filterSeries => 'ドラマ';

  @override
  String get filterSingleMovies => '映画';

  @override
  String get filterAnimation => 'アニメ';

  @override
  String get filterTvShows => 'TV番組';

  @override
  String get filterSubtitled => '字幕';

  @override
  String get filterVoiceOver => 'ボイスオーバー';

  @override
  String get filterDubbed => '吹き替え';

  @override
  String get filterChooseMovieType => '作品タイプを選択してください。';

  @override
  String get filterChooseGenre => 'ジャンルを選択してください。';

  @override
  String get filterChooseCountry => '絞り込む国を選択してください。';

  @override
  String get filterChooseYear => '絞り込む年を選択してください。';

  @override
  String get filterLanguage => '言語';

  @override
  String get filterSortBy => '並び替え';

  @override
  String get filterSortDirection => '並び順';

  @override
  String get filterDescending => '降順';

  @override
  String get filterAscending => '昇順';

  @override
  String get filterMostViewed => '再生回数順';

  @override
  String get filterNewest => '新着順';

  @override
  String get filterReleaseYear => '公開年';

  @override
  String get filterApply => 'フィルターを適用';

  @override
  String get filterResults => '結果を絞り込む';

  @override
  String get searchAttentionTitle => '注意';

  @override
  String get searchEnterKeywordBeforeFiltering => '映画を絞り込む前にキーワードを入力してください。';

  @override
  String get searchNoResults => '結果が見つかりません';

  @override
  String get searchMovieActorHint => '映画、俳優を検索...';

  @override
  String get searchFilterTooltip => '検索フィルター';

  @override
  String get searchStartPrompt => '映画タイトルを入力して検索を開始';

  @override
  String get searchRecent => '最近の検索';

  @override
  String get searchLoadingGenres => 'ジャンルを読み込み中...';

  @override
  String get searchLoadingCountries => '国を読み込み中...';

  @override
  String get searchNoMovies => '映画がありません';

  @override
  String get searchTryDifferentFilters => '別のフィルターをお試しください';

  @override
  String get librarySignOutTitle => 'サインアウトしますか？';

  @override
  String get librarySignOutConfirmation => 'このアカウントからサインアウトしますか？';

  @override
  String get librarySignOut => 'サインアウト';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    return '選択した$count件の映画を削除しますか？';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => 'この映画を履歴から削除しますか？';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    return '視聴履歴から$count件の映画を削除しますか？';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle => 'この映画をお気に入りから削除しますか？';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    return 'お気に入りから$count件の映画を削除しますか？';
  }

  @override
  String get libraryCancelSelection => '選択を解除';

  @override
  String get libraryDeleteSelectedMovies => '選択した映画を削除';

  @override
  String get libraryCannotResumeMovie => '現在この映画を再開できません。';

  @override
  String get libraryYourProfile => 'あなたのプロフィール';

  @override
  String get librarySignInProfileDescription =>
      'プロフィールの編集と視聴履歴の同期にはサインインしてください。';

  @override
  String get libraryWatchHistory => '視聴履歴';

  @override
  String get libraryNoWatchHistory => '視聴履歴はまだありません';

  @override
  String get libraryFavorites => 'お気に入り';

  @override
  String get librarySignInToSaveFavorites => 'お気に入りを保存するにはサインインしてください';

  @override
  String get libraryFavoritesSyncDescription => 'リストは端末間で同期されます。';

  @override
  String get libraryNoFavorites => 'お気に入りの映画はまだありません';

  @override
  String get libraryRemoveFromList => 'リストから削除';

  @override
  String libraryContinueProgress(int progress) {
    return '$progress%から続ける';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed => 'ライブラリを読み込めませんでした。もう一度お試しください。';

  @override
  String get libraryFavoriteUpdateFailed => 'お気に入りを更新できませんでした。もう一度お試しください。';

  @override
  String get libraryFavoriteRemoveFailed => 'お気に入りから削除できませんでした。もう一度お試しください。';

  @override
  String get libraryHistorySyncLater => '視聴履歴は後でもう一度同期されます。';

  @override
  String get libraryHistoryDeleteFailed => '視聴履歴を削除できませんでした。もう一度お試しください。';

  @override
  String get profileEdit => 'プロフィールを編集';

  @override
  String get profileChangePhoto => '写真を変更';

  @override
  String get profileName => '名前';

  @override
  String get profileNameDescription => 'この名前は Liquid Phim のプロフィールに表示されます。';

  @override
  String get profileNameHint => '表示名を入力';

  @override
  String get profileClearName => '名前を消去';

  @override
  String get profileEmailDescription => 'このメールアドレスはアカウントに紐づいており、ここにのみ表示されます。';

  @override
  String get profileChangeAvatar => 'プロフィール写真を変更';

  @override
  String get profileTakePhoto => '写真を撮る';

  @override
  String get profileUploadPhoto => '写真をアップロード';

  @override
  String get profileViewPhoto => '写真を見る';

  @override
  String get profileAvatar => 'プロフィール写真';

  @override
  String get profileCropAvatar => 'プロフィール写真を切り抜く';

  @override
  String get profileAvatarUpdated => 'プロフィール写真を更新しました。';

  @override
  String get profileAvatarUpdateFailed => 'プロフィール写真を更新できませんでした。もう一度お試しください。';

  @override
  String get profilePhotoOpenFailed => '写真を開けませんでした。写真へのアクセス権限を確認してください。';

  @override
  String get profileNameUpdated => '表示名を更新しました。';

  @override
  String get profileNameUpdateFailed => '名前を更新できませんでした。もう一度お試しください。';

  @override
  String get profileNameRequired => '名前を入力してください。';

  @override
  String get profileUpdatedProfileReadFailed => '更新したプロフィールを読み込めませんでした。';

  @override
  String get detailCastUnavailable => '出演者情報はありません';

  @override
  String get detailCast => '出演者';

  @override
  String get detailRecommendationsLoadFailed => 'おすすめを読み込めませんでした';

  @override
  String get detailNoRecommendations => 'おすすめはありません';

  @override
  String detailEpisodeNotFound(int episode) {
    return '現在のサーバーではエピソード$episodeを利用できません。';
  }

  @override
  String get detailNoEpisodes => '利用可能なエピソードはありません';

  @override
  String get detailWatchThisVersion => 'このバージョンを視聴';

  @override
  String get detailServer => 'サーバー';

  @override
  String detailServerNumber(int number) {
    return 'サーバー $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'エピソード 1–$count';
  }

  @override
  String get detailEnterEpisode => 'エピソード番号を入力';

  @override
  String get detailLoadMovieError => '映画を読み込めませんでした';

  @override
  String get detailEpisodesTab => 'エピソード';

  @override
  String get detailRecommendationsTab => 'おすすめ';

  @override
  String get detailCommentsTab => 'コメント';

  @override
  String get detailInTheaters => '劇場公開';

  @override
  String get detailExclusiveSubtitles => '独占字幕';

  @override
  String get detailDirectorLabel => '監督:';

  @override
  String get detailCreatedDateLabel => '追加日:';

  @override
  String get detailProductionYearLabel => '製作年:';

  @override
  String get detailCountryLabel => '国:';

  @override
  String get detailWatchLatestEpisode => '最新話を視聴';

  @override
  String get detailWatchMovie => '映画を視聴';

  @override
  String get detailIntroduction => '概要';

  @override
  String get detailFavorite => 'お気に入り';

  @override
  String get detailContent => 'あらすじ';

  @override
  String get detailNoPlayableEpisodes =>
      'この作品にはまだ再生可能なエピソードがありません。しばらくしてからもう一度お試しください。';

  @override
  String get detailDetails => '詳細';

  @override
  String get detailVideoQuality => '画質';

  @override
  String detailViews(String count) {
    return '$count 回視聴';
  }

  @override
  String detailLikes(String count) {
    return '$count いいね';
  }

  @override
  String get detailUpdatedJustNow => 'たった今更新';

  @override
  String get playerSubtitleServer => '字幕';

  @override
  String get playerNowPlaying => '再生中';

  @override
  String playerNowPlayingEpisode(String episode) {
    return '再生中: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable => 'このサーバーには再生可能なソースがありません。';

  @override
  String get playerSourceLoadFailed => 'この動画ソースを読み込めませんでした。';

  @override
  String get playerAutoplayEnabled => '自動再生を有効にしました';

  @override
  String get playerAutoplayDisabled => '自動再生を無効にしました';

  @override
  String get playerNoMoreEpisodes => '最終話です';

  @override
  String get playerFirstEpisode => 'これは第1話です';

  @override
  String get playerPlaybackFailed => '動画を再生できませんでした。もう一度お試しください。';

  @override
  String get playerPlay => '再生';

  @override
  String get playerPause => '一時停止';

  @override
  String get playerPullDownToCloseComments => '下に引っ張ってコメントを閉じる';

  @override
  String get playerPlayOnTv => 'テレビで再生';

  @override
  String get playerEpisodeList => 'エピソード一覧';

  @override
  String get playerVideoProgress => '動画の再生位置';

  @override
  String get playerClose => 'プレーヤーを閉じる';

  @override
  String get playerContinueWatchingTitle => '視聴を続けますか？';

  @override
  String playerContinueWatchingBody(String episode) {
    return '$episodeを視聴していました。続きから再生しますか、それとも第1話から再開しますか？';
  }

  @override
  String get playerRestartFromBeginning => '最初から再生';

  @override
  String get playerContinue => '続ける';

  @override
  String get commentsReply => '返信';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の返信',
      zero: '返信なし',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'コメントを読み込めませんでした';

  @override
  String get commentsEmptyTitle => 'コメントはまだありません';

  @override
  String get commentsEmptySubtitle => '最初のコメントを投稿してみましょう。';

  @override
  String get commentsEditHint => 'コメントを編集...';

  @override
  String commentsReplyToHint(String name) {
    return '$nameさんに返信...';
  }

  @override
  String get commentsAddReplyHint => '返信を追加...';

  @override
  String get commentsComposerHint => 'コメントを書く...';

  @override
  String get commentsEditingStatus => 'コメントを編集中';

  @override
  String commentsReplyingStatus(String name) {
    return '$nameさんに返信中';
  }

  @override
  String get commentsWrite => 'コメントを書く';

  @override
  String get commentsSend => '送信';

  @override
  String get commentsCloseMenu => 'コメントメニューを閉じる';

  @override
  String get commentsCopied => 'コメントをコピーしました';

  @override
  String get commentsYourComment => 'あなたのコメント';

  @override
  String get commentsReportReasonTitle => 'このコメントを報告する理由は？';

  @override
  String get commentsReportSent => '報告を送信しました。ありがとうございます。';

  @override
  String get commentsDeleteTitle => 'コメントを削除しますか？';

  @override
  String get commentsRepliesPreserved => '返信は保持されます。';

  @override
  String get commentsDeleteAction => 'コメントを削除';

  @override
  String get commentsSortTitle => 'コメントを並び替え';

  @override
  String get commentsPopular => '人気';

  @override
  String get commentsNewest => '新着';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件のコメント',
      zero: 'コメント',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'コメントをコピー';

  @override
  String get commentsEdited => '編集済み';

  @override
  String get commentsDeleted => 'コメントは削除されました';

  @override
  String get commentsJustNow => 'たった今';

  @override
  String commentsMinutesAgo(int count) {
    return '$count分前';
  }

  @override
  String commentsHoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String commentsDaysAgo(int count) {
    return '$count日前';
  }

  @override
  String commentsWeeksAgo(int count) {
    return '$count週間前';
  }

  @override
  String commentsMonthsAgo(int count) {
    return '$countか月前';
  }

  @override
  String commentsYearsAgo(int count) {
    return '$count年前';
  }

  @override
  String get commentsSpamReason => 'スパム';

  @override
  String get commentsHarassmentReason => '嫌がらせ・誹謗中傷';

  @override
  String get commentsSpoilerReason => 'ネタバレ';

  @override
  String get commentsInappropriateReason => '不適切な内容';

  @override
  String get commentsOtherReason => 'その他';

  @override
  String get commentsLoadFailed => 'コメントを読み込めませんでした。もう一度お試しください。';

  @override
  String get commentsLoadMoreFailed => 'コメントをさらに読み込めませんでした。';

  @override
  String get commentsRepliesLoadFailed => '返信を読み込めませんでした。';

  @override
  String get commentsRepliesLoadMoreFailed => '返信をさらに読み込めませんでした。';

  @override
  String get commentsSendFailed => 'コメントを送信できませんでした。入力内容は保持されています。';

  @override
  String get commentsEditFailed => 'コメントを編集できませんでした。';

  @override
  String get commentsDeleteFailed => 'コメントを削除できませんでした。';

  @override
  String get commentsReactionFailed => 'リアクションを更新できませんでした。';

  @override
  String get commentsReportFailed => 'このコメントはすでに報告済みか、報告を送信できませんでした。';

  @override
  String get commentsOperationInProgress => 'この操作はすでに実行中です。';

  @override
  String get notificationsEmpty => '新しい通知はありません';

  @override
  String get notificationsRepliedToYourComment => 'あなたのコメントに返信しました';

  @override
  String get notificationsLikedYourComment => 'あなたのコメントにいいねしました';

  @override
  String get notificationsToday => '今日';

  @override
  String get notificationsYesterday => '昨日';

  @override
  String get notificationsUnknownUser => 'ユーザー';

  @override
  String get notificationsNewMovieTitle => '新着映画';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '新着映画 $count件';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName が Liquid Phim に追加されました。';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Liquid Phim が新しい映画を見つけたときの通知';

  @override
  String get castChooseDevice => 'デバイスを選択';

  @override
  String get castAirPlayUnavailableTitle => 'AirPlay を開けませんでした';

  @override
  String get castAirPlayUnavailableBody =>
      'iPhone とテレビまたは Mac が同じ Wi-Fi ネットワークに接続されていることを確認して、もう一度お試しください。';

  @override
  String get castVideoUnavailableTitle => '利用可能な動画がありません';

  @override
  String get castVideoUnavailableBody =>
      '動画の読み込みが完了してから Google Cast デバイスを選択してください。';

  @override
  String get castConnectionFailedTitle => 'Google Cast に接続できませんでした';

  @override
  String get castConnectionFailedBody =>
      'Google Play 開発者サービスを確認し、スマートフォンと Chromecast または Google TV が同じ Wi-Fi ネットワークに接続されていることを確認してください。';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay と Bluetooth デバイス';

  @override
  String get castConnecting => '接続中...';

  @override
  String get castSearching => 'Google Cast デバイスを検索中...';

  @override
  String get castNoDevices => 'デバイスが見つかりません';

  @override
  String get castSameWifiGuidance =>
      'スマートフォンと Chromecast または Google TV が同じ Wi-Fi ネットワークに接続されていることを確認してください。';

  @override
  String get castSearchAgain => 'もう一度検索';

  @override
  String get castDefaultDeviceName => 'Google Cast デバイス';

  @override
  String shareMovieSubject(String movieName) {
    return 'Liquid Phim で $movieName を視聴';
  }

  @override
  String get shareOpenFailed => '共有シートを開けませんでした。';

  @override
  String get rankingTopFavorites => 'お気に入り映画 TOP';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => '話題の映画 TOP 30';

  @override
  String get rankingMostViewed => '最も視聴された作品';

  @override
  String get rankingMostLiked => '最も「いいね」された作品';

  @override
  String get rankingEmptyLikes => '映画に「いいね」が付くとランキングが表示されます。';

  @override
  String get rankingEmptyViews => '映画が視聴されるとランキングが表示されます。';

  @override
  String get rankingLoadFailed => 'ランキングを読み込めませんでした。';

  @override
  String playerEpisodeNumber(int number) {
    return '第$number話';
  }

  @override
  String libraryMonthLabel(int month) {
    return '$month月';
  }
}
