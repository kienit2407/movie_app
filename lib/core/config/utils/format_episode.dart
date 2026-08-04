import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

extension FormatEpisode on String {
  String toFormatEpisode() {
    int totalMinutes = int.parse(
      this.split(" ")[0],
    ); //sử dụng tryParse khi không phải số
    int hours = totalMinutes ~/ 60; //chia lấy nguyên
    int minutes = totalMinutes % 60; //-> chia lấy dư
    return "${hours.toString()} giờ ${minutes.toString().padLeft(2, '0')} phút";
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
