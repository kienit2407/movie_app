class NewMovieNotificationConstants {
  const NewMovieNotificationConstants._();

  static const String knownSlugsBox = 'known_new_movie_slugs';
  static const String metadataBox = 'new_movie_notification_meta';
  static const String inboxBox = 'new_movie_notification_inbox';
  static const Duration inboxRetention = Duration(days: 7);

  static const String baselineInitializedKey = 'baselineInitialized';
  static const String onboardingShownKey = 'onboardingShown';
  static const String lastSuccessfulCheckAtKey = 'lastSuccessfulCheckAt';

  static const String androidUniqueTaskName = 'new-movie-periodic-check';
  static const String taskName = 'checkNewMovies';
  static const String iosTaskIdentifier = 'com.kinit.movieapp.newMovieRefresh';
  // Temporary debug interval. Restore to 20 minutes after iOS testing.
  static const Duration checkFrequency = Duration(minutes: 20);

  static const int notificationId = 1001;
  static const String channelId = 'new_movies';
  static const String channelName = 'Phim mới';
  static const String channelDescription =
      'Thông báo khi Liquid Phim phát hiện phim mới';
}
