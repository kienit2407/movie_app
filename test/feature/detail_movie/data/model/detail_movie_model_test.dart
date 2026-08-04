import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/feature/detail_movie/data/model/detail_movie_model.dart';

void main() {
  test('splits a combined full movie into Vietsub and Thuyet Minh servers', () {
    final model = DetailMovieModel.fromMap({
      'movie': {
        'slug': 'conan-25',
        'name': 'Conan 25',
        'episode_current': 'Full',
      },
      'episodes': [
        {
          'server_name': 'Vietsub + Thuyết Minh',
          'server_data': [
            {
              'name': 'Full',
              'slug': 'full',
              'filename': 'Conan 25 - Vietsub + Thuyết Minh - Full',
              'link_embed': 'embed-vietsub',
              'link_m3u8': 'vietsub.m3u8',
            },
            {
              'name': 'Thuyết Minh',
              'slug': 'thuyet-minh',
              'filename': 'Conan 25 - Vietsub + Thuyết Minh - Thuyết Minh',
              'link_embed': 'embed-thuyet-minh',
              'link_m3u8': 'thuyet-minh.m3u8',
            },
          ],
        },
      ],
    });

    expect(model.episodes, hasLength(2));
    expect(model.episodes[0].server_name, 'Vietsub');
    expect(model.episodes[0].server_data.single.link_m3u8, 'vietsub.m3u8');
    expect(model.episodes[1].server_name, 'Thuyết Minh');
    expect(model.episodes[1].server_data.single.link_m3u8, 'thuyet-minh.m3u8');
  });

  test('keeps API servers that are already separated', () {
    final episodes = [
      EpisodesModel(
        server_name: 'Vietsub',
        server_data: [
          ServerData(
            name: 'Tập 01',
            slug: 'tap-01',
            filename: 'Vietsub - Tập 01',
            link_embed: '',
            link_m3u8: 'vietsub.m3u8',
          ),
        ],
      ),
      EpisodesModel(
        server_name: 'Thuyết Minh',
        server_data: [
          ServerData(
            name: 'Tập 01',
            slug: 'tap-01',
            filename: 'Thuyết Minh - Tập 01',
            link_embed: '',
            link_m3u8: 'thuyet-minh.m3u8',
          ),
        ],
      ),
    ];

    final normalized = episodes.expand((episode) => episode.normalize());

    expect(normalized, hasLength(2));
  });
}
