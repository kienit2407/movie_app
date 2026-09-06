// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'Фильмы в любое время и в любом месте';

  @override
  String get commonAgree => 'ОК';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonReport => 'Пожаловаться';

  @override
  String get commonRetry => 'Повторить';

  @override
  String get commonReset => 'Сбросить';

  @override
  String get commonAll => 'Все';

  @override
  String get commonSeeMore => 'Показать больше';

  @override
  String get commonCollapse => 'Показать меньше';

  @override
  String get commonLoading => 'Загрузка...';

  @override
  String get commonUpdating => 'Обновление';

  @override
  String get commonUnderstood => 'Понятно';

  @override
  String get commonNoData => 'Нет данных';

  @override
  String get commonNotAvailable => 'Н/Д';

  @override
  String get commonWarningTitle => 'Предупреждение';

  @override
  String get commonNoticeTitle => 'Уведомление';

  @override
  String get commonCongratulationsTitle => 'Поздравляем!';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonGoHome => 'На главную';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Выбрано $count элемента',
      many: 'Выбрано $count элементов',
      few: 'Выбрано $count элемента',
      one: 'Выбран $count элемент',
      zero: 'Ничего не выбрано',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'Ошибка: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours часа',
      many: '$hours часов',
      few: '$hours часа',
      one: '$hours час',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes минуты',
      many: '$minutes минут',
      few: '$minutes минуты',
      one: '$minutes минута',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get settingsLanguage => 'Язык';

  @override
  String get settingsLanguageSystem => 'Использовать язык устройства';

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
  String get settingsTitle => 'Настройки';

  @override
  String get settingsGeneralSection => 'Общие';

  @override
  String get settingsAppLanguage => 'Язык приложения';

  @override
  String get settingsAccountSection => 'Аккаунт';

  @override
  String get settingsSwitchAccount => 'Сменить аккаунт';

  @override
  String get settingsAddAccount => 'Добавить аккаунт';

  @override
  String get settingsAccountSwitchFailed =>
      'Не удалось сменить аккаунт. Войдите в этот аккаунт снова.';

  @override
  String get settingsSignOutFailed => 'Не удалось выйти. Повторите попытку.';

  @override
  String get navHome => 'Главная';

  @override
  String get navSearch => 'Поиск';

  @override
  String get navFavorites => 'Избранное';

  @override
  String get navProfile => 'Профиль';

  @override
  String get navNotifications => 'Уведомления';

  @override
  String get internetOffline => 'Нет подключения к Интернету';

  @override
  String get internetBackOnline => 'Снова в сети';

  @override
  String get authJoinMember => 'Стать участником';

  @override
  String get authSignInTitle => 'Войти в Liquid Phim';

  @override
  String get authSignIn => 'Войти';

  @override
  String get authSignInFailed => 'Не удалось войти. Повторите попытку.';

  @override
  String get authSignInToComment =>
      'Войдите, чтобы оставлять комментарии и общаться с сообществом.';

  @override
  String get authGoogleSyncDescription =>
      'Продолжите через Google, чтобы синхронизировать аккаунт и присоединиться к сообществу.';

  @override
  String get authGoogleConsent =>
      'Продолжая, вы соглашаетесь использовать свой аккаунт Google с Liquid Phim.';

  @override
  String get authContinueWithGoogle => 'Продолжить через Google';

  @override
  String get authGoogleSignInFailed =>
      'Не удалось войти через Google. Повторите попытку.';

  @override
  String get authGoogleSignInCheckFailed =>
      'Не удалось войти через Google. Проверьте подключение и повторите попытку.';

  @override
  String get authSessionUpdateFailed => 'Не удалось обновить сеанс входа.';

  @override
  String get authLoginRequired => 'Необходимо войти в аккаунт.';

  @override
  String get authLoginRequiredForAction =>
      'Для выполнения этого действия необходимо войти в аккаунт.';

  @override
  String get authEmail => 'Эл. почта';

  @override
  String get authPassword => 'Пароль';

  @override
  String get authFullName => 'Полное имя';

  @override
  String get authForgotPassword => 'Забыли пароль?';

  @override
  String get authOrContinueWith => 'Или продолжить через';

  @override
  String get authAlreadyHaveAccount => 'Уже есть аккаунт?';

  @override
  String get authFullNameRequired => 'Полное имя не может быть пустым.';

  @override
  String get authFullNameLength =>
      'Полное имя должно содержать от 3 до 15 символов.';

  @override
  String get authEmailRequired => 'Адрес эл. почты не может быть пустым.';

  @override
  String get authEmailInvalid => 'Введите действительный адрес эл. почты.';

  @override
  String get authPasswordRequired => 'Пароль не может быть пустым.';

  @override
  String get authPasswordLength =>
      'Пароль должен содержать от 6 до 15 символов.';

  @override
  String get authAccountAlreadyExists =>
      'Этот аккаунт уже существует. Выберите другой адрес эл. почты.';

  @override
  String get authWeakPassword =>
      'Этот пароль слишком слабый. Введите более надежный пароль.';

  @override
  String get authInvalidCredentials =>
      'Неверный адрес эл. почты или пароль. Повторите попытку.';

  @override
  String get authUnexpectedError => 'Что-то пошло не так. Повторите попытку.';

  @override
  String get authSignUpFailed =>
      'Не удалось создать аккаунт. Повторите попытку.';

  @override
  String get authSignUpSucceeded => 'Ваш аккаунт создан.';

  @override
  String get authSignInSucceeded => 'Вход выполнен.';

  @override
  String get authSignOutSucceeded => 'Вы вышли из аккаунта.';

  @override
  String get authTokenConfirmed => 'Код подтверждения принят.';

  @override
  String get authTokenInvalid => 'Неверный код подтверждения.';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      'Получать уведомления о новых фильмах?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim может периодически выполнять проверку в фоновом режиме и уведомлять вас о найденных новых фильмах. Для экономии заряда операционная система может задерживать проверки более чем на 20 минут.';

  @override
  String get homeEnableNotifications => 'Включить уведомления';

  @override
  String get homeDoNotEnable => 'Не сейчас';

  @override
  String get homeNotificationPermissionDisabled =>
      'Разрешение на уведомления отключено. Его можно снова включить в настройках телефона.';

  @override
  String get homeLoadMoviesFailed =>
      'Не удалось загрузить фильмы.\nПотяните вниз, чтобы повторить попытку.';

  @override
  String get homeRecommended => 'Рекомендуем';

  @override
  String get homeGenres => 'Жанры';

  @override
  String get homeCountries => 'Страны';

  @override
  String get homeYear => 'Год';

  @override
  String get homeFreshMovies => 'Свежие релизы!';

  @override
  String get homeKoreanMovies => 'Корейские фильмы';

  @override
  String get homeChineseMovies => 'Китайские фильмы';

  @override
  String get homeUsUkMovies => 'Фильмы США и Великобритании';

  @override
  String get homeWatchMovie => 'Смотреть';

  @override
  String get homeInformation => 'Информация';

  @override
  String get homeViewAll => 'Показать все';

  @override
  String get homeWhatToWatch => 'Что вы хотите посмотреть сегодня?';

  @override
  String get homeViewMore => 'Показать больше';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'Версия: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'Тип фильма';

  @override
  String get filterSeries => 'Сериалы';

  @override
  String get filterSingleMovies => 'Фильмы';

  @override
  String get filterAnimation => 'Анимация';

  @override
  String get filterTvShows => 'Телешоу';

  @override
  String get filterSubtitled => 'С субтитрами';

  @override
  String get filterVoiceOver => 'Закадровый перевод';

  @override
  String get filterDubbed => 'Дублированный';

  @override
  String get filterChooseMovieType => 'Выберите тип фильма.';

  @override
  String get filterChooseGenre => 'Выберите жанр.';

  @override
  String get filterChooseCountry => 'Выберите страну для фильтрации.';

  @override
  String get filterChooseYear => 'Выберите год для фильтрации.';

  @override
  String get filterLanguage => 'Язык';

  @override
  String get filterSortBy => 'Сортировать по';

  @override
  String get filterSortDirection => 'Направление сортировки';

  @override
  String get filterDescending => 'По убыванию';

  @override
  String get filterAscending => 'По возрастанию';

  @override
  String get filterMostViewed => 'Самые просматриваемые';

  @override
  String get filterNewest => 'Новейшие';

  @override
  String get filterReleaseYear => 'Год выпуска';

  @override
  String get filterApply => 'Применить фильтры';

  @override
  String get filterResults => 'Фильтровать результаты';

  @override
  String get searchAttentionTitle => 'Внимание';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'Введите ключевое слово перед фильтрацией фильмов.';

  @override
  String get searchNoResults => 'Ничего не найдено';

  @override
  String get searchMovieActorHint => 'Поиск фильмов, актеров...';

  @override
  String get searchFilterTooltip => 'Фильтры поиска';

  @override
  String get searchStartPrompt => 'Введите название фильма, чтобы начать поиск';

  @override
  String get searchRecent => 'Недавние запросы';

  @override
  String get searchLoadingGenres => 'Загрузка жанров...';

  @override
  String get searchLoadingCountries => 'Загрузка стран...';

  @override
  String get searchNoMovies => 'Нет фильмов';

  @override
  String get searchTryDifferentFilters => 'Попробуйте другие фильтры';

  @override
  String get librarySignOutTitle => 'Выйти?';

  @override
  String get librarySignOutConfirmation =>
      'Вы уверены, что хотите выйти из этого аккаунта?';

  @override
  String get librarySignOut => 'Выйти';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count выбранного фильма?',
      many: 'Удалить $count выбранных фильмов?',
      few: 'Удалить $count выбранных фильма?',
      one: 'Удалить $count выбранный фильм?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => 'Удалить этот фильм из истории?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count фильма из истории просмотров?',
      many: 'Удалить $count фильмов из истории просмотров?',
      few: 'Удалить $count фильма из истории просмотров?',
      one: 'Удалить $count фильм из истории просмотров?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle =>
      'Удалить этот фильм из избранного?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалить $count фильма из избранного?',
      many: 'Удалить $count фильмов из избранного?',
      few: 'Удалить $count фильма из избранного?',
      one: 'Удалить $count фильм из избранного?',
    );
    return '$_temp0';
  }

  @override
  String get libraryCancelSelection => 'Отменить выбор';

  @override
  String get libraryDeleteSelectedMovies => 'Удалить выбранные фильмы';

  @override
  String get libraryCannotResumeMovie =>
      'Сейчас невозможно продолжить просмотр этого фильма.';

  @override
  String get libraryYourProfile => 'Ваш профиль';

  @override
  String get librarySignInProfileDescription =>
      'Войдите, чтобы редактировать профиль и синхронизировать историю просмотров.';

  @override
  String get libraryWatchHistory => 'История просмотров';

  @override
  String get libraryNoWatchHistory => 'История просмотров пока пуста';

  @override
  String get libraryFavorites => 'Избранное';

  @override
  String get librarySignInToSaveFavorites =>
      'Войдите, чтобы сохранять любимые фильмы';

  @override
  String get libraryFavoritesSyncDescription =>
      'Ваш список будет синхронизирован на всех устройствах.';

  @override
  String get libraryNoFavorites => 'В избранном пока нет фильмов';

  @override
  String get libraryRemoveFromList => 'Удалить из списка';

  @override
  String libraryContinueProgress(int progress) {
    return 'Продолжить с $progress%';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed =>
      'Не удалось загрузить вашу медиатеку. Повторите попытку.';

  @override
  String get libraryFavoriteUpdateFailed =>
      'Не удалось обновить избранное. Повторите попытку.';

  @override
  String get libraryFavoriteRemoveFailed =>
      'Не удалось удалить фильм из избранного. Повторите попытку.';

  @override
  String get libraryHistorySyncLater => 'История будет синхронизирована позже.';

  @override
  String get libraryHistoryDeleteFailed =>
      'Не удалось удалить историю просмотров. Повторите попытку.';

  @override
  String get profileEdit => 'Редактировать профиль';

  @override
  String get profileChangePhoto => 'Изменить фото';

  @override
  String get profileName => 'Имя';

  @override
  String get profileNameDescription =>
      'Это имя будет отображаться в вашем профиле Liquid Phim.';

  @override
  String get profileNameHint => 'Введите отображаемое имя';

  @override
  String get profileClearName => 'Очистить имя';

  @override
  String get profileEmailDescription =>
      'Этот адрес эл. почты связан с вашим аккаунтом и отображается только здесь.';

  @override
  String get profileChangeAvatar => 'Изменить фото профиля';

  @override
  String get profileTakePhoto => 'Сделать фото';

  @override
  String get profileUploadPhoto => 'Загрузить фото';

  @override
  String get profileViewPhoto => 'Просмотреть фото';

  @override
  String get profileAvatar => 'Фото профиля';

  @override
  String get profileCropAvatar => 'Обрезать фото профиля';

  @override
  String get profileAvatarUpdated => 'Фото профиля обновлено.';

  @override
  String get profileAvatarUpdateFailed =>
      'Не удалось обновить фото профиля. Повторите попытку.';

  @override
  String get profilePhotoOpenFailed =>
      'Не удалось открыть фото. Проверьте разрешение на доступ к фотографиям.';

  @override
  String get profileNameUpdated => 'Отображаемое имя обновлено.';

  @override
  String get profileNameUpdateFailed =>
      'Не удалось обновить имя. Повторите попытку.';

  @override
  String get profileNameRequired => 'Имя не может быть пустым.';

  @override
  String get profileUpdatedProfileReadFailed =>
      'Не удалось прочитать обновленный профиль.';

  @override
  String get detailCastUnavailable => 'Информация об актерах недоступна';

  @override
  String get detailCast => 'В ролях';

  @override
  String get detailRecommendationsLoadFailed =>
      'Не удалось загрузить рекомендации';

  @override
  String get detailNoRecommendations => 'Нет рекомендаций';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'Эпизод $episode недоступен на текущем сервере.';
  }

  @override
  String get detailNoEpisodes => 'Нет доступных эпизодов';

  @override
  String get detailWatchThisVersion => 'Смотреть эту версию';

  @override
  String get detailServer => 'Сервер';

  @override
  String detailServerNumber(int number) {
    return 'Сервер $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'Эпизоды 1–$count';
  }

  @override
  String get detailEnterEpisode => 'Введите номер эпизода';

  @override
  String get detailLoadMovieError => 'Не удалось загрузить фильм';

  @override
  String get detailEpisodesTab => 'Эпизоды';

  @override
  String get detailRecommendationsTab => 'Рекомендации';

  @override
  String get detailCommentsTab => 'Комментарии';

  @override
  String get detailInTheaters => 'В кинотеатрах';

  @override
  String get detailExclusiveSubtitles => 'Эксклюзивные субтитры';

  @override
  String get detailDirectorLabel => 'Режиссер:';

  @override
  String get detailCreatedDateLabel => 'Добавлено:';

  @override
  String get detailProductionYearLabel => 'Год производства:';

  @override
  String get detailCountryLabel => 'Страна:';

  @override
  String get detailWatchLatestEpisode => 'Смотреть последний эпизод';

  @override
  String get detailWatchMovie => 'Смотреть фильм';

  @override
  String get detailIntroduction => 'Обзор';

  @override
  String get detailFavorite => 'В избранном';

  @override
  String get detailContent => 'Сюжет';

  @override
  String get detailNoPlayableEpisodes =>
      'У этого фильма пока нет доступных для воспроизведения эпизодов. Повторите попытку позже.';

  @override
  String get detailDetails => 'Подробнее';

  @override
  String get detailVideoQuality => 'Качество видео';

  @override
  String detailViews(String count) {
    return 'Просмотры: $count';
  }

  @override
  String detailLikes(String count) {
    return 'Отметки «Нравится»: $count';
  }

  @override
  String get detailUpdatedJustNow => 'Только что обновлено';

  @override
  String get playerSubtitleServer => 'С субтитрами';

  @override
  String get playerNowPlaying => 'Сейчас воспроизводится';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'Сейчас воспроизводится: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable =>
      'На этом сервере нет источника, доступного для воспроизведения.';

  @override
  String get playerSourceLoadFailed =>
      'Не удалось загрузить источник этого фильма.';

  @override
  String get playerAutoplayEnabled => 'Автовоспроизведение включено';

  @override
  String get playerAutoplayDisabled => 'Автовоспроизведение отключено';

  @override
  String get playerNoMoreEpisodes => 'Вы дошли до последнего эпизода';

  @override
  String get playerFirstEpisode => 'Это первый эпизод';

  @override
  String get playerPlaybackFailed =>
      'Не удалось воспроизвести видео. Повторите попытку.';

  @override
  String get playerPlay => 'Воспроизвести';

  @override
  String get playerPause => 'Пауза';

  @override
  String get playerPullDownToCloseComments =>
      'Потяните вниз, чтобы закрыть комментарии';

  @override
  String get playerPlayOnTv => 'Воспроизвести на ТВ';

  @override
  String get playerEpisodeList => 'Список эпизодов';

  @override
  String get playerVideoProgress => 'Ход воспроизведения';

  @override
  String get playerClose => 'Закрыть проигрыватель';

  @override
  String get playerContinueWatchingTitle => 'Продолжить просмотр?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'Вы смотрели $episode. Продолжить просмотр или начать заново с эпизода 1?';
  }

  @override
  String get playerRestartFromBeginning => 'Начать с начала';

  @override
  String get playerContinue => 'Продолжить';

  @override
  String get commentsReply => 'Ответить';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ответа',
      many: '$count ответов',
      few: '$count ответа',
      one: '$count ответ',
      zero: 'Нет ответов',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'Не удалось загрузить комментарии';

  @override
  String get commentsEmptyTitle => 'Комментариев пока нет';

  @override
  String get commentsEmptySubtitle => 'Поделитесь своим мнением первым.';

  @override
  String get commentsEditHint => 'Изменить комментарий...';

  @override
  String commentsReplyToHint(String name) {
    return 'Ответить пользователю $name...';
  }

  @override
  String get commentsAddReplyHint => 'Добавить ответ...';

  @override
  String get commentsComposerHint => 'Напишите комментарий...';

  @override
  String get commentsEditingStatus => 'Редактирование комментария';

  @override
  String commentsReplyingStatus(String name) {
    return 'Ответ пользователю $name';
  }

  @override
  String get commentsWrite => 'Написать комментарий';

  @override
  String get commentsSend => 'Отправить';

  @override
  String get commentsCloseMenu => 'Закрыть меню комментария';

  @override
  String get commentsCopied => 'Комментарий скопирован';

  @override
  String get commentsYourComment => 'Ваш комментарий';

  @override
  String get commentsReportReasonTitle =>
      'Почему вы жалуетесь на этот комментарий?';

  @override
  String get commentsReportSent => 'Жалоба отправлена. Спасибо.';

  @override
  String get commentsDeleteTitle => 'Удалить комментарий?';

  @override
  String get commentsRepliesPreserved => 'Ответы будут сохранены.';

  @override
  String get commentsDeleteAction => 'Удалить комментарий';

  @override
  String get commentsSortTitle => 'Сортировка комментариев';

  @override
  String get commentsPopular => 'Популярные';

  @override
  String get commentsNewest => 'Новые';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count комментария',
      many: '$count комментариев',
      few: '$count комментария',
      one: '$count комментарий',
      zero: 'Комментарии',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'Скопировать комментарий';

  @override
  String get commentsEdited => 'Изменено';

  @override
  String get commentsDeleted => 'Комментарий удален';

  @override
  String get commentsJustNow => 'только что';

  @override
  String commentsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count минуты назад',
      many: '$count минут назад',
      few: '$count минуты назад',
      one: '$count минуту назад',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count часа назад',
      many: '$count часов назад',
      few: '$count часа назад',
      one: '$count час назад',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня назад',
      many: '$count дней назад',
      few: '$count дня назад',
      one: '$count день назад',
    );
    return '$_temp0';
  }

  @override
  String commentsWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count недели назад',
      many: '$count недель назад',
      few: '$count недели назад',
      one: '$count неделю назад',
    );
    return '$_temp0';
  }

  @override
  String commentsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count месяца назад',
      many: '$count месяцев назад',
      few: '$count месяца назад',
      one: '$count месяц назад',
    );
    return '$_temp0';
  }

  @override
  String commentsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count года назад',
      many: '$count лет назад',
      few: '$count года назад',
      one: '$count год назад',
    );
    return '$_temp0';
  }

  @override
  String get commentsSpamReason => 'Спам';

  @override
  String get commentsHarassmentReason => 'Домогательства или оскорбления';

  @override
  String get commentsSpoilerReason => 'Спойлер к фильму';

  @override
  String get commentsInappropriateReason => 'Неприемлемый контент';

  @override
  String get commentsOtherReason => 'Другая причина';

  @override
  String get commentsLoadFailed =>
      'Не удалось загрузить комментарии. Повторите попытку.';

  @override
  String get commentsLoadMoreFailed =>
      'Не удалось загрузить дополнительные комментарии.';

  @override
  String get commentsRepliesLoadFailed => 'Не удалось загрузить ответы.';

  @override
  String get commentsRepliesLoadMoreFailed =>
      'Не удалось загрузить дополнительные ответы.';

  @override
  String get commentsSendFailed =>
      'Не удалось отправить комментарий. Ваш текст сохранен.';

  @override
  String get commentsEditFailed => 'Не удалось изменить комментарий.';

  @override
  String get commentsDeleteFailed => 'Не удалось удалить комментарий.';

  @override
  String get commentsReactionFailed => 'Не удалось обновить реакцию.';

  @override
  String get commentsReportFailed =>
      'На этот комментарий уже пожаловались или жалобу не удалось отправить.';

  @override
  String get commentsOperationInProgress => 'Это действие уже выполняется.';

  @override
  String get notificationsEmpty => 'Нет новых уведомлений';

  @override
  String get notificationsRepliedToYourComment =>
      'ответил(а) на ваш комментарий';

  @override
  String get notificationsLikedYourComment =>
      'поставил(а) отметку «Нравится» вашему комментарию';

  @override
  String get notificationsToday => 'Сегодня';

  @override
  String get notificationsYesterday => 'Вчера';

  @override
  String get notificationsUnknownUser => 'Кто-то';

  @override
  String get notificationsNewMovieTitle => 'Новый фильм';

  @override
  String notificationsNewMoviesTitle(int count) {
    return 'Новые фильмы: $count';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return 'Фильм «$movieName» только что добавлен в Liquid Phim.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Уведомления о новых фильмах, найденных Liquid Phim';

  @override
  String get castChooseDevice => 'Выберите устройство';

  @override
  String get castAirPlayUnavailableTitle => 'Не удалось открыть AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      'Убедитесь, что iPhone и телевизор или Mac подключены к одной сети Wi-Fi, затем повторите попытку.';

  @override
  String get castVideoUnavailableTitle => 'Видео недоступно';

  @override
  String get castVideoUnavailableBody =>
      'Дождитесь загрузки видео, затем выберите устройство Google Cast.';

  @override
  String get castConnectionFailedTitle =>
      'Не удалось подключиться к Google Cast';

  @override
  String get castConnectionFailedBody =>
      'Проверьте сервисы Google Play и убедитесь, что телефон и Chromecast или Google TV подключены к одной сети Wi-Fi.';

  @override
  String get castAirPlayAndBluetoothDevices => 'Устройства AirPlay и Bluetooth';

  @override
  String get castConnecting => 'Подключение...';

  @override
  String get castSearching => 'Поиск устройств Google Cast...';

  @override
  String get castNoDevices => 'Устройства не найдены';

  @override
  String get castSameWifiGuidance =>
      'Убедитесь, что телефон и Chromecast или Google TV подключены к одной сети Wi-Fi.';

  @override
  String get castSearchAgain => 'Искать снова';

  @override
  String get castDefaultDeviceName => 'Устройство Google Cast';

  @override
  String shareMovieSubject(String movieName) {
    return 'Смотреть «$movieName» в Liquid Phim';
  }

  @override
  String get shareOpenFailed => 'Не удалось открыть меню «Поделиться».';

  @override
  String get rankingTopFavorites => 'ТОП любимых фильмов';

  @override
  String get rankingTopLiquidPhim => 'ТОП-30 Liquid Phim';

  @override
  String get rankingTopHotMovies => 'ТОП-30 популярных фильмов';

  @override
  String get rankingMostViewed => 'САМЫЕ ПРОСМАТРИВАЕМЫЕ';

  @override
  String get rankingMostLiked => 'БОЛЬШЕ ВСЕГО ОТМЕТОК «НРАВИТСЯ»';

  @override
  String get rankingEmptyLikes =>
      'Рейтинг появится после того, как фильмы начнут получать отметки «Нравится».';

  @override
  String get rankingEmptyViews =>
      'Рейтинг появится после того, как фильмы начнут получать просмотры.';

  @override
  String get rankingLoadFailed => 'Не удалось загрузить рейтинг.';

  @override
  String playerEpisodeNumber(int number) {
    return 'Эпизод $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'Месяц $month';
  }
}
