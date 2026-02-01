import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

extension FormatEpisode on String {
  String toFormatEpisode() {
    int totalMinutes = int.parse(
      this.split(" ")[0],
    ); //sử dụng tryParse khi không phải số
    int hours = totalMinutes ~/ 60; //chia lấy nguyên
    int minutes = totalMinutes % 60; //-> chia lấy dư
    return "${hours.toString()}giờ ${minutes.toString().padLeft(2, '0')}phút";
  }
}

// extension FormatEpisode on String {
//   String toFormatEpisode () {
//     int totalMinutes = int.parse(this.split("")[0]); //sử dụng tryParse khi không phải số
//     int hours = totalMinutes ~/ 60; //chia lấy nguyên
//     int minutes = totalMinutes % 60; //-> chia lấy dư
//     return "${minutes.toString()} phút/tập";
//   }
// }
extension ConvertLang on String {
  String toConvertLang() {
    String lang = this;
    switch (lang) {
      case 'Vietsub':
        return 'PĐ';
      case 'Lồng Tiếng':
        return 'LT';
      case 'Vietsub + Lồng Tiếng':
        return 'PĐ.LT';
      case 'Vietsub + Thuyết Minh':
        return 'PD.TM';
      case 'Vietsub + Thuyết Minh + Lồng Tiếng':
        return 'PĐ.TM.LT';
      case 'Vietsub + Lồng Tiếng + Thuyết Minh':
        return 'PĐ.LT.TM';
      case 'Thuyết Minh':
        return 'TM';
    }
    // if(lang == 'Vietsub') {
    //   return 'PĐ';
    // }
    // if(lang == 'Lồng Tiếng') {
    //   return 'LT';
    // }
    // if(lang == 'Vietsub + Lồng Tiếng') {
    //   return 'PĐ.LT';
    // }
    // if(lang == 'Vietsub + Thuyết Minh') {
    //   return 'PĐ.TM';
    // }

    return 'unKnown';
  }
}

class EpisodeHelper {
  static int parse(String? s) {
    final m = RegExp(r'(\d+)').firstMatch(s ?? '');
    return m == null ? 1 : int.parse(m.group(1)!);
  }

  static List<EpisodesModel> normalizeEpisodes(List<EpisodesModel> input) {
    final List<EpisodesModel> out = [];

    for (final ep in input) {
      final rawServerName = ep.server_name;
      final lowerName = rawServerName.toLowerCase();

      // nhanh: không có "+" thì bỏ qua
      if (!rawServerName.contains('+')) {
        out.add(ep);
        continue;
      }

      final hasVietsub = lowerName.contains('vietsub');

      final hasThuyetMinh =
          lowerName.contains('thuyết minh') ||
          lowerName.contains('thuyet minh') ||
          lowerName.contains('thuyet-minh');

      final hasLongTieng =
          lowerName.contains('lồng tiếng') ||
          lowerName.contains('long tieng') ||
          lowerName.contains('long-tieng');

      final isCombined = hasVietsub && (hasThuyetMinh || hasLongTieng);

      if (!isCombined) {
        out.add(ep);
        continue;
      }

      final prefix = _extractPrefix(rawServerName);
      final vietsubName = '$prefix (Vietsub)';
      final thuyetMinhName = '$prefix (Thuyết Minh)';
      final longTiengName = '$prefix (Lồng Tiếng)';

      final vietsubData = <ServerData>[];
      final thuyetMinhData = <ServerData>[];
      final longTiengData = <ServerData>[];

      for (final sd in ep.server_data) {
        final slug = sd.slug.toLowerCase();
        final name = sd.name.toLowerCase();
        final file = sd.filename.toLowerCase();

        final isThuyetMinh =
            slug.contains('thuyet-minh') ||
            name.contains('thuyết minh') ||
            name.contains('thuyet minh') ||
            file.contains('thuyết minh') ||
            file.contains('thuyet minh') ||
            file.contains('thuyet-minh');

        final isLongTieng =
            slug.contains('long-tieng') ||
            name.contains('lồng tiếng') ||
            name.contains('long tieng') ||
            file.contains('lồng tiếng') ||
            file.contains('long tieng') ||
            file.contains('long-tieng');

        if (isThuyetMinh) {
          thuyetMinhData.add(sd);
        } else if (isLongTieng) {
          longTiengData.add(sd);
        } else {
          vietsubData.add(sd);
        }
      }

      if (vietsubData.isNotEmpty) {
        out.add(
          EpisodesModel(server_name: vietsubName, server_data: vietsubData),
        );
      }
      if (thuyetMinhData.isNotEmpty) {
        out.add(
          EpisodesModel(
            server_name: thuyetMinhName,
            server_data: thuyetMinhData,
          ),
        );
      }
      if (longTiengData.isNotEmpty) {
        out.add(
          EpisodesModel(server_name: longTiengName, server_data: longTiengData),
        );
      }

      // fallback
      if (vietsubData.isEmpty &&
          thuyetMinhData.isEmpty &&
          longTiengData.isEmpty) {
        out.add(ep);
      }
    }

    return out;
  }

  static String _extractPrefix(String serverName) {
    final idx = serverName.indexOf('(');
    if (idx == -1) return serverName.trim();
    return serverName.substring(0, idx).trim();
  }
}
