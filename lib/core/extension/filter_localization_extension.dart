import 'package:flutter/widgets.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';

extension FilterLocalizationExtension on BuildContext {
  String movieTypeLabel(String slug) => switch (slug) {
    'phim-bo' => l10n.filterSeries,
    'phim-le' => l10n.filterSingleMovies,
    'hoat-hinh' => l10n.filterAnimation,
    'tv-shows' => l10n.filterTvShows,
    'phim-vietsub' => l10n.filterSubtitled,
    'phim-thuyet-minh' => l10n.filterVoiceOver,
    'phim-long-tieng' => l10n.filterDubbed,
    _ => slug,
  };

  String filterLanguageLabel(String slug) => switch (slug) {
    'vietsub' => l10n.filterSubtitled,
    'thuyet-minh' => l10n.filterVoiceOver,
    'long-tieng' => l10n.filterDubbed,
    _ => slug,
  };

  String filterSortLabel(String slug) => switch (slug) {
    '_id' => l10n.filterMostViewed,
    'modified.time' => l10n.filterNewest,
    _ => slug,
  };

  String serverLabel(Object? rawLabel) => switch (rawLabel) {
    'Phụ Đề' => l10n.playerSubtitleServer,
    'Lồng Tiếng' => l10n.filterDubbed,
    'Thuyết Minh' => l10n.filterVoiceOver,
    final String label => label,
    _ => l10n.playerSubtitleServer,
  };
}
