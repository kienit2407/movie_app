import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/app_toast.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/utils/movie_player_args.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/player_overlay_launcher.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
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
  final Set<String> _selectedHistorySlugs = <String>{};

  bool get _isSelectingHistory => _selectedHistorySlugs.isNotEmpty;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    HubTabReselectNotifier.instance.addListener(_onHubTabReselected);
  }

  void _onHubTabReselected() {
    if (HubTabReselectNotifier.instance.index != 3) {
      return;
    }
    if (_isSelectingHistory) {
      setState(_selectedHistorySlugs.clear);
      return;
    }
    if (!_scrollController.hasClients) return;
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
    final confirmed = await showAnimatedDialog<bool>(
      context: context,
      dialog: const AppAlertDialog(
        title: 'Đăng xuất?',
        content: 'Bạn có chắc muốn đăng xuất khỏi tài khoản này?',
        buttonTitle: 'Đăng xuất',
        cancelButtonTitle: 'Hủy',
        isDestructive: true,
      ),
    );
    if (confirmed != true || !mounted) return;
    await Supabase.instance.client.auth.signOut();
    if (mounted) context.go(AppRoutes.home);
  }

  void _toggleHistorySelection(String slug) {
    setState(() {
      if (!_selectedHistorySlugs.add(slug)) {
        _selectedHistorySlugs.remove(slug);
      }
    });
  }

  Future<bool> _confirmHistoryRemoval(int count) async {
    final many = count > 1;
    return await showAnimatedDialog<bool>(
          context: context,
          dialog: AppAlertDialog(
            title: many ? 'Xóa $count phim đã chọn?' : 'Xóa lịch sử phim này?',
            content: many
                ? 'Bạn có đồng ý xóa $count phim khỏi lịch sử xem không?'
                : 'Bạn có đồng ý xóa phim này khỏi lịch sử xem không?',
            buttonTitle: 'Xóa',
            cancelButtonTitle: 'Hủy',
            isDestructive: true,
          ),
        ) ??
        false;
  }

  Future<void> _removeHistory(String slug) async {
    if (!await _confirmHistoryRemoval(1) || !mounted) return;
    await context.read<UserLibraryCubit>().removeHistory(slug);
  }

  Future<void> _removeSelectedHistory() async {
    final selected = Set<String>.from(_selectedHistorySlugs);
    if (selected.isEmpty ||
        !await _confirmHistoryRemoval(selected.length) ||
        !mounted) {
      return;
    }
    setState(_selectedHistorySlugs.clear);
    await context.read<UserLibraryCubit>().removeHistoryItems(selected);
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
        (_) => AppToast.show(context, 'Không thể mở lại phim lúc này.'),
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
          context.openMoviePlayer(
            MoviePlayerArgs(
              detail.movie.slug,
              detail.movie.poster_url,
              link,
              episodeIndex,
              server.server_name,
              detail.movie.name,
              detail.episodes,
              detail.movie,
              initialServerIndex: serverIndex,
              bypassSeriesResumePrompt: true,
            ),
          );
        },
      );
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      AppToast.show(context, 'Không thể mở lại phim lúc này.');
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: !_isSelectingHistory,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSelectingHistory) {
          setState(_selectedHistorySlugs.clear);
        }
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColor.firstColor.withValues(alpha: .4),
                      AppColor.firstColor.withValues(alpha: .02),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
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
                      onSignedIn: () =>
                          context.read<UserLibraryCubit>().refresh(),
                    );
                  }
                  final displayName = state.displayName;
                  final avatarUrl = state.avatarUrl;

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
                                Expanded(
                                  child: Text(
                                    _isSelectingHistory
                                        ? '${_selectedHistorySlugs.length} đã chọn'
                                        : 'Lịch sử xem',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (_isSelectingHistory) ...[
                                  IconButton(
                                    tooltip: 'Hủy chọn',
                                    onPressed: () =>
                                        setState(_selectedHistorySlugs.clear),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                  IconButton(
                                    tooltip: 'Xóa phim đã chọn',
                                    onPressed: _removeSelectedHistory,
                                    icon: Icon(
                                      Iconsax.trash_copy,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
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
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final movie = state.history[index];
                                final previousDate = index == 0
                                    ? null
                                    : state.history[index - 1].watchedAt;
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
                                  activityDate: movie.watchedAt,
                                  showDateBadge: startsNewLibraryDateGroup(
                                    movie.watchedAt,
                                    previousDate,
                                  ),
                                  rating: movie.rating,
                                  progress: movie.progress,
                                  isSelectionMode: _isSelectingHistory,
                                  isSelected: _selectedHistorySlugs.contains(
                                    movie.slug,
                                  ),
                                  onTap: () => _continueWatching(movie),
                                  onSelectionTap: () =>
                                      _toggleHistorySelection(movie.slug),
                                  onLongPress: () {
                                    HapticFeedback.mediumImpact();
                                    _toggleHistorySelection(movie.slug);
                                  },
                                  onRemove: () => _removeHistory(movie.slug),
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
          ),
        ],
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
              icon: const Icon(Iconsax.logout_1_copy, color: Colors.white70),
            ),
          ),

          _Avatar(url: avatarUrl, size: 112),

          const SizedBox(height: 16),

          // Tên luôn nằm chính giữa,
          // icon edit nằm riêng bên phải.
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = 10.0;
              const editButtonWidth = 46.0;

              // Bên trái chừa đúng bằng:
              // khoảng cách + chiều rộng nút edit.
              const sideSpace = gap + editButtonWidth;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Spacer giả để giữ tên chính giữa tuyệt đối.
                  const SizedBox(width: sideSpace),

                  // Tên.
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth - sideSpace * 2,
                    ),
                    child: Text(
                      displayName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  // Khoảng cách tính từ chữ.
                  const SizedBox(width: gap),

                  // Nút edit.
                  SizedBox(
                    width: editButtonWidth,
                    child: InkWell(
                      onTap: onEdit,
                      borderRadius: BorderRadius.circular(30.r),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        child: const Icon(
                          Iconsax.edit_2,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 5),

          Text(email, style: const TextStyle(color: Colors.white54)),

          const SizedBox(height: 18),
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
            : FastCachedImage(key: ValueKey(url), url: url, fit: BoxFit.cover),
      ),
    );
  }
}
