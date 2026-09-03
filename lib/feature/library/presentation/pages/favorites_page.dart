import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/components/app_toast.dart';
import 'package:movie_app/common/helpers/static_data.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/sharder_text.dart';
import 'package:movie_app/core/extension/build_context_extension.dart';
import 'package:movie_app/feature/hub/presentation/pages/hub_page.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:movie_app/feature/library/presentation/widgets/auth_required_view.dart';
import 'package:movie_app/feature/library/presentation/widgets/library_movie_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _largeTitleKey = GlobalKey();
  final Set<String> _selectedSlugs = <String>{};

  late final Map<LinearGradient, Color> _selectedGradient;
  bool _showSmallTitle = false;

  bool get _isSelecting => _selectedSlugs.isNotEmpty;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    final gradients = StaticData.randomeGadientTitlePage;
    _selectedGradient = gradients[Random().nextInt(gradients.length)];
    _scrollController.addListener(_checkLargeTitleVisibility);
    HubTabReselectNotifier.instance.addListener(_onHubTabReselected);
  }

  void _checkLargeTitleVisibility() {
    final renderObject = _largeTitleKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox) return;
    final position = renderObject.localToGlobal(Offset.zero);
    final largeTitleBottom = position.dy + renderObject.size.height;
    final appBarHeight = MediaQuery.paddingOf(context).top + kToolbarHeight;
    final shouldShowSmallTitle = largeTitleBottom < appBarHeight + 10;
    if (shouldShowSmallTitle == _showSmallTitle) return;
    setState(() => _showSmallTitle = shouldShowSmallTitle);
  }

  void _onHubTabReselected() {
    if (HubTabReselectNotifier.instance.index != 2 ||
        !_scrollController.hasClients) {
      return;
    }
    if (_isSelecting) {
      setState(_selectedSlugs.clear);
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

  void _toggleSelection(String slug) {
    setState(() {
      if (!_selectedSlugs.add(slug)) _selectedSlugs.remove(slug);
    });
  }

  Future<bool> _confirmRemoval(int count) async {
    final many = count > 1;
    final l10n = context.l10n;
    return await showAnimatedDialog<bool>(
          context: context,
          dialog: AppAlertDialog(
            title: many
                ? l10n.libraryDeleteSelectedMoviesTitle(count)
                : l10n.libraryDeleteFavoriteMovieTitle,
            content: l10n.libraryDeleteFavoritesConfirmation(count),
            buttonTitle: l10n.commonDelete,
            cancelButtonTitle: l10n.commonCancel,
            isDestructive: true,
          ),
        ) ??
        false;
  }

  Future<void> _removeOne(String slug) async {
    if (!await _confirmRemoval(1) || !mounted) return;
    await context.read<UserLibraryCubit>().removeFavorite(slug);
  }

  Future<void> _removeSelected() async {
    final selected = Set<String>.from(_selectedSlugs);
    if (selected.isEmpty ||
        !await _confirmRemoval(selected.length) ||
        !mounted) {
      return;
    }
    setState(_selectedSlugs.clear);
    await context.read<UserLibraryCubit>().removeFavorites(selected);
  }

  @override
  void dispose() {
    HubTabReselectNotifier.instance.removeListener(_onHubTabReselected);
    _scrollController
      ..removeListener(_checkLargeTitleVisibility)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final backgroundGradient = _selectedGradient.keys.single;
    final appBarColor = _selectedGradient.values.single;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);

    return PopScope(
      canPop: !_isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSelecting) setState(_selectedSlugs.clear);
      },
      child: Scaffold(
        backgroundColor: AppColor.bgApp,
        body: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(gradient: backgroundGradient),
            ),
            BlocConsumer<UserLibraryCubit, UserLibraryState>(
              listenWhen: (previous, current) =>
                  previous.errorMessage != current.errorMessage &&
                  current.errorMessage != null,
              listener: (context, state) {
                AppToast.show(context, context.l10n.libraryLoadFailed);
              },
              builder: (context, state) => RefreshIndicator.adaptive(
                color: Colors.white,
                onRefresh: context.read<UserLibraryCubit>().refresh,
                child: Scrollbar(
                  controller: _scrollController,
                  child: CustomScrollView(
                    key: const PageStorageKey('favorites-scroll'),
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      _buildAppBar(appBarColor, duration),
                      _buildLargeTitle(),
                      _buildContent(state),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Color appBarColor, Duration duration) {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      leading: _isSelecting
          ? IconButton(
              tooltip: context.l10n.libraryCancelSelection,
              onPressed: () => setState(_selectedSlugs.clear),
              icon: const Icon(Icons.close_rounded, color: Colors.white),
            )
          : null,
      actions: _isSelecting
          ? [
              IconButton(
                tooltip: context.l10n.libraryDeleteSelectedMovies,
                onPressed: _removeSelected,
                icon: const Icon(Iconsax.trash_copy, color: Colors.white),
              ),
              const SizedBox(width: 6),
            ]
          : null,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          enabled: _showSmallTitle || _isSelecting,
          filter: ImageFilter.blur(
            sigmaX: _showSmallTitle || _isSelecting ? 30 : 0,
            sigmaY: _showSmallTitle || _isSelecting ? 30 : 0,
          ),
          child: AnimatedContainer(
            duration: duration,
            decoration: _showSmallTitle || _isSelecting
                ? BoxDecoration(
                    border: Border.all(
                      color: AppColor.buttonColor.withValues(alpha: .3),
                    ),
                    color: appBarColor.withValues(alpha: .7),
                  )
                : null,
          ),
        ),
      ),
      title: AnimatedSwitcher(
        duration: duration,
        child: _isSelecting
            ? Text(
                context.l10n.commonSelectedCount(_selectedSlugs.length),
                key: const ValueKey('selection-title'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              )
            : AnimatedOpacity(
                key: const ValueKey('favorites-title'),
                duration: duration,
                opacity: _showSmallTitle ? 1 : 0,
                child: Text(
                  context.l10n.libraryFavorites,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildLargeTitle() {
    return SliverToBoxAdapter(
      child: Padding(
        key: _largeTitleKey,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SharderText(
          gradient: const LinearGradient(
            colors: [
              Colors.black,
              Colors.black,
              Color(0xff717285),
              Colors.black,
            ],
            begin: Alignment.centerRight,
            end: Alignment.centerLeft,
          ),
          child: Text(
            context.l10n.libraryFavorites,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(UserLibraryState state) {
    if (!state.isAuthenticated) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: AuthRequiredView(
          title: context.l10n.librarySignInToSaveFavorites,
          description: context.l10n.libraryFavoritesSyncDescription,
          onSignedIn: () => context.read<UserLibraryCubit>().refresh(),
        ),
      );
    }
    if (state.isLoading && state.favorites.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    if (state.errorMessage != null && state.favorites.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
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
                  context.l10n.libraryLoadFailed,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: context.read<UserLibraryCubit>().refresh,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.l10n.commonRetry),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (state.favorites.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border,
                color: Colors.white38,
                size: 58,
              ),
              const SizedBox(height: 14),
              Text(
                context.l10n.libraryNoFavorites,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: 18,
          crossAxisSpacing: 10,
          childAspectRatio: .55,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final movie = state.favorites[index];
            final selected = _selectedSlugs.contains(movie.slug);
            final previousDate = index == 0
                ? null
                : state.favorites[index - 1].addedAt;
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
              activityDate: movie.addedAt,
              showDateBadge: startsNewLibraryDateGroup(
                movie.addedAt,
                previousDate,
              ),
              rating: movie.rating,
              isSelectionMode: _isSelecting,
              isSelected: selected,
              onSelectionTap: () => _toggleSelection(movie.slug),
              onLongPress: () {
                HapticFeedback.mediumImpact();
                _toggleSelection(movie.slug);
              },
              onRemove: () => _removeOne(movie.slug),
            );
          },
          childCount: state.favorites.length,
          findChildIndexCallback: (key) {
            final slug = (key as ValueKey<String>).value;
            final index = state.favorites.indexWhere(
              (item) => item.slug == slug,
            );
            return index < 0 ? null : index;
          },
        ),
      ),
    );
  }
}
