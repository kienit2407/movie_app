import 'package:movie_app/l10n/app_localizations.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

extension FormatEpisode on String {
  String toFormatEpisode(AppLocalizations l10n) {
    int totalMinutes = int.parse(
      this.split(" ")[0],
    ); //sử dụng tryParse khi không phải số
    int hours = totalMinutes ~/ 60; //chia lấy nguyên
    int minutes = totalMinutes % 60; //-> chia lấy dư
    return l10n.commonDurationHoursMinutes(hours, minutes);
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
