import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:movie_app/feature/library/presentation/widgets/auth_required_view.dart';
import 'package:movie_app/feature/library/presentation/widgets/library_movie_card.dart';
import 'package:movie_app/feature/hub/presentation/pages/hub_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
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
    if (HubTabReselectNotifier.instance.index != 2 ||
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: AppColor.bgApp,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        title: const Text('Yêu thích'),
      ),
      body: BlocConsumer<UserLibraryCubit, UserLibraryState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        },
        builder: (context, state) {
          if (!state.isAuthenticated) {
            return AuthRequiredView(
              title: 'Đăng nhập để lưu phim yêu thích',
              description:
                  'Danh sách của bạn sẽ được đồng bộ trên các thiết bị.',
              onSignedIn: () => context.read<UserLibraryCubit>().refresh(),
            );
          }
          if (state.isLoading && state.favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          if (state.errorMessage != null && state.favorites.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.cloud_off_outlined,
                      color: Colors.white54,
                      size: 52,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: context.read<UserLibraryCubit>().refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state.favorites.isEmpty) {
            return RefreshIndicator.adaptive(
              onRefresh: context.read<UserLibraryCubit>().refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 190),
                  Icon(Icons.favorite_border, color: Colors.white38, size: 58),
                  SizedBox(height: 14),
                  Center(
                    child: Text(
                      'Chưa có phim yêu thích',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: context.read<UserLibraryCubit>().refresh,
            child: GridView.builder(
              key: const PageStorageKey('favorites-grid'),
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150,
                mainAxisSpacing: 18,
                crossAxisSpacing: 10,
                childAspectRatio: .55,
              ),
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final movie = state.favorites[index];
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
                  onRemove: () => context
                      .read<UserLibraryCubit>()
                      .removeFavorite(movie.slug),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
