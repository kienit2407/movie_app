import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/movie_engagement/domain/playback_view_tracker.dart';

void main() {
  test('reaches the threshold after cumulative qualified playback', () {
    final tracker = PlaybackViewTracker(threshold: const Duration(seconds: 60));
    final startedAt = DateTime(2026, 8, 11, 12);

    expect(tracker.update(isPlaying: true, now: startedAt), isFalse);
    expect(
      tracker.update(
        isPlaying: false,
        now: startedAt.add(const Duration(seconds: 40)),
      ),
      isFalse,
    );
    expect(
      tracker.update(
        isPlaying: true,
        now: startedAt.add(const Duration(minutes: 2)),
      ),
      isFalse,
    );
    expect(
      tracker.update(
        isPlaying: true,
        now: startedAt.add(const Duration(minutes: 2, seconds: 19)),
      ),
      isFalse,
    );
    expect(
      tracker.update(
        isPlaying: true,
        now: startedAt.add(const Duration(minutes: 2, seconds: 20)),
      ),
      isTrue,
    );
    expect(tracker.qualifiedWatchTime, const Duration(seconds: 60));
  });

  test('does not count time while playback is paused', () {
    final tracker = PlaybackViewTracker(threshold: const Duration(seconds: 5));
    final startedAt = DateTime(2026, 8, 11, 12);

    tracker.update(isPlaying: true, now: startedAt);
    tracker.update(
      isPlaying: false,
      now: startedAt.add(const Duration(seconds: 2)),
    );

    expect(
      tracker.update(
        isPlaying: false,
        now: startedAt.add(const Duration(minutes: 10)),
      ),
      isFalse,
    );
    expect(tracker.qualifiedWatchTime, const Duration(seconds: 2));
  });

  test('reports the threshold only once', () {
    final tracker = PlaybackViewTracker(threshold: const Duration(seconds: 1));
    final startedAt = DateTime(2026, 8, 11, 12);

    tracker.update(isPlaying: true, now: startedAt);
    expect(
      tracker.update(
        isPlaying: true,
        now: startedAt.add(const Duration(seconds: 1)),
      ),
      isTrue,
    );
    expect(
      tracker.update(
        isPlaying: true,
        now: startedAt.add(const Duration(seconds: 2)),
      ),
      isFalse,
    );
  });
}
