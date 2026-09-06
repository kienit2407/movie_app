// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'Des films à tout moment, partout';

  @override
  String get commonAgree => 'OK';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonClose => 'Fermer';

  @override
  String get commonDone => 'Terminé';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonReport => 'Signaler';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get commonAll => 'Tous';

  @override
  String get commonSeeMore => 'Voir plus';

  @override
  String get commonCollapse => 'Voir moins';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonUpdating => 'Mise à jour';

  @override
  String get commonUnderstood => 'Compris';

  @override
  String get commonNoData => 'Aucune donnée';

  @override
  String get commonNotAvailable => 'N/D';

  @override
  String get commonWarningTitle => 'Avertissement';

  @override
  String get commonNoticeTitle => 'Information';

  @override
  String get commonCongratulationsTitle => 'Félicitations !';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonGoHome => 'Aller à l\'accueil';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments sélectionnés',
      one: '1 élément sélectionné',
      zero: 'Aucune sélection',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'Erreur : $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours heures',
      one: '1 heure',
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
  String get settingsLanguage => 'Langue';

  @override
  String get settingsLanguageSystem => 'Utiliser la langue de l\'appareil';

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
  String get settingsTitle => 'Paramètres';

  @override
  String get settingsGeneralSection => 'Général';

  @override
  String get settingsAppLanguage => 'Langue de l\'application';

  @override
  String get settingsAccountSection => 'Compte';

  @override
  String get settingsSwitchAccount => 'Changer de compte';

  @override
  String get settingsAddAccount => 'Ajouter un compte';

  @override
  String get settingsAccountSwitchFailed =>
      'Impossible de changer de compte. Veuillez vous reconnecter à ce compte.';

  @override
  String get settingsSignOutFailed =>
      'Impossible de vous déconnecter. Veuillez réessayer.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSearch => 'Rechercher';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navProfile => 'Profil';

  @override
  String get navNotifications => 'Notifications';

  @override
  String get internetOffline => 'Aucune connexion Internet';

  @override
  String get internetBackOnline => 'Connexion rétablie';

  @override
  String get authJoinMember => 'Rejoindre en tant que membre';

  @override
  String get authSignInTitle => 'Se connecter à Liquid Phim';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authSignInFailed => 'La connexion a échoué. Veuillez réessayer.';

  @override
  String get authSignInToComment =>
      'Connectez-vous pour commenter et interagir avec la communauté.';

  @override
  String get authGoogleSyncDescription =>
      'Continuez avec Google pour synchroniser votre compte et rejoindre la communauté.';

  @override
  String get authGoogleConsent =>
      'En continuant, vous acceptez d\'utiliser votre compte Google avec Liquid Phim.';

  @override
  String get authContinueWithGoogle => 'Continuer avec Google';

  @override
  String get authGoogleSignInFailed =>
      'Impossible de se connecter avec Google. Veuillez réessayer.';

  @override
  String get authGoogleSignInCheckFailed =>
      'Impossible de se connecter avec Google. Vérifiez votre connexion et réessayez.';

  @override
  String get authSessionUpdateFailed =>
      'Impossible de mettre à jour votre session de connexion.';

  @override
  String get authLoginRequired => 'Vous devez vous connecter.';

  @override
  String get authLoginRequiredForAction =>
      'Vous devez vous connecter pour effectuer cette action.';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authFullName => 'Nom complet';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authOrContinueWith => 'Ou continuer avec';

  @override
  String get authAlreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get authFullNameRequired => 'Le nom complet ne peut pas être vide.';

  @override
  String get authFullNameLength =>
      'Le nom complet doit contenir entre 3 et 15 caractères.';

  @override
  String get authEmailRequired => 'L\'adresse e-mail ne peut pas être vide.';

  @override
  String get authEmailInvalid => 'Saisissez une adresse e-mail valide.';

  @override
  String get authPasswordRequired => 'Le mot de passe ne peut pas être vide.';

  @override
  String get authPasswordLength =>
      'Le mot de passe doit contenir entre 6 et 15 caractères.';

  @override
  String get authAccountAlreadyExists =>
      'Ce compte existe déjà. Veuillez choisir une autre adresse e-mail.';

  @override
  String get authWeakPassword =>
      'Ce mot de passe est trop faible. Saisissez un mot de passe plus robuste.';

  @override
  String get authInvalidCredentials =>
      'L\'adresse e-mail ou le mot de passe est incorrect. Veuillez réessayer.';

  @override
  String get authUnexpectedError =>
      'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get authSignUpFailed =>
      'Impossible de créer votre compte. Veuillez réessayer.';

  @override
  String get authSignUpSucceeded => 'Votre compte a été créé.';

  @override
  String get authSignInSucceeded => 'Connexion réussie.';

  @override
  String get authSignOutSucceeded => 'Déconnexion réussie.';

  @override
  String get authTokenConfirmed => 'Code de vérification confirmé.';

  @override
  String get authTokenInvalid => 'Le code de vérification est incorrect.';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      'Recevoir les notifications de nouveaux films ?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim peut effectuer des vérifications périodiques en arrière-plan et vous avertir lorsque de nouveaux films sont trouvés. Le système d\'exploitation peut retarder les vérifications de plus de 20 minutes pour économiser la batterie.';

  @override
  String get homeEnableNotifications => 'Activer les notifications';

  @override
  String get homeDoNotEnable => 'Pas maintenant';

  @override
  String get homeNotificationPermissionDisabled =>
      'L\'autorisation des notifications est désactivée. Vous pouvez la réactiver dans les paramètres de votre téléphone.';

  @override
  String get homeLoadMoviesFailed =>
      'Impossible de charger les films.\nTirez vers le bas pour réessayer.';

  @override
  String get homeRecommended => 'Recommandé';

  @override
  String get homeGenres => 'Genres';

  @override
  String get homeCountries => 'Pays';

  @override
  String get homeYear => 'Année';

  @override
  String get homeFreshMovies => 'Nouvelles sorties !';

  @override
  String get homeKoreanMovies => 'Films coréens';

  @override
  String get homeChineseMovies => 'Films chinois';

  @override
  String get homeUsUkMovies => 'Films américains et britanniques';

  @override
  String get homeWatchMovie => 'Regarder';

  @override
  String get homeInformation => 'Infos';

  @override
  String get homeViewAll => 'Tout voir';

  @override
  String get homeWhatToWatch => 'Que souhaitez-vous regarder aujourd\'hui ?';

  @override
  String get homeViewMore => 'Voir plus';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'Version : $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'Type de film';

  @override
  String get filterSeries => 'Séries';

  @override
  String get filterSingleMovies => 'Films';

  @override
  String get filterAnimation => 'Animation';

  @override
  String get filterTvShows => 'Émissions TV';

  @override
  String get filterSubtitled => 'Sous-titré';

  @override
  String get filterVoiceOver => 'Voix off';

  @override
  String get filterDubbed => 'Doublé';

  @override
  String get filterChooseMovieType => 'Veuillez sélectionner un type de film.';

  @override
  String get filterChooseGenre => 'Veuillez sélectionner un genre.';

  @override
  String get filterChooseCountry => 'Sélectionnez un pays pour filtrer.';

  @override
  String get filterChooseYear => 'Sélectionnez une année pour filtrer.';

  @override
  String get filterLanguage => 'Langue';

  @override
  String get filterSortBy => 'Trier par';

  @override
  String get filterSortDirection => 'Sens du tri';

  @override
  String get filterDescending => 'Décroissant';

  @override
  String get filterAscending => 'Croissant';

  @override
  String get filterMostViewed => 'Les plus vus';

  @override
  String get filterNewest => 'Les plus récents';

  @override
  String get filterReleaseYear => 'Année de sortie';

  @override
  String get filterApply => 'Appliquer les filtres';

  @override
  String get filterResults => 'Filtrer les résultats';

  @override
  String get searchAttentionTitle => 'Attention';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'Saisissez un mot-clé avant de filtrer les films.';

  @override
  String get searchNoResults => 'Aucun résultat trouvé';

  @override
  String get searchMovieActorHint => 'Rechercher des films, des acteurs...';

  @override
  String get searchFilterTooltip => 'Filtres de recherche';

  @override
  String get searchStartPrompt =>
      'Saisissez un titre de film pour commencer la recherche';

  @override
  String get searchRecent => 'Recherches récentes';

  @override
  String get searchLoadingGenres => 'Chargement des genres...';

  @override
  String get searchLoadingCountries => 'Chargement des pays...';

  @override
  String get searchNoMovies => 'Aucun film';

  @override
  String get searchTryDifferentFilters => 'Essayez d\'autres filtres';

  @override
  String get librarySignOutTitle => 'Se déconnecter ?';

  @override
  String get librarySignOutConfirmation =>
      'Voulez-vous vraiment vous déconnecter de ce compte ?';

  @override
  String get librarySignOut => 'Se déconnecter';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer les $count films sélectionnés ?',
      one: 'Supprimer le film sélectionné ?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle =>
      'Supprimer ce film de l\'historique ?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimer $count films de l\'historique de visionnage ?',
      one: 'Supprimer ce film de l\'historique de visionnage ?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle => 'Retirer ce film des favoris ?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Retirer $count films des favoris ?',
      one: 'Retirer ce film des favoris ?',
    );
    return '$_temp0';
  }

  @override
  String get libraryCancelSelection => 'Annuler la sélection';

  @override
  String get libraryDeleteSelectedMovies => 'Supprimer les films sélectionnés';

  @override
  String get libraryCannotResumeMovie =>
      'Impossible de reprendre ce film pour le moment.';

  @override
  String get libraryYourProfile => 'Votre profil';

  @override
  String get librarySignInProfileDescription =>
      'Connectez-vous pour modifier votre profil et synchroniser votre historique de visionnage.';

  @override
  String get libraryWatchHistory => 'Historique de visionnage';

  @override
  String get libraryNoWatchHistory =>
      'Aucun historique de visionnage pour le moment';

  @override
  String get libraryFavorites => 'Favoris';

  @override
  String get librarySignInToSaveFavorites =>
      'Connectez-vous pour enregistrer vos films favoris';

  @override
  String get libraryFavoritesSyncDescription =>
      'Votre liste sera synchronisée sur tous vos appareils.';

  @override
  String get libraryNoFavorites => 'Aucun film favori pour le moment';

  @override
  String get libraryRemoveFromList => 'Retirer de la liste';

  @override
  String libraryContinueProgress(int progress) {
    return 'Continuer à $progress %';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed =>
      'Impossible de charger votre bibliothèque. Veuillez réessayer.';

  @override
  String get libraryFavoriteUpdateFailed =>
      'Impossible de mettre à jour les favoris. Veuillez réessayer.';

  @override
  String get libraryFavoriteRemoveFailed =>
      'Impossible de retirer ce favori. Veuillez réessayer.';

  @override
  String get libraryHistorySyncLater =>
      'Votre historique sera synchronisé à nouveau ultérieurement.';

  @override
  String get libraryHistoryDeleteFailed =>
      'Impossible de supprimer l\'historique de visionnage. Veuillez réessayer.';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileChangePhoto => 'Changer la photo';

  @override
  String get profileName => 'Nom';

  @override
  String get profileNameDescription =>
      'Ce nom apparaîtra sur votre profil Liquid Phim.';

  @override
  String get profileNameHint => 'Saisissez un nom d\'affichage';

  @override
  String get profileClearName => 'Effacer le nom';

  @override
  String get profileEmailDescription =>
      'Cette adresse e-mail est liée à votre compte et n\'est affichée qu\'ici.';

  @override
  String get profileChangeAvatar => 'Changer la photo de profil';

  @override
  String get profileTakePhoto => 'Prendre une photo';

  @override
  String get profileUploadPhoto => 'Importer une photo';

  @override
  String get profileViewPhoto => 'Voir la photo';

  @override
  String get profileAvatar => 'Photo de profil';

  @override
  String get profileCropAvatar => 'Recadrer la photo de profil';

  @override
  String get profileAvatarUpdated => 'Photo de profil mise à jour.';

  @override
  String get profileAvatarUpdateFailed =>
      'Impossible de mettre à jour la photo de profil. Veuillez réessayer.';

  @override
  String get profilePhotoOpenFailed =>
      'Impossible d\'ouvrir la photo. Vérifiez l\'autorisation d\'accès aux photos.';

  @override
  String get profileNameUpdated => 'Nom d\'affichage mis à jour.';

  @override
  String get profileNameUpdateFailed =>
      'Impossible de mettre à jour le nom. Veuillez réessayer.';

  @override
  String get profileNameRequired => 'Le nom ne peut pas être vide.';

  @override
  String get profileUpdatedProfileReadFailed =>
      'Impossible de lire le profil mis à jour.';

  @override
  String get detailCastUnavailable =>
      'Les informations sur la distribution ne sont pas disponibles';

  @override
  String get detailCast => 'Distribution';

  @override
  String get detailRecommendationsLoadFailed =>
      'Impossible de charger les recommandations';

  @override
  String get detailNoRecommendations => 'Aucune recommandation';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'L\'épisode $episode n\'est pas disponible sur le serveur actuel.';
  }

  @override
  String get detailNoEpisodes => 'Aucun épisode disponible';

  @override
  String get detailWatchThisVersion => 'Regarder cette version';

  @override
  String get detailServer => 'Serveur';

  @override
  String detailServerNumber(int number) {
    return 'Serveur $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'Épisodes 1–$count';
  }

  @override
  String get detailEnterEpisode => 'Saisir un épisode';

  @override
  String get detailLoadMovieError => 'Impossible de charger le film';

  @override
  String get detailEpisodesTab => 'Épisodes';

  @override
  String get detailRecommendationsTab => 'Recommandations';

  @override
  String get detailCommentsTab => 'Commentaires';

  @override
  String get detailInTheaters => 'Au cinéma';

  @override
  String get detailExclusiveSubtitles => 'Sous-titres exclusifs';

  @override
  String get detailDirectorLabel => 'Réalisateur :';

  @override
  String get detailCreatedDateLabel => 'Ajouté le :';

  @override
  String get detailProductionYearLabel => 'Année de production :';

  @override
  String get detailCountryLabel => 'Pays :';

  @override
  String get detailWatchLatestEpisode => 'Regarder le dernier épisode';

  @override
  String get detailWatchMovie => 'Regarder le film';

  @override
  String get detailIntroduction => 'Aperçu';

  @override
  String get detailFavorite => 'Favori';

  @override
  String get detailContent => 'Synopsis';

  @override
  String get detailNoPlayableEpisodes =>
      'Ce film ne contient encore aucun épisode lisible. Veuillez réessayer plus tard.';

  @override
  String get detailDetails => 'Détails';

  @override
  String get detailVideoQuality => 'Qualité vidéo';

  @override
  String detailViews(String count) {
    return '$count vues';
  }

  @override
  String detailLikes(String count) {
    return '$count J\'aime';
  }

  @override
  String get detailUpdatedJustNow => 'Mis à jour à l\'instant';

  @override
  String get playerSubtitleServer => 'Sous-titré';

  @override
  String get playerNowPlaying => 'Lecture en cours';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'Lecture en cours : $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable =>
      'Ce serveur ne dispose d\'aucune source lisible.';

  @override
  String get playerSourceLoadFailed =>
      'Impossible de charger cette source vidéo.';

  @override
  String get playerAutoplayEnabled => 'Lecture automatique activée';

  @override
  String get playerAutoplayDisabled => 'Lecture automatique désactivée';

  @override
  String get playerNoMoreEpisodes => 'Vous avez atteint le dernier épisode';

  @override
  String get playerFirstEpisode => 'Ceci est le premier épisode';

  @override
  String get playerPlaybackFailed =>
      'Impossible de lire la vidéo. Veuillez réessayer.';

  @override
  String get playerPlay => 'Lire';

  @override
  String get playerPause => 'Pause';

  @override
  String get playerPullDownToCloseComments =>
      'Tirez vers le bas pour fermer les commentaires';

  @override
  String get playerPlayOnTv => 'Lire sur la TV';

  @override
  String get playerEpisodeList => 'Liste des épisodes';

  @override
  String get playerVideoProgress => 'Progression de la vidéo';

  @override
  String get playerClose => 'Fermer le lecteur';

  @override
  String get playerContinueWatchingTitle => 'Continuer à regarder ?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'Vous regardiez $episode. Voulez-vous continuer ou recommencer à partir de l\'épisode 1 ?';
  }

  @override
  String get playerRestartFromBeginning => 'Recommencer depuis le début';

  @override
  String get playerContinue => 'Continuer';

  @override
  String get commentsReply => 'Répondre';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count réponses',
      one: '1 réponse',
      zero: 'Aucune réponse',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle =>
      'Impossible de charger les commentaires';

  @override
  String get commentsEmptyTitle => 'Aucun commentaire pour le moment';

  @override
  String get commentsEmptySubtitle =>
      'Soyez la première personne à partager votre avis.';

  @override
  String get commentsEditHint => 'Modifier le commentaire...';

  @override
  String commentsReplyToHint(String name) {
    return 'Répondre à $name...';
  }

  @override
  String get commentsAddReplyHint => 'Ajouter une réponse...';

  @override
  String get commentsComposerHint => 'Écrire un commentaire...';

  @override
  String get commentsEditingStatus => 'Modification du commentaire';

  @override
  String commentsReplyingStatus(String name) {
    return 'Réponse à $name';
  }

  @override
  String get commentsWrite => 'Écrire un commentaire';

  @override
  String get commentsSend => 'Envoyer';

  @override
  String get commentsCloseMenu => 'Fermer le menu du commentaire';

  @override
  String get commentsCopied => 'Commentaire copié';

  @override
  String get commentsYourComment => 'Votre commentaire';

  @override
  String get commentsReportReasonTitle =>
      'Pourquoi signalez-vous ce commentaire ?';

  @override
  String get commentsReportSent => 'Signalement envoyé. Merci.';

  @override
  String get commentsDeleteTitle => 'Supprimer le commentaire ?';

  @override
  String get commentsRepliesPreserved => 'Les réponses seront conservées.';

  @override
  String get commentsDeleteAction => 'Supprimer le commentaire';

  @override
  String get commentsSortTitle => 'Trier les commentaires';

  @override
  String get commentsPopular => 'Populaires';

  @override
  String get commentsNewest => 'Plus récents';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count commentaires',
      one: '1 commentaire',
      zero: 'Commentaires',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'Copier le commentaire';

  @override
  String get commentsEdited => 'Modifié';

  @override
  String get commentsDeleted => 'Commentaire supprimé';

  @override
  String get commentsJustNow => 'à l\'instant';

  @override
  String commentsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count minutes',
      one: 'il y a 1 minute',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count heures',
      one: 'il y a 1 heure',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String commentsWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count semaines',
      one: 'il y a 1 semaine',
    );
    return '$_temp0';
  }

  @override
  String commentsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count mois',
      one: 'il y a 1 mois',
    );
    return '$_temp0';
  }

  @override
  String commentsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count ans',
      one: 'il y a 1 an',
    );
    return '$_temp0';
  }

  @override
  String get commentsSpamReason => 'Spam';

  @override
  String get commentsHarassmentReason => 'Harcèlement ou abus';

  @override
  String get commentsSpoilerReason => 'Spoiler de film';

  @override
  String get commentsInappropriateReason => 'Contenu inapproprié';

  @override
  String get commentsOtherReason => 'Autre raison';

  @override
  String get commentsLoadFailed =>
      'Impossible de charger les commentaires. Veuillez réessayer.';

  @override
  String get commentsLoadMoreFailed =>
      'Impossible de charger davantage de commentaires.';

  @override
  String get commentsRepliesLoadFailed => 'Impossible de charger les réponses.';

  @override
  String get commentsRepliesLoadMoreFailed =>
      'Impossible de charger davantage de réponses.';

  @override
  String get commentsSendFailed =>
      'Impossible d\'envoyer le commentaire. Votre texte a été conservé.';

  @override
  String get commentsEditFailed => 'Impossible de modifier le commentaire.';

  @override
  String get commentsDeleteFailed => 'Impossible de supprimer le commentaire.';

  @override
  String get commentsReactionFailed =>
      'Impossible de mettre à jour la réaction.';

  @override
  String get commentsReportFailed =>
      'Ce commentaire a déjà été signalé ou le signalement n\'a pas pu être envoyé.';

  @override
  String get commentsOperationInProgress => 'Cette action est déjà en cours.';

  @override
  String get notificationsEmpty => 'Aucune nouvelle notification';

  @override
  String get notificationsRepliedToYourComment =>
      'a répondu à votre commentaire';

  @override
  String get notificationsLikedYourComment => 'a aimé votre commentaire';

  @override
  String get notificationsToday => 'Aujourd\'hui';

  @override
  String get notificationsYesterday => 'Hier';

  @override
  String get notificationsUnknownUser => 'Quelqu\'un';

  @override
  String get notificationsNewMovieTitle => 'Nouveau film';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count nouveaux films';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName vient d\'être ajouté à Liquid Phim.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Notifications lorsque Liquid Phim découvre de nouveaux films';

  @override
  String get castChooseDevice => 'Choisir un appareil';

  @override
  String get castAirPlayUnavailableTitle => 'Impossible d\'ouvrir AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      'Assurez-vous que votre iPhone et votre TV ou Mac sont connectés au même réseau Wi-Fi, puis réessayez.';

  @override
  String get castVideoUnavailableTitle => 'Aucune vidéo disponible';

  @override
  String get castVideoUnavailableBody =>
      'Attendez que la vidéo soit chargée, puis choisissez un appareil Google Cast.';

  @override
  String get castConnectionFailedTitle =>
      'Impossible de se connecter à Google Cast';

  @override
  String get castConnectionFailedBody =>
      'Vérifiez les services Google Play et assurez-vous que votre téléphone et votre Chromecast ou Google TV sont connectés au même réseau Wi-Fi.';

  @override
  String get castAirPlayAndBluetoothDevices => 'Appareils AirPlay et Bluetooth';

  @override
  String get castConnecting => 'Connexion...';

  @override
  String get castSearching => 'Recherche d\'appareils Google Cast...';

  @override
  String get castNoDevices => 'Aucun appareil trouvé';

  @override
  String get castSameWifiGuidance =>
      'Assurez-vous que votre téléphone et votre Chromecast ou Google TV sont connectés au même réseau Wi-Fi.';

  @override
  String get castSearchAgain => 'Rechercher à nouveau';

  @override
  String get castDefaultDeviceName => 'Appareil Google Cast';

  @override
  String shareMovieSubject(String movieName) {
    return 'Regarder $movieName sur Liquid Phim';
  }

  @override
  String get shareOpenFailed => 'Impossible d\'ouvrir la feuille de partage.';

  @override
  String get rankingTopFavorites => 'TOP des films favoris';

  @override
  String get rankingTopLiquidPhim => 'TOP 30 Liquid Phim';

  @override
  String get rankingTopHotMovies => 'TOP 30 des films populaires';

  @override
  String get rankingMostViewed => 'LES PLUS VUS';

  @override
  String get rankingMostLiked => 'LES PLUS AIMÉS';

  @override
  String get rankingEmptyLikes =>
      'Le classement apparaîtra lorsque les films auront reçu des mentions J\'aime.';

  @override
  String get rankingEmptyViews =>
      'Le classement apparaîtra lorsque les films auront reçu des vues.';

  @override
  String get rankingLoadFailed => 'Impossible de charger le classement.';

  @override
  String playerEpisodeNumber(int number) {
    return 'Épisode $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'Mois $month';
  }
}
