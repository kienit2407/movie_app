// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'Filme jederzeit und überall';

  @override
  String get commonAgree => 'OK';

  @override
  String get commonCancel => 'Abbrechen';

  @override
  String get commonClose => 'Schließen';

  @override
  String get commonDone => 'Fertig';

  @override
  String get commonSave => 'Speichern';

  @override
  String get commonDelete => 'Löschen';

  @override
  String get commonEdit => 'Bearbeiten';

  @override
  String get commonReport => 'Melden';

  @override
  String get commonRetry => 'Erneut versuchen';

  @override
  String get commonReset => 'Zurücksetzen';

  @override
  String get commonAll => 'Alle';

  @override
  String get commonSeeMore => 'Mehr anzeigen';

  @override
  String get commonCollapse => 'Weniger anzeigen';

  @override
  String get commonLoading => 'Wird geladen...';

  @override
  String get commonUpdating => 'Wird aktualisiert';

  @override
  String get commonUnderstood => 'Verstanden';

  @override
  String get commonNoData => 'Keine Daten';

  @override
  String get commonNotAvailable => 'N/V';

  @override
  String get commonWarningTitle => 'Warnung';

  @override
  String get commonNoticeTitle => 'Hinweis';

  @override
  String get commonCongratulationsTitle => 'Glückwunsch!';

  @override
  String get commonBack => 'Zurück';

  @override
  String get commonGoHome => 'Zur Startseite';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählt',
      one: '1 ausgewählt',
      zero: 'Nichts ausgewählt',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'Fehler: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours Stunden',
      one: '1 Stunde',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes Minuten',
      one: '1 Minute',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get settingsLanguageSystem => 'Gerätesprache verwenden';

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
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsGeneralSection => 'Allgemein';

  @override
  String get settingsAppLanguage => 'App-Sprache';

  @override
  String get settingsAccountSection => 'Konto';

  @override
  String get settingsSwitchAccount => 'Konto wechseln';

  @override
  String get settingsAddAccount => 'Konto hinzufügen';

  @override
  String get settingsAccountSwitchFailed =>
      'Das Konto konnte nicht gewechselt werden. Bitte melde dich erneut bei diesem Konto an.';

  @override
  String get settingsSignOutFailed =>
      'Abmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get navHome => 'Start';

  @override
  String get navSearch => 'Suchen';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navProfile => 'Profil';

  @override
  String get navNotifications => 'Benachrichtigungen';

  @override
  String get internetOffline => 'Keine Internetverbindung';

  @override
  String get internetBackOnline => 'Wieder online';

  @override
  String get authJoinMember => 'Als Mitglied beitreten';

  @override
  String get authSignInTitle => 'Bei Liquid Phim anmelden';

  @override
  String get authSignIn => 'Anmelden';

  @override
  String get authSignInFailed =>
      'Die Anmeldung war nicht erfolgreich. Bitte versuche es erneut.';

  @override
  String get authSignInToComment =>
      'Melde dich an, um zu kommentieren und mit der Community zu interagieren.';

  @override
  String get authGoogleSyncDescription =>
      'Mit Google fortfahren, um dein Konto zu synchronisieren und der Community beizutreten.';

  @override
  String get authGoogleConsent =>
      'Wenn du fortfährst, stimmst du der Verwendung deines Google-Kontos mit Liquid Phim zu.';

  @override
  String get authContinueWithGoogle => 'Mit Google fortfahren';

  @override
  String get authGoogleSignInFailed =>
      'Die Anmeldung mit Google ist fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get authGoogleSignInCheckFailed =>
      'Die Anmeldung mit Google ist fehlgeschlagen. Bitte prüfe deine Verbindung und versuche es erneut.';

  @override
  String get authSessionUpdateFailed =>
      'Deine Anmeldesitzung konnte nicht aktualisiert werden.';

  @override
  String get authLoginRequired => 'Du musst dich anmelden.';

  @override
  String get authLoginRequiredForAction =>
      'Du musst dich anmelden, um diese Aktion auszuführen.';

  @override
  String get authEmail => 'E-Mail';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authFullName => 'Vollständiger Name';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authOrContinueWith => 'Oder fortfahren mit';

  @override
  String get authAlreadyHaveAccount => 'Du hast bereits ein Konto?';

  @override
  String get authFullNameRequired =>
      'Der vollständige Name darf nicht leer sein.';

  @override
  String get authFullNameLength =>
      'Der vollständige Name muss zwischen 3 und 15 Zeichen lang sein.';

  @override
  String get authEmailRequired => 'Die E-Mail-Adresse darf nicht leer sein.';

  @override
  String get authEmailInvalid => 'Gib eine gültige E-Mail-Adresse ein.';

  @override
  String get authPasswordRequired => 'Das Passwort darf nicht leer sein.';

  @override
  String get authPasswordLength =>
      'Das Passwort muss zwischen 6 und 15 Zeichen lang sein.';

  @override
  String get authAccountAlreadyExists =>
      'Dieses Konto existiert bereits. Bitte wähle eine andere E-Mail-Adresse.';

  @override
  String get authWeakPassword =>
      'Dieses Passwort ist zu schwach. Bitte gib ein stärkeres Passwort ein.';

  @override
  String get authInvalidCredentials =>
      'Die E-Mail-Adresse oder das Passwort ist falsch. Bitte versuche es erneut.';

  @override
  String get authUnexpectedError =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get authSignUpFailed =>
      'Dein Konto konnte nicht erstellt werden. Bitte versuche es erneut.';

  @override
  String get authSignUpSucceeded => 'Dein Konto wurde erstellt.';

  @override
  String get authSignInSucceeded => 'Erfolgreich angemeldet.';

  @override
  String get authSignOutSucceeded => 'Erfolgreich abgemeldet.';

  @override
  String get authTokenConfirmed => 'Bestätigungscode bestätigt.';

  @override
  String get authTokenInvalid => 'Der Bestätigungscode ist falsch.';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      'Benachrichtigungen über neue Filme erhalten?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim kann regelmäßig im Hintergrund prüfen und dich benachrichtigen, wenn neue Filme gefunden werden. Das Betriebssystem kann Prüfungen um mehr als 20 Minuten verzögern, um Akku zu sparen.';

  @override
  String get homeEnableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get homeDoNotEnable => 'Nicht jetzt';

  @override
  String get homeNotificationPermissionDisabled =>
      'Die Benachrichtigungsberechtigung ist deaktiviert. Du kannst sie in den Einstellungen deines Telefons wieder aktivieren.';

  @override
  String get homeLoadMoviesFailed =>
      'Filme konnten nicht geladen werden.\nZum erneuten Versuchen nach unten ziehen.';

  @override
  String get homeRecommended => 'Empfohlen';

  @override
  String get homeGenres => 'Genres';

  @override
  String get homeCountries => 'Länder';

  @override
  String get homeYear => 'Jahr';

  @override
  String get homeFreshMovies => 'Neu erschienen!';

  @override
  String get homeKoreanMovies => 'Koreanische Filme';

  @override
  String get homeChineseMovies => 'Chinesische Filme';

  @override
  String get homeUsUkMovies => 'Filme aus den USA und Großbritannien';

  @override
  String get homeWatchMovie => 'Ansehen';

  @override
  String get homeInformation => 'Info';

  @override
  String get homeViewAll => 'Alle anzeigen';

  @override
  String get homeWhatToWatch => 'Was möchtest du heute ansehen?';

  @override
  String get homeViewMore => 'Mehr anzeigen';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'Version: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'Filmtyp';

  @override
  String get filterSeries => 'Serien';

  @override
  String get filterSingleMovies => 'Filme';

  @override
  String get filterAnimation => 'Animation';

  @override
  String get filterTvShows => 'TV-Sendungen';

  @override
  String get filterSubtitled => 'Untertitelt';

  @override
  String get filterVoiceOver => 'Voice-over';

  @override
  String get filterDubbed => 'Synchronisiert';

  @override
  String get filterChooseMovieType => 'Bitte wähle einen Filmtyp aus.';

  @override
  String get filterChooseGenre => 'Bitte wähle ein Genre aus.';

  @override
  String get filterChooseCountry => 'Wähle ein Land zum Filtern aus.';

  @override
  String get filterChooseYear => 'Wähle ein Jahr zum Filtern aus.';

  @override
  String get filterLanguage => 'Sprache';

  @override
  String get filterSortBy => 'Sortieren nach';

  @override
  String get filterSortDirection => 'Sortierrichtung';

  @override
  String get filterDescending => 'Absteigend';

  @override
  String get filterAscending => 'Aufsteigend';

  @override
  String get filterMostViewed => 'Meistgesehen';

  @override
  String get filterNewest => 'Neueste';

  @override
  String get filterReleaseYear => 'Erscheinungsjahr';

  @override
  String get filterApply => 'Filter anwenden';

  @override
  String get filterResults => 'Ergebnisse filtern';

  @override
  String get searchAttentionTitle => 'Achtung';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'Gib ein Suchwort ein, bevor du Filme filterst.';

  @override
  String get searchNoResults => 'Keine Ergebnisse gefunden';

  @override
  String get searchMovieActorHint => 'Filme, Schauspieler suchen...';

  @override
  String get searchFilterTooltip => 'Suchfilter';

  @override
  String get searchStartPrompt =>
      'Gib einen Filmtitel ein, um die Suche zu starten';

  @override
  String get searchRecent => 'Letzte Suchanfragen';

  @override
  String get searchLoadingGenres => 'Genres werden geladen...';

  @override
  String get searchLoadingCountries => 'Länder werden geladen...';

  @override
  String get searchNoMovies => 'Keine Filme';

  @override
  String get searchTryDifferentFilters => 'Probiere andere Filter aus';

  @override
  String get librarySignOutTitle => 'Abmelden?';

  @override
  String get librarySignOutConfirmation =>
      'Möchtest du dich wirklich von diesem Konto abmelden?';

  @override
  String get librarySignOut => 'Abmelden';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ausgewählte Filme löschen?',
      one: 'Ausgewählten Film löschen?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle =>
      'Diesen Film aus dem Verlauf löschen?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Filme aus dem Wiedergabeverlauf entfernen?',
      one: 'Diesen Film aus dem Wiedergabeverlauf entfernen?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle =>
      'Diesen Film aus den Favoriten entfernen?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Filme aus den Favoriten entfernen?',
      one: 'Diesen Film aus den Favoriten entfernen?',
    );
    return '$_temp0';
  }

  @override
  String get libraryCancelSelection => 'Auswahl aufheben';

  @override
  String get libraryDeleteSelectedMovies => 'Ausgewählte Filme löschen';

  @override
  String get libraryCannotResumeMovie =>
      'Dieser Film kann derzeit nicht fortgesetzt werden.';

  @override
  String get libraryYourProfile => 'Dein Profil';

  @override
  String get librarySignInProfileDescription =>
      'Melde dich an, um dein Profil zu bearbeiten und deinen Wiedergabeverlauf zu synchronisieren.';

  @override
  String get libraryWatchHistory => 'Wiedergabeverlauf';

  @override
  String get libraryNoWatchHistory => 'Noch kein Wiedergabeverlauf';

  @override
  String get libraryFavorites => 'Favoriten';

  @override
  String get librarySignInToSaveFavorites =>
      'Melde dich an, um Lieblingsfilme zu speichern';

  @override
  String get libraryFavoritesSyncDescription =>
      'Deine Liste wird auf allen deinen Geräten synchronisiert.';

  @override
  String get libraryNoFavorites => 'Noch keine Lieblingsfilme';

  @override
  String get libraryRemoveFromList => 'Aus Liste entfernen';

  @override
  String libraryContinueProgress(int progress) {
    return 'Fortsetzen bei $progress%';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed =>
      'Deine Mediathek konnte nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get libraryFavoriteUpdateFailed =>
      'Favoriten konnten nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get libraryFavoriteRemoveFailed =>
      'Der Favorit konnte nicht entfernt werden. Bitte versuche es erneut.';

  @override
  String get libraryHistorySyncLater =>
      'Dein Verlauf wird später erneut synchronisiert.';

  @override
  String get libraryHistoryDeleteFailed =>
      'Der Wiedergabeverlauf konnte nicht gelöscht werden. Bitte versuche es erneut.';

  @override
  String get profileEdit => 'Profil bearbeiten';

  @override
  String get profileChangePhoto => 'Foto ändern';

  @override
  String get profileName => 'Name';

  @override
  String get profileNameDescription =>
      'Dieser Name wird in deinem Liquid-Phim-Profil angezeigt.';

  @override
  String get profileNameHint => 'Anzeigenamen eingeben';

  @override
  String get profileClearName => 'Name löschen';

  @override
  String get profileEmailDescription =>
      'Diese E-Mail-Adresse ist mit deinem Konto verknüpft und wird nur hier angezeigt.';

  @override
  String get profileChangeAvatar => 'Profilfoto ändern';

  @override
  String get profileTakePhoto => 'Foto aufnehmen';

  @override
  String get profileUploadPhoto => 'Foto hochladen';

  @override
  String get profileViewPhoto => 'Foto ansehen';

  @override
  String get profileAvatar => 'Profilfoto';

  @override
  String get profileCropAvatar => 'Profilfoto zuschneiden';

  @override
  String get profileAvatarUpdated => 'Profilfoto aktualisiert.';

  @override
  String get profileAvatarUpdateFailed =>
      'Das Profilfoto konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get profilePhotoOpenFailed =>
      'Das Foto konnte nicht geöffnet werden. Prüfe die Berechtigung für den Fotozugriff.';

  @override
  String get profileNameUpdated => 'Anzeigename aktualisiert.';

  @override
  String get profileNameUpdateFailed =>
      'Der Name konnte nicht aktualisiert werden. Bitte versuche es erneut.';

  @override
  String get profileNameRequired => 'Der Name darf nicht leer sein.';

  @override
  String get profileUpdatedProfileReadFailed =>
      'Das aktualisierte Profil konnte nicht gelesen werden.';

  @override
  String get detailCastUnavailable =>
      'Besetzungsinformationen sind nicht verfügbar';

  @override
  String get detailCast => 'Besetzung';

  @override
  String get detailRecommendationsLoadFailed =>
      'Empfehlungen konnten nicht geladen werden';

  @override
  String get detailNoRecommendations => 'Keine Empfehlungen';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'Episode $episode ist auf dem aktuellen Server nicht verfügbar.';
  }

  @override
  String get detailNoEpisodes => 'Keine Episoden verfügbar';

  @override
  String get detailWatchThisVersion => 'Diese Version ansehen';

  @override
  String get detailServer => 'Server';

  @override
  String detailServerNumber(int number) {
    return 'Server $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'Episoden 1–$count';
  }

  @override
  String get detailEnterEpisode => 'Episode eingeben';

  @override
  String get detailLoadMovieError => 'Film konnte nicht geladen werden';

  @override
  String get detailEpisodesTab => 'Episoden';

  @override
  String get detailRecommendationsTab => 'Empfehlungen';

  @override
  String get detailCommentsTab => 'Kommentare';

  @override
  String get detailInTheaters => 'Im Kino';

  @override
  String get detailExclusiveSubtitles => 'Exklusive Untertitel';

  @override
  String get detailDirectorLabel => 'Regie:';

  @override
  String get detailCreatedDateLabel => 'Hinzugefügt am:';

  @override
  String get detailProductionYearLabel => 'Produktionsjahr:';

  @override
  String get detailCountryLabel => 'Land:';

  @override
  String get detailWatchLatestEpisode => 'Neueste Episode ansehen';

  @override
  String get detailWatchMovie => 'Film ansehen';

  @override
  String get detailIntroduction => 'Übersicht';

  @override
  String get detailFavorite => 'Favorit';

  @override
  String get detailContent => 'Handlung';

  @override
  String get detailNoPlayableEpisodes =>
      'Dieser Film hat noch keine abspielbaren Episoden. Bitte versuche es später erneut.';

  @override
  String get detailDetails => 'Details';

  @override
  String get detailVideoQuality => 'Videoqualität';

  @override
  String detailViews(String count) {
    return '$count Aufrufe';
  }

  @override
  String detailLikes(String count) {
    return '$count Likes';
  }

  @override
  String get detailUpdatedJustNow => 'Gerade aktualisiert';

  @override
  String get playerSubtitleServer => 'Untertitelt';

  @override
  String get playerNowPlaying => 'Wird jetzt abgespielt';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'Wird jetzt abgespielt: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable =>
      'Auf diesem Server ist keine abspielbare Quelle verfügbar.';

  @override
  String get playerSourceLoadFailed =>
      'Diese Filmquelle konnte nicht geladen werden.';

  @override
  String get playerAutoplayEnabled => 'Automatische Wiedergabe aktiviert';

  @override
  String get playerAutoplayDisabled => 'Automatische Wiedergabe deaktiviert';

  @override
  String get playerNoMoreEpisodes => 'Du hast die letzte Episode erreicht';

  @override
  String get playerFirstEpisode => 'Dies ist die erste Episode';

  @override
  String get playerPlaybackFailed =>
      'Das Video konnte nicht abgespielt werden. Bitte versuche es erneut.';

  @override
  String get playerPlay => 'Wiedergabe';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPullDownToCloseComments =>
      'Nach unten ziehen, um Kommentare zu schließen';

  @override
  String get playerPlayOnTv => 'Auf TV abspielen';

  @override
  String get playerEpisodeList => 'Episodenliste';

  @override
  String get playerVideoProgress => 'Videofortschritt';

  @override
  String get playerClose => 'Player schließen';

  @override
  String get playerContinueWatchingTitle => 'Weiterschauen?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'Du hast $episode angesehen. Möchtest du fortfahren oder ab Episode 1 neu starten?';
  }

  @override
  String get playerRestartFromBeginning => 'Von vorne beginnen';

  @override
  String get playerContinue => 'Fortsetzen';

  @override
  String get commentsReply => 'Antworten';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Antworten',
      one: '1 Antwort',
      zero: 'Keine Antworten',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle =>
      'Kommentare konnten nicht geladen werden';

  @override
  String get commentsEmptyTitle => 'Noch keine Kommentare';

  @override
  String get commentsEmptySubtitle =>
      'Teile als Erste oder Erster deine Meinung.';

  @override
  String get commentsEditHint => 'Kommentar bearbeiten...';

  @override
  String commentsReplyToHint(String name) {
    return 'Auf $name antworten...';
  }

  @override
  String get commentsAddReplyHint => 'Antwort hinzufügen...';

  @override
  String get commentsComposerHint => 'Kommentar schreiben...';

  @override
  String get commentsEditingStatus => 'Kommentar wird bearbeitet';

  @override
  String commentsReplyingStatus(String name) {
    return 'Antwort an $name';
  }

  @override
  String get commentsWrite => 'Kommentar schreiben';

  @override
  String get commentsSend => 'Senden';

  @override
  String get commentsCloseMenu => 'Kommentarmenü schließen';

  @override
  String get commentsCopied => 'Kommentar kopiert';

  @override
  String get commentsYourComment => 'Dein Kommentar';

  @override
  String get commentsReportReasonTitle => 'Warum meldest du diesen Kommentar?';

  @override
  String get commentsReportSent => 'Meldung gesendet. Danke.';

  @override
  String get commentsDeleteTitle => 'Kommentar löschen?';

  @override
  String get commentsRepliesPreserved => 'Antworten bleiben erhalten.';

  @override
  String get commentsDeleteAction => 'Kommentar löschen';

  @override
  String get commentsSortTitle => 'Kommentare sortieren';

  @override
  String get commentsPopular => 'Beliebt';

  @override
  String get commentsNewest => 'Neueste';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kommentare',
      one: '1 Kommentar',
      zero: 'Kommentare',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'Kommentar kopieren';

  @override
  String get commentsEdited => 'Bearbeitet';

  @override
  String get commentsDeleted => 'Kommentar gelöscht';

  @override
  String get commentsJustNow => 'gerade eben';

  @override
  String commentsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Minuten',
      one: 'vor 1 Minute',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Stunden',
      one: 'vor 1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String commentsWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Wochen',
      one: 'vor 1 Woche',
    );
    return '$_temp0';
  }

  @override
  String commentsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Monaten',
      one: 'vor 1 Monat',
    );
    return '$_temp0';
  }

  @override
  String commentsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Jahren',
      one: 'vor 1 Jahr',
    );
    return '$_temp0';
  }

  @override
  String get commentsSpamReason => 'Spam';

  @override
  String get commentsHarassmentReason => 'Belästigung oder Missbrauch';

  @override
  String get commentsSpoilerReason => 'Film-Spoiler';

  @override
  String get commentsInappropriateReason => 'Unangemessener Inhalt';

  @override
  String get commentsOtherReason => 'Anderer Grund';

  @override
  String get commentsLoadFailed =>
      'Kommentare konnten nicht geladen werden. Bitte versuche es erneut.';

  @override
  String get commentsLoadMoreFailed =>
      'Weitere Kommentare konnten nicht geladen werden.';

  @override
  String get commentsRepliesLoadFailed =>
      'Antworten konnten nicht geladen werden.';

  @override
  String get commentsRepliesLoadMoreFailed =>
      'Weitere Antworten konnten nicht geladen werden.';

  @override
  String get commentsSendFailed =>
      'Der Kommentar konnte nicht gesendet werden. Dein Text wurde beibehalten.';

  @override
  String get commentsEditFailed =>
      'Der Kommentar konnte nicht bearbeitet werden.';

  @override
  String get commentsDeleteFailed =>
      'Der Kommentar konnte nicht gelöscht werden.';

  @override
  String get commentsReactionFailed =>
      'Die Reaktion konnte nicht aktualisiert werden.';

  @override
  String get commentsReportFailed =>
      'Dieser Kommentar wurde bereits gemeldet oder die Meldung konnte nicht gesendet werden.';

  @override
  String get commentsOperationInProgress =>
      'Diese Aktion wird bereits ausgeführt.';

  @override
  String get notificationsEmpty => 'Keine neuen Benachrichtigungen';

  @override
  String get notificationsRepliedToYourComment =>
      'hat auf deinen Kommentar geantwortet';

  @override
  String get notificationsLikedYourComment => 'gefällt dein Kommentar';

  @override
  String get notificationsToday => 'Heute';

  @override
  String get notificationsYesterday => 'Gestern';

  @override
  String get notificationsUnknownUser => 'Jemand';

  @override
  String get notificationsNewMovieTitle => 'Neuer Film';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count neue Filme';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName wurde gerade zu Liquid Phim hinzugefügt.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Benachrichtigungen, wenn Liquid Phim neue Filme entdeckt';

  @override
  String get castChooseDevice => 'Gerät auswählen';

  @override
  String get castAirPlayUnavailableTitle =>
      'AirPlay konnte nicht geöffnet werden';

  @override
  String get castAirPlayUnavailableBody =>
      'Stelle sicher, dass sich dein iPhone und dein TV oder Mac im selben WLAN befinden, und versuche es erneut.';

  @override
  String get castVideoUnavailableTitle => 'Kein Video verfügbar';

  @override
  String get castVideoUnavailableBody =>
      'Warte, bis das Video geladen ist, und wähle dann ein Google-Cast-Gerät aus.';

  @override
  String get castConnectionFailedTitle =>
      'Verbindung mit Google Cast fehlgeschlagen';

  @override
  String get castConnectionFailedBody =>
      'Prüfe die Google Play-Dienste und stelle sicher, dass sich dein Telefon und Chromecast oder Google TV im selben WLAN befinden.';

  @override
  String get castAirPlayAndBluetoothDevices => 'AirPlay- und Bluetooth-Geräte';

  @override
  String get castConnecting => 'Verbindung wird hergestellt...';

  @override
  String get castSearching => 'Google-Cast-Geräte werden gesucht...';

  @override
  String get castNoDevices => 'Keine Geräte gefunden';

  @override
  String get castSameWifiGuidance =>
      'Stelle sicher, dass sich dein Telefon und Chromecast oder Google TV im selben WLAN befinden.';

  @override
  String get castSearchAgain => 'Erneut suchen';

  @override
  String get castDefaultDeviceName => 'Google-Cast-Gerät';

  @override
  String shareMovieSubject(String movieName) {
    return '$movieName auf Liquid Phim ansehen';
  }

  @override
  String get shareOpenFailed => 'Das Teilen-Menü konnte nicht geöffnet werden.';

  @override
  String get rankingTopFavorites => 'TOP-Lieblingsfilme';

  @override
  String get rankingTopLiquidPhim => 'Liquid Phim TOP 30';

  @override
  String get rankingTopHotMovies => 'TOP 30 angesagte Filme';

  @override
  String get rankingMostViewed => 'MEISTGESEHEN';

  @override
  String get rankingMostLiked => 'MEISTGELIKT';

  @override
  String get rankingEmptyLikes =>
      'Die Rangliste wird angezeigt, sobald Filme Likes erhalten.';

  @override
  String get rankingEmptyViews =>
      'Die Rangliste wird angezeigt, sobald Filme Aufrufe erhalten.';

  @override
  String get rankingLoadFailed => 'Die Rangliste konnte nicht geladen werden.';

  @override
  String playerEpisodeNumber(int number) {
    return 'Episode $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'Monat $month';
  }
}
