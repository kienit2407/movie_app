import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

extension FormatEpisode on String {
  String toFormatEpisode(AppLocalizations l10n, {bool perEpisode = false}) {
    final match = RegExp(r'^\s*(\d+)').firstMatch(this);
    final totalMinutes = int.tryParse(match?.group(1) ?? '');
    if (totalMinutes == null) return this;

    if (perEpisode) {
      return l10n.commonDurationMinutesPerEpisode(totalMinutes);
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return l10n.commonDurationHoursMinutes(hours, minutes);
  }

  String toLocalizedEpisodeLabel(AppLocalizations l10n) {
    final value = trim();
    if (value.isEmpty) return value;

    final normalized = _normalizeVietnamese(value);
    final completedMatch = RegExp(r'\((\d+)\s*/\s*(\d+)\)').firstMatch(value);
    final isCompleted =
        normalized.contains('hoan tat') ||
        normalized.contains('completed') ||
        normalized.contains('complete');
    if (isCompleted && completedMatch != null) {
      final current = int.parse(completedMatch.group(1)!);
      final total = int.parse(completedMatch.group(2)!);
      return l10n.commonEpisodeCompleted(current, total);
    }

    final prefixedEpisodeMatch = RegExp(
      r'^(?:tap|episode|ep\.?)[\s_-]*(\d+)',
      caseSensitive: false,
    ).firstMatch(normalized);
    final episodeMatch =
        prefixedEpisodeMatch ?? RegExp(r'^(\d+)$').firstMatch(normalized);
    final episode = int.tryParse(episodeMatch?.group(1) ?? '');
    return episode == null ? value : l10n.playerEpisodeNumber(episode);
  }

  String toLocalizedEpisodeShortLabel(AppLocalizations l10n) {
    final value = trim();
    if (value.isEmpty) return value;

    final episode = int.tryParse(
      RegExp(r'\d+').firstMatch(value)?.group(0) ?? '',
    );
    return episode == null ? value : l10n.commonEpisodeNumberShort(episode);
  }

  String _normalizeVietnamese(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp('[àáạảãâầấậẩẫăằắặẳẵ]'), 'a')
        .replaceAll(RegExp('[èéẹẻẽêềếệểễ]'), 'e')
        .replaceAll(RegExp('[ìíịỉĩ]'), 'i')
        .replaceAll(RegExp('[òóọỏõôồốộổỗơờớợởỡ]'), 'o')
        .replaceAll(RegExp('[ùúụủũưừứựửữ]'), 'u')
        .replaceAll(RegExp('[ỳýỵỷỹ]'), 'y')
        .replaceAll('đ', 'd');
  }
}

class EpisodeHelper {
  static int parse(String? s) {
    final m = RegExp(r'(\d+)').firstMatch(s ?? '');
    return m == null ? 1 : int.parse(m.group(1)!);
  }

  static List<EpisodesModel> normalizeEpisodes(List<EpisodesModel> input) {
    return input.expand((episode) => episode.normalize()).toList();
  }
}
