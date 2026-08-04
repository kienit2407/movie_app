import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/feature/detail_movie/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:movie_app/feature/library/presentation/widgets/auth_required_view.dart';
import 'package:movie_app/feature/library/presentation/widgets/library_movie_card.dart';
import 'package:movie_app/feature/hub/presentation/pages/hub_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    HubTabReselectNotifier.instance.addListener(_onHubTabReselected);
  }

  void _onHubTabReselected() {
    if (HubTabReselectNotifier.instance.index != 3 ||
        !_scrollController.hasClients) {
      return;
    }
    _scrollController.animateTo(
      0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    HubTabReselectNotifier.instance.removeListener(_onHubTabReselected);
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go(AppRoutes.home);
  }

  Future<void> _continueWatching(UserWatchHistory history) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator.adaptive()),
    );
    try {
      final result = await sl<GetDetailMovieUsecase>()(history.slug);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      result.fold(
        (_) => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở lại phim lúc này.')),
        ),
        (detail) {
          if (detail.episodes.isEmpty) return;
          var serverIndex = history.lastServerIndex ?? 0;
          if (history.lastServerName?.isNotEmpty ?? false) {
            final namedIndex = detail.episodes.indexWhere(
              (server) => server.server_name == history.lastServerName,
            );
            if (namedIndex >= 0) serverIndex = namedIndex;
          }
          serverIndex = serverIndex
              .clamp(0, detail.episodes.length - 1)
              .toInt();
          final server = detail.episodes[serverIndex];
          if (server.server_data.isEmpty) return;
          final episodeIndex = (history.lastEpisodeIndex ?? 0)
              .clamp(0, server.server_data.length - 1)
              .toInt();
          final episode = server.server_data[episodeIndex];
          final link = episode.link_m3u8.isNotEmpty
              ? episode.link_m3u8
              : episode.link_embed;
          context.push(
            AppRoutes.player,
            extra: MoviePlayerArgs(
              detail.movie.slug,
              detail.movie.poster_url,
              link,
              episodeIndex,
              server.server_name,
              detail.movie.name,
              detail.episodes,
              detail.movie,
              initialServerIndex: serverIndex,
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể mở lại phim lúc này.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColor.bgApp,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<UserLibraryCubit, UserLibraryState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) {
              return AuthRequiredView(
                title: 'Hồ sơ của bạn',
                description:
                    'Đăng nhập để chỉnh sửa hồ sơ và đồng bộ lịch sử xem.',
                onSignedIn: () => context.read<UserLibraryCubit>().refresh(),
              );
            }
            final metadata = user.userMetadata ?? const <String, dynamic>{};
            final displayName = _firstNonEmpty([
              metadata['full_name'],
              metadata['name'],
              metadata['user_name'],
              user.email?.split('@').first,
            ], fallback: 'Người dùng');
            final avatarUrl = _firstNonEmpty([
              metadata['avatar_url'],
              metadata['picture'],
            ]);

            return RefreshIndicator.adaptive(
              onRefresh: context.read<UserLibraryCubit>().refresh,
              child: CustomScrollView(
                key: const PageStorageKey('profile-scroll'),
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: _ProfileHeader(
                      displayName: displayName,
                      email: user.email ?? '',
                      avatarUrl: avatarUrl,
                      onEdit: () => context.push(AppRoutes.editProfile),
                      onSignOut: _signOut,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          const Text(
                            'Lịch sử xem',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${state.history.length}/100',
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state.isLoading && state.history.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    )
                  else if (state.history.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Chưa có lịch sử xem',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: .55),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 120),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              mainAxisSpacing: 18,
                              crossAxisSpacing: 10,
                              childAspectRatio: .55,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final movie = state.history[index];
                          return LibraryMovieCard(
                            key: ValueKey(movie.slug),
                            slug: movie.slug,
                            name: movie.name,
                            originName: movie.originName,
                            posterUrl: movie.posterUrl,
                            episodeCurrent: movie.episodeCurrent,
                            quality: movie.quality,
                            lang: movie.lang,
                            year: movie.year,
                            rating: movie.rating,
                            progress: movie.progress,
                            onTap: () => _continueWatching(movie),
                            onRemove: () => context
                                .read<UserLibraryCubit>()
                                .removeHistory(movie.slug),
                          );
                        }, childCount: state.history.length),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.onEdit,
    required this.onSignOut,
  });

  final String displayName;
  final String email;
  final String avatarUrl;
  final VoidCallback onEdit;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              tooltip: 'Đăng xuất',
              onPressed: onSignOut,
              icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            ),
          ),
          _Avatar(url: avatarUrl, size: 112),
          const SizedBox(height: 16),
          Text(
            displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(email, style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 18),
          FilledButton.tonalIcon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Chỉnh sửa hồ sơ'),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.url, required this.size});

  final String url;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColor.primaryColor,
      ),
      child: ClipOval(
        child: url.isEmpty
            ? const ColoredBox(
                color: Color(0xff292B38),
                child: Icon(Icons.person, color: Colors.white70, size: 54),
              )
            : FastCachedImage(url: url, fit: BoxFit.cover),
      ),
    );
  }
}

String _firstNonEmpty(List<Object?> values, {String fallback = ''}) {
  for (final value in values) {
    final text = value?.toString().trim() ?? '';
    if (text.isNotEmpty) return text;
  }
  return fallback;
}
