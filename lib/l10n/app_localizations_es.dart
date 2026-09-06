// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'Películas en cualquier momento y lugar';

  @override
  String get commonAgree => 'Aceptar';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get commonDone => 'Listo';

  @override
  String get commonSave => 'Guardar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonEdit => 'Editar';

  @override
  String get commonReport => 'Reportar';

  @override
  String get commonRetry => 'Intentar de nuevo';

  @override
  String get commonReset => 'Restablecer';

  @override
  String get commonAll => 'Todos';

  @override
  String get commonSeeMore => 'Ver más';

  @override
  String get commonCollapse => 'Ver menos';

  @override
  String get commonLoading => 'Cargando...';

  @override
  String get commonUpdating => 'Actualizando';

  @override
  String get commonUnderstood => 'Entendido';

  @override
  String get commonNoData => 'Sin datos';

  @override
  String get commonNotAvailable => 'N/D';

  @override
  String get commonWarningTitle => 'Advertencia';

  @override
  String get commonNoticeTitle => 'Aviso';

  @override
  String get commonCongratulationsTitle => '¡Felicidades!';

  @override
  String get commonBack => 'Atrás';

  @override
  String get commonGoHome => 'Ir al inicio';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
      zero: 'Nada seleccionado',
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
      other: '$hours horas',
      one: '1 hora',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '1 minuto',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get settingsLanguageSystem => 'Usar el idioma del dispositivo';

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
  String get settingsTitle => 'Configuración';

  @override
  String get settingsGeneralSection => 'General';

  @override
  String get settingsAppLanguage => 'Idioma de la aplicación';

  @override
  String get settingsAccountSection => 'Cuenta';

  @override
  String get settingsSwitchAccount => 'Cambiar de cuenta';

  @override
  String get settingsAddAccount => 'Añadir cuenta';

  @override
  String get settingsAccountSwitchFailed =>
      'No se pudo cambiar de cuenta. Vuelve a iniciar sesión en esa cuenta.';

  @override
  String get settingsSignOutFailed =>
      'No se pudo cerrar sesión. Inténtalo de nuevo.';

  @override
  String get navHome => 'Inicio';

  @override
  String get navSearch => 'Buscar';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navProfile => 'Perfil';

  @override
  String get navNotifications => 'Notificaciones';

  @override
  String get internetOffline => 'Sin conexión a Internet';

  @override
  String get internetBackOnline => 'Conexión restablecida';

  @override
  String get authJoinMember => 'Unirse como miembro';

  @override
  String get authSignInTitle => 'Inicia sesión en Liquid Phim';

  @override
  String get authSignIn => 'Iniciar sesión';

  @override
  String get authSignInFailed =>
      'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get authSignInToComment =>
      'Inicia sesión para comentar e interactuar con la comunidad.';

  @override
  String get authGoogleSyncDescription =>
      'Continúa con Google para sincronizar tu cuenta y unirte a la comunidad.';

  @override
  String get authGoogleConsent =>
      'Al continuar, aceptas usar tu cuenta de Google con Liquid Phim.';

  @override
  String get authContinueWithGoogle => 'Continuar con Google';

  @override
  String get authGoogleSignInFailed =>
      'No se pudo iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get authGoogleSignInCheckFailed =>
      'No se pudo iniciar sesión con Google. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get authSessionUpdateFailed => 'No se pudo actualizar tu sesión.';

  @override
  String get authLoginRequired => 'Debes iniciar sesión.';

  @override
  String get authLoginRequiredForAction =>
      'Debes iniciar sesión para realizar esta acción.';

  @override
  String get authEmail => 'Correo electrónico';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authFullName => 'Nombre completo';

  @override
  String get authForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get authOrContinueWith => 'O continuar con';

  @override
  String get authAlreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get authFullNameRequired => 'El nombre completo no puede estar vacío.';

  @override
  String get authFullNameLength =>
      'El nombre completo debe tener entre 3 y 15 caracteres.';

  @override
  String get authEmailRequired => 'El correo electrónico no puede estar vacío.';

  @override
  String get authEmailInvalid =>
      'Introduce una dirección de correo electrónico válida.';

  @override
  String get authPasswordRequired => 'La contraseña no puede estar vacía.';

  @override
  String get authPasswordLength =>
      'La contraseña debe tener entre 6 y 15 caracteres.';

  @override
  String get authAccountAlreadyExists =>
      'Esta cuenta ya existe. Elige otro correo electrónico.';

  @override
  String get authWeakPassword =>
      'Esta contraseña es demasiado débil. Introduce una contraseña más segura.';

  @override
  String get authInvalidCredentials =>
      'El correo electrónico o la contraseña son incorrectos. Inténtalo de nuevo.';

  @override
  String get authUnexpectedError => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get authSignUpFailed =>
      'No se pudo crear tu cuenta. Inténtalo de nuevo.';

  @override
  String get authSignUpSucceeded => 'Tu cuenta ha sido creada.';

  @override
  String get authSignInSucceeded => 'Sesión iniciada correctamente.';

  @override
  String get authSignOutSucceeded => 'Sesión cerrada correctamente.';

  @override
  String get authTokenConfirmed => 'Código de verificación confirmado.';

  @override
  String get authTokenInvalid => 'El código de verificación es incorrecto.';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      '¿Recibir notificaciones de nuevas películas?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim puede comprobar periódicamente en segundo plano y avisarte cuando encuentre nuevas películas. El sistema operativo puede retrasar las comprobaciones más de 20 minutos para ahorrar batería.';

  @override
  String get homeEnableNotifications => 'Activar notificaciones';

  @override
  String get homeDoNotEnable => 'Ahora no';

  @override
  String get homeNotificationPermissionDisabled =>
      'El permiso de notificaciones está desactivado. Puedes volver a activarlo en la configuración de tu teléfono.';

  @override
  String get homeLoadMoviesFailed =>
      'No se pudieron cargar las películas.\nDesliza hacia abajo para intentarlo de nuevo.';

  @override
  String get homeRecommended => 'Recomendado';

  @override
  String get homeGenres => 'Géneros';

  @override
  String get homeCountries => 'Países';

  @override
  String get homeYear => 'Año';

  @override
  String get homeFreshMovies => '¡Estrenos recientes!';

  @override
  String get homeKoreanMovies => 'Películas coreanas';

  @override
  String get homeChineseMovies => 'Películas chinas';

  @override
  String get homeUsUkMovies => 'Películas de EE. UU. y Reino Unido';

  @override
  String get homeWatchMovie => 'Ver';

  @override
  String get homeInformation => 'Información';

  @override
  String get homeViewAll => 'Ver todo';

  @override
  String get homeWhatToWatch => '¿Qué te gustaría ver hoy?';

  @override
  String get homeViewMore => 'Ver más';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'Versión: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'Tipo de película';

  @override
  String get filterSeries => 'Series';

  @override
  String get filterSingleMovies => 'Películas';

  @override
  String get filterAnimation => 'Animación';

  @override
  String get filterTvShows => 'Programas de TV';

  @override
  String get filterSubtitled => 'Subtitulado';

  @override
  String get filterVoiceOver => 'Voz en off';

  @override
  String get filterDubbed => 'Doblado';

  @override
  String get filterChooseMovieType => 'Selecciona un tipo de película.';

  @override
  String get filterChooseGenre => 'Selecciona un género.';

  @override
  String get filterChooseCountry => 'Selecciona un país para filtrar.';

  @override
  String get filterChooseYear => 'Selecciona un año para filtrar.';

  @override
  String get filterLanguage => 'Idioma';

  @override
  String get filterSortBy => 'Ordenar por';

  @override
  String get filterSortDirection => 'Dirección de ordenación';

  @override
  String get filterDescending => 'Descendente';

  @override
  String get filterAscending => 'Ascendente';

  @override
  String get filterMostViewed => 'Más vistas';

  @override
  String get filterNewest => 'Más recientes';

  @override
  String get filterReleaseYear => 'Año de estreno';

  @override
  String get filterApply => 'Aplicar filtros';

  @override
  String get filterResults => 'Filtrar resultados';

  @override
  String get searchAttentionTitle => 'Atención';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'Introduce una palabra clave antes de filtrar películas.';

  @override
  String get searchNoResults => 'No se encontraron resultados';

  @override
  String get searchMovieActorHint => 'Buscar películas, actores...';

  @override
  String get searchFilterTooltip => 'Filtros de búsqueda';

  @override
  String get searchStartPrompt =>
      'Introduce el título de una película para empezar a buscar';

  @override
  String get searchRecent => 'Búsquedas recientes';

  @override
  String get searchLoadingGenres => 'Cargando géneros...';

  @override
  String get searchLoadingCountries => 'Cargando países...';

  @override
  String get searchNoMovies => 'No hay películas';

  @override
  String get searchTryDifferentFilters => 'Prueba con otros filtros';

  @override
  String get librarySignOutTitle => '¿Cerrar sesión?';

  @override
  String get librarySignOutConfirmation =>
      '¿Seguro que quieres cerrar sesión en esta cuenta?';

  @override
  String get librarySignOut => 'Cerrar sesión';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar las $count películas seleccionadas?',
      one: '¿Eliminar la película seleccionada?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle =>
      '¿Eliminar esta película del historial?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count películas del historial de reproducción?',
      one: '¿Eliminar esta película del historial de reproducción?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle =>
      '¿Eliminar esta película de favoritos?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '¿Eliminar $count películas de favoritos?',
      one: '¿Eliminar esta película de favoritos?',
    );
    return '$_temp0';
  }

  @override
  String get libraryCancelSelection => 'Cancelar selección';

  @override
  String get libraryDeleteSelectedMovies => 'Eliminar películas seleccionadas';

  @override
  String get libraryCannotResumeMovie =>
      'No se puede reanudar esta película ahora mismo.';

  @override
  String get libraryYourProfile => 'Tu perfil';

  @override
  String get librarySignInProfileDescription =>
      'Inicia sesión para editar tu perfil y sincronizar tu historial de reproducción.';

  @override
  String get libraryWatchHistory => 'Historial de reproducción';

  @override
  String get libraryNoWatchHistory => 'Aún no hay historial de reproducción';

  @override
  String get libraryFavorites => 'Favoritos';

  @override
  String get librarySignInToSaveFavorites =>
      'Inicia sesión para guardar películas favoritas';

  @override
  String get libraryFavoritesSyncDescription =>
      'Tu lista se sincronizará en todos tus dispositivos.';

  @override
  String get libraryNoFavorites => 'Aún no hay películas favoritas';

  @override
  String get libraryRemoveFromList => 'Eliminar de la lista';

  @override
  String libraryContinueProgress(int progress) {
    return 'Continuar $progress%';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed =>
      'No se pudo cargar tu biblioteca. Inténtalo de nuevo.';

  @override
  String get libraryFavoriteUpdateFailed =>
      'No se pudieron actualizar los favoritos. Inténtalo de nuevo.';

  @override
  String get libraryFavoriteRemoveFailed =>
      'No se pudo eliminar de favoritos. Inténtalo de nuevo.';

  @override
  String get libraryHistorySyncLater =>
      'Tu historial se volverá a sincronizar más tarde.';

  @override
  String get libraryHistoryDeleteFailed =>
      'No se pudo eliminar el historial de reproducción. Inténtalo de nuevo.';

  @override
  String get profileEdit => 'Editar perfil';

  @override
  String get profileChangePhoto => 'Cambiar foto';

  @override
  String get profileName => 'Nombre';

  @override
  String get profileNameDescription =>
      'Este nombre aparecerá en tu perfil de Liquid Phim.';

  @override
  String get profileNameHint => 'Introduce un nombre para mostrar';

  @override
  String get profileClearName => 'Borrar nombre';

  @override
  String get profileEmailDescription =>
      'Este correo electrónico está vinculado a tu cuenta y solo se muestra aquí.';

  @override
  String get profileChangeAvatar => 'Cambiar foto de perfil';

  @override
  String get profileTakePhoto => 'Tomar foto';

  @override
  String get profileUploadPhoto => 'Subir foto';

  @override
  String get profileViewPhoto => 'Ver foto';

  @override
  String get profileAvatar => 'Foto de perfil';

  @override
  String get profileCropAvatar => 'Recortar foto de perfil';

  @override
  String get profileAvatarUpdated => 'Foto de perfil actualizada.';

  @override
  String get profileAvatarUpdateFailed =>
      'No se pudo actualizar la foto de perfil. Inténtalo de nuevo.';

  @override
  String get profilePhotoOpenFailed =>
      'No se pudo abrir la foto. Comprueba el permiso de acceso a las fotos.';

  @override
  String get profileNameUpdated => 'Nombre para mostrar actualizado.';

  @override
  String get profileNameUpdateFailed =>
      'No se pudo actualizar el nombre. Inténtalo de nuevo.';

  @override
  String get profileNameRequired => 'El nombre no puede estar vacío.';

  @override
  String get profileUpdatedProfileReadFailed =>
      'No se pudo leer el perfil actualizado.';

  @override
  String get detailCastUnavailable =>
      'La información del reparto no está disponible';

  @override
  String get detailCast => 'Reparto';

  @override
  String get detailRecommendationsLoadFailed =>
      'No se pudieron cargar las recomendaciones';

  @override
  String get detailNoRecommendations => 'No hay recomendaciones';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'El episodio $episode no está disponible en el servidor actual.';
  }

  @override
  String get detailNoEpisodes => 'No hay episodios disponibles';

  @override
  String get detailWatchThisVersion => 'Ver esta versión';

  @override
  String get detailServer => 'Servidor';

  @override
  String detailServerNumber(int number) {
    return 'Servidor $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'Episodios 1–$count';
  }

  @override
  String get detailEnterEpisode => 'Introducir episodio';

  @override
  String get detailLoadMovieError => 'No se pudo cargar la película';

  @override
  String get detailEpisodesTab => 'Episodios';

  @override
  String get detailRecommendationsTab => 'Recomendaciones';

  @override
  String get detailCommentsTab => 'Comentarios';

  @override
  String get detailInTheaters => 'En cines';

  @override
  String get detailExclusiveSubtitles => 'Subtítulos exclusivos';

  @override
  String get detailDirectorLabel => 'Director:';

  @override
  String get detailCreatedDateLabel => 'Añadido el:';

  @override
  String get detailProductionYearLabel => 'Año de producción:';

  @override
  String get detailCountryLabel => 'País:';

  @override
  String get detailWatchLatestEpisode => 'Ver el último episodio';

  @override
  String get detailWatchMovie => 'Ver película';

  @override
  String get detailIntroduction => 'Descripción general';

  @override
  String get detailFavorite => 'Favorito';

  @override
  String get detailContent => 'Sinopsis';

  @override
  String get detailNoPlayableEpisodes =>
      'Esta película aún no tiene episodios reproducibles. Inténtalo de nuevo más tarde.';

  @override
  String get detailDetails => 'Detalles';

  @override
  String get detailVideoQuality => 'Calidad de vídeo';

  @override
  String detailViews(String count) {
    return '$count visualizaciones';
  }

  @override
  String detailLikes(String count) {
    return '$count Me gusta';
  }

  @override
  String get detailUpdatedJustNow => 'Actualizado ahora mismo';

  @override
  String get playerSubtitleServer => 'Subtitulado';

  @override
  String get playerNowPlaying => 'Reproduciendo ahora';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'Reproduciendo ahora: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable =>
      'Este servidor no tiene una fuente reproducible.';

  @override
  String get playerSourceLoadFailed =>
      'No se pudo cargar esta fuente de la película.';

  @override
  String get playerAutoplayEnabled => 'Reproducción automática activada';

  @override
  String get playerAutoplayDisabled => 'Reproducción automática desactivada';

  @override
  String get playerNoMoreEpisodes => 'Has llegado al último episodio';

  @override
  String get playerFirstEpisode => 'Este es el primer episodio';

  @override
  String get playerPlaybackFailed =>
      'No se pudo reproducir el vídeo. Inténtalo de nuevo.';

  @override
  String get playerPlay => 'Reproducir';

  @override
  String get playerPause => 'Pausar';

  @override
  String get playerPullDownToCloseComments =>
      'Desliza hacia abajo para cerrar los comentarios';

  @override
  String get playerPlayOnTv => 'Reproducir en TV';

  @override
  String get playerEpisodeList => 'Lista de episodios';

  @override
  String get playerVideoProgress => 'Progreso del vídeo';

  @override
  String get playerClose => 'Cerrar reproductor';

  @override
  String get playerContinueWatchingTitle => '¿Seguir viendo?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'Estabas viendo $episode. ¿Quieres continuar o reiniciar desde el episodio 1?';
  }

  @override
  String get playerRestartFromBeginning => 'Reiniciar desde el principio';

  @override
  String get playerContinue => 'Continuar';

  @override
  String get commentsReply => 'Responder';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count respuestas',
      one: '1 respuesta',
      zero: 'Sin respuestas',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'No se pudieron cargar los comentarios';

  @override
  String get commentsEmptyTitle => 'Aún no hay comentarios';

  @override
  String get commentsEmptySubtitle =>
      'Sé la primera persona en compartir tu opinión.';

  @override
  String get commentsEditHint => 'Editar comentario...';

  @override
  String commentsReplyToHint(String name) {
    return 'Responder a $name...';
  }

  @override
  String get commentsAddReplyHint => 'Añadir una respuesta...';

  @override
  String get commentsComposerHint => 'Escribe un comentario...';

  @override
  String get commentsEditingStatus => 'Editando comentario';

  @override
  String commentsReplyingStatus(String name) {
    return 'Respondiendo a $name';
  }

  @override
  String get commentsWrite => 'Escribir un comentario';

  @override
  String get commentsSend => 'Enviar';

  @override
  String get commentsCloseMenu => 'Cerrar menú de comentarios';

  @override
  String get commentsCopied => 'Comentario copiado';

  @override
  String get commentsYourComment => 'Tu comentario';

  @override
  String get commentsReportReasonTitle => '¿Por qué reportas este comentario?';

  @override
  String get commentsReportSent => 'Reporte enviado. Gracias.';

  @override
  String get commentsDeleteTitle => '¿Eliminar comentario?';

  @override
  String get commentsRepliesPreserved => 'Las respuestas se conservarán.';

  @override
  String get commentsDeleteAction => 'Eliminar comentario';

  @override
  String get commentsSortTitle => 'Ordenar comentarios';

  @override
  String get commentsPopular => 'Populares';

  @override
  String get commentsNewest => 'Más recientes';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count comentarios',
      one: '1 comentario',
      zero: 'Comentarios',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'Copiar comentario';

  @override
  String get commentsEdited => 'Editado';

  @override
  String get commentsDeleted => 'Comentario eliminado';

  @override
  String get commentsJustNow => 'ahora mismo';

  @override
  String commentsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count minutos',
      one: 'hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String commentsWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count semanas',
      one: 'hace 1 semana',
    );
    return '$_temp0';
  }

  @override
  String commentsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count meses',
      one: 'hace 1 mes',
    );
    return '$_temp0';
  }

  @override
  String commentsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count años',
      one: 'hace 1 año',
    );
    return '$_temp0';
  }

  @override
  String get commentsSpamReason => 'Spam';

  @override
  String get commentsHarassmentReason => 'Acoso o abuso';

  @override
  String get commentsSpoilerReason => 'Spoiler de película';

  @override
  String get commentsInappropriateReason => 'Contenido inapropiado';

  @override
  String get commentsOtherReason => 'Otro motivo';

  @override
  String get commentsLoadFailed =>
      'No se pudieron cargar los comentarios. Inténtalo de nuevo.';

  @override
  String get commentsLoadMoreFailed => 'No se pudieron cargar más comentarios.';

  @override
  String get commentsRepliesLoadFailed =>
      'No se pudieron cargar las respuestas.';

  @override
  String get commentsRepliesLoadMoreFailed =>
      'No se pudieron cargar más respuestas.';

  @override
  String get commentsSendFailed =>
      'No se pudo enviar el comentario. Tu texto se ha conservado.';

  @override
  String get commentsEditFailed => 'No se pudo editar el comentario.';

  @override
  String get commentsDeleteFailed => 'No se pudo eliminar el comentario.';

  @override
  String get commentsReactionFailed => 'No se pudo actualizar la reacción.';

  @override
  String get commentsReportFailed =>
      'Este comentario ya se ha reportado o no se pudo enviar el reporte.';

  @override
  String get commentsOperationInProgress => 'Esta acción ya está en curso.';

  @override
  String get notificationsEmpty => 'No hay notificaciones nuevas';

  @override
  String get notificationsRepliedToYourComment => 'respondió a tu comentario';

  @override
  String get notificationsLikedYourComment =>
      'indicó que le gusta tu comentario';

  @override
  String get notificationsToday => 'Hoy';

  @override
  String get notificationsYesterday => 'Ayer';

  @override
  String get notificationsUnknownUser => 'Alguien';

  @override
  String get notificationsNewMovieTitle => 'Nueva película';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count películas nuevas';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName acaba de añadirse a Liquid Phim.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Notificaciones cuando Liquid Phim descubre nuevas películas';

  @override
  String get castChooseDevice => 'Elegir un dispositivo';

  @override
  String get castAirPlayUnavailableTitle => 'No se pudo abrir AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      'Asegúrate de que tu iPhone y tu TV o Mac estén en la misma red Wi-Fi e inténtalo de nuevo.';

  @override
  String get castVideoUnavailableTitle => 'No hay vídeo disponible';

  @override
  String get castVideoUnavailableBody =>
      'Espera a que se cargue el vídeo y luego elige un dispositivo Google Cast.';

  @override
  String get castConnectionFailedTitle => 'No se pudo conectar con Google Cast';

  @override
  String get castConnectionFailedBody =>
      'Comprueba los servicios de Google Play y asegúrate de que tu teléfono y Chromecast o Google TV estén en la misma red Wi-Fi.';

  @override
  String get castAirPlayAndBluetoothDevices =>
      'Dispositivos AirPlay y Bluetooth';

  @override
  String get castConnecting => 'Conectando...';

  @override
  String get castSearching => 'Buscando dispositivos Google Cast...';

  @override
  String get castNoDevices => 'No se encontraron dispositivos';

  @override
  String get castSameWifiGuidance =>
      'Asegúrate de que tu teléfono y Chromecast o Google TV estén en la misma red Wi-Fi.';

  @override
  String get castSearchAgain => 'Buscar de nuevo';

  @override
  String get castDefaultDeviceName => 'Dispositivo Google Cast';

  @override
  String shareMovieSubject(String movieName) {
    return 'Ver $movieName en Liquid Phim';
  }

  @override
  String get shareOpenFailed => 'No se pudo abrir el menú para compartir.';

  @override
  String get rankingTopFavorites => 'TOP de películas favoritas';

  @override
  String get rankingTopLiquidPhim => 'TOP 30 de Liquid Phim';

  @override
  String get rankingTopHotMovies => 'TOP 30 de películas populares';

  @override
  String get rankingMostViewed => 'MÁS VISTAS';

  @override
  String get rankingMostLiked => 'CON MÁS ME GUSTA';

  @override
  String get rankingEmptyLikes =>
      'La clasificación aparecerá cuando las películas reciban Me gusta.';

  @override
  String get rankingEmptyViews =>
      'La clasificación aparecerá cuando las películas reciban visualizaciones.';

  @override
  String get rankingLoadFailed => 'No se pudo cargar la clasificación.';

  @override
  String playerEpisodeNumber(int number) {
    return 'Episodio $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'Mes $month';
  }
}
