import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_constants.dart';

abstract interface class NewMovieNotificationStore {
  Future<bool> get isBaselineInitialized;

  Future<bool> get isOnboardingShown;

  Future<void> markOnboardingShown();

  Future<bool> seedBaselineIfNeeded(Iterable<String> slugs);

  Future<Set<String>> getKnownSlugs();

  Future<void> markKnown(Iterable<String> slugs);

  Future<void> recordSuccessfulCheck(DateTime checkedAt);
}

class HiveNewMovieNotificationStore implements NewMovieNotificationStore {
  Future<void>? _initialization;
  Future<IsolatedBox<bool>>? _knownSlugsBox;
  Future<IsolatedBox<dynamic>>? _metadataBox;

  Future<void> _ensureInitialized() {
    return _initialization ??= IsolatedHive.initFlutter();
  }

  Future<IsolatedBox<bool>> _openKnownSlugsBox() async {
    await _ensureInitialized();
    return _knownSlugsBox ??= IsolatedHive.openBox<bool>(
      NewMovieNotificationConstants.knownSlugsBox,
    );
  }

  Future<IsolatedBox<dynamic>> _openMetadataBox() async {
    await _ensureInitialized();
    return _metadataBox ??= IsolatedHive.openBox<dynamic>(
      NewMovieNotificationConstants.metadataBox,
    );
  }

  @override
  Future<bool> get isBaselineInitialized async {
    final box = await _openMetadataBox();
    return await box.get(
          NewMovieNotificationConstants.baselineInitializedKey,
        ) ==
        true;
  }

  @override
  Future<bool> get isOnboardingShown async {
    final box = await _openMetadataBox();
    return await box.get(NewMovieNotificationConstants.onboardingShownKey) ==
        true;
  }

  @override
  Future<void> markOnboardingShown() async {
    final box = await _openMetadataBox();
    await box.put(NewMovieNotificationConstants.onboardingShownKey, true);
  }

  @override
  Future<bool> seedBaselineIfNeeded(Iterable<String> slugs) async {
    final normalizedSlugs = _normalizeSlugs(slugs);
    if (normalizedSlugs.isEmpty || await isBaselineInitialized) return false;

    final knownSlugsBox = await _openKnownSlugsBox();
    await knownSlugsBox.putAll({
      for (final slug in normalizedSlugs) slug: true,
    });

    final metadataBox = await _openMetadataBox();
    await metadataBox.put(
      NewMovieNotificationConstants.baselineInitializedKey,
      true,
    );
    await recordSuccessfulCheck(DateTime.now());
    return true;
  }

  @override
  Future<Set<String>> getKnownSlugs() async {
    final box = await _openKnownSlugsBox();
    final keys = await box.keys;
    return keys.whereType<String>().toSet();
  }

  @override
  Future<void> markKnown(Iterable<String> slugs) async {
    final normalizedSlugs = _normalizeSlugs(slugs);
    if (normalizedSlugs.isEmpty) return;

    final box = await _openKnownSlugsBox();
    await box.putAll({for (final slug in normalizedSlugs) slug: true});
  }

  @override
  Future<void> recordSuccessfulCheck(DateTime checkedAt) async {
    final box = await _openMetadataBox();
    await box.put(
      NewMovieNotificationConstants.lastSuccessfulCheckAtKey,
      checkedAt.toUtc().toIso8601String(),
    );
  }

  Set<String> _normalizeSlugs(Iterable<String> slugs) {
    return slugs
        .map((slug) => slug.trim())
        .where((slug) => slug.isNotEmpty)
        .toSet();
  }
}
