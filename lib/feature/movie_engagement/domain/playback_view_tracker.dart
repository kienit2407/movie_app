class PlaybackViewTracker {
  PlaybackViewTracker({this.threshold = const Duration(minutes: 1)});

  final Duration threshold;

  Duration _qualifiedWatchTime = Duration.zero;
  DateTime? _qualifiedPlaybackStartedAt;
  bool _hasReachedThreshold = false;

  Duration get qualifiedWatchTime => _qualifiedWatchTime;
  bool get hasReachedThreshold => _hasReachedThreshold;

  bool update({required bool isPlaying, DateTime? now}) {
    if (_hasReachedThreshold) return false;

    final updatedAt = now ?? DateTime.now();
    final startedAt = _qualifiedPlaybackStartedAt;
    if (startedAt != null && updatedAt.isAfter(startedAt)) {
      _qualifiedWatchTime += updatedAt.difference(startedAt);
    }

    _qualifiedPlaybackStartedAt = isPlaying ? updatedAt : null;
    if (_qualifiedWatchTime < threshold) return false;

    _hasReachedThreshold = true;
    _qualifiedPlaybackStartedAt = null;
    return true;
  }
}
