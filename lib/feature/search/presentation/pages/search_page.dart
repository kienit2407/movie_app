import 'dart:async';
import 'package:cupertino_native_better/components/liquid_glass_container.dart';
import 'package:cupertino_native_better/style/glass_effect.dart';
import 'package:cupertino_native_better/utils/version_detector.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_filter_bottom_sheet.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_history_view.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_result_view.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_shimmer_loading.dart';
import 'package:movie_app/feature/hub/presentation/pages/hub_page.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.showBackButton = true});

  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SearchCubit>(),
      child: _SearchPageView(showBackButton: showBackButton),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView({required this.showBackButton});

  final bool showBackButton;

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  bool get _useNativeGlass =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.iOS &&
      PlatformVersion.shouldUseNativeGlass;
  bool _hideClear = false;
  SearchFilterParams _filters = SearchFilterParams.defaults;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    HubTabReselectNotifier.instance.addListener(_onHubTabReselected);
  }

  void _onHubTabReselected() {
    if (HubTabReselectNotifier.instance.index != 1 || !_scrollCtrl.hasClients) {
      return;
    }
    _scrollCtrl.animateTo(
      0,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    // gần đáy thì load more
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final cubit = context.read<SearchCubit>();
      final state = cubit.state;

      if (state is SearchLoaded) {
        //  còn trang + không đang load more mới gọi
        if (state.hasMore && !state.isLoadingMore) {
          cubit.search(state.currentKeyword, isLoadMore: true);
        }
      }
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 600), () {
      final cubit = context.read<SearchCubit>();
      final q = query.trim();

      if (q.isEmpty) {
        cubit.clearSearch();
      } else {
        cubit.search(q, filters: _filters);
      }
    });
  }

  void _showKeywordRequiredMessage() {
    showAnimatedDialog(
      context: context,
      dialog: const AppAlertDialog(
        title: 'Chú ý!',
        content: 'Nhập từ khóa trước khi lọc phim.',
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    FocusScope.of(context).unfocus();

    final keyword = _searchCtrl.text.trim();
    if (keyword.isEmpty) {
      _showKeywordRequiredMessage();
      return;
    }

    final result = await SearchFilterBottomSheet.show(
      context,
      initialFilters: _filters,
    );

    if (result == null || !mounted) return;

    setState(() => _filters = result);
    context.read<SearchCubit>().search(keyword, filters: result);
  }

  @override
  void dispose() {
    HubTabReselectNotifier.instance.removeListener(_onHubTabReselected);
    _debounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColor.bgApp,
        body: Stack(
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
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (widget.showBackButton)
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Iconsax.arrow_left_2_copy,
                              color: Colors.white,
                            ),
                          ),

                        Expanded(child: _buildSearchField()),
                        const SizedBox(width: 8),
                        _buildFilterButton(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<SearchCubit, SearchState>(
                      builder: (context, state) {
                        if (state is SearchLoading) {
                          return const SearchShimmerLoading();
                        } else if (state is SearchLoaded) {
                          return SearchResultView(
                            movies: state.movies,
                            isLoadingMore: state.isLoadingMore, // ✅ mới
                            scrollController: _scrollCtrl,
                            resultSignature:
                                '${state.currentKeyword}|${state.filters.signature}',
                          );
                        } else if (state is SearchInitial) {
                          return SearchHistoryView(
                            history: state.history,
                            onSelect: (keyword) {
                              _searchCtrl.text = keyword;
                              _searchCtrl.selection =
                                  TextSelection.fromPosition(
                                    TextPosition(offset: keyword.length),
                                  );
                              setState(() => _hideClear = keyword.isNotEmpty);
                              context.read<SearchCubit>().search(
                                keyword,
                                filters: _filters,
                              );
                            },
                          );
                        } else if (state is SearchError) {
                          return const Center(
                            child: Text(
                              "Không tìm thấy",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    if (_useNativeGlass) {
      return _buildGlassSearchField();
    }

    return _buildNormalSearchField();
  }

  Widget _buildGlassSearchField() {
    return SizedBox(
      height: 46,
      child: LiquidGlassContainer(
        config: const LiquidGlassConfig(
          effect: CNGlassEffect.regular,
          shape: CNGlassEffectShape.rect,
          cornerRadius: 30,
          interactive: true,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(
                Iconsax.search_normal_1_copy,
                color: Colors.white,
                size: 21,
              ),

              const SizedBox(width: 10),

              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  focusNode: _focusNode,

                  style: const TextStyle(color: Colors.white, fontSize: 13),

                  textAlignVertical: TextAlignVertical.center,

                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm phim, diễn viên...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),

                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,

                    filled: false,

                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),

                  onChanged: (val) {
                    setState(() => _hideClear = val.isNotEmpty);
                    _onSearchChanged(val);
                  },

                  onSubmitted: (val) {
                    final q = val.trim();

                    if (q.isNotEmpty) {
                      context.read<SearchCubit>().search(q, filters: _filters);
                    }
                  },
                ),
              ),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _hideClear
                    ? GestureDetector(
                        key: const ValueKey('clear'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          setState(() {
                            _searchCtrl.clear();
                            _hideClear = false;
                          });

                          context.read<SearchCubit>().clearSearch();
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Iconsax.tag_cross_copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : const SizedBox(key: ValueKey('empty'), width: 36),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNormalSearchField() {
    return TextField(
      controller: _searchCtrl,
      focusNode: _focusNode,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Tìm kiếm phim, diễn viên...',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        prefixIcon: const Icon(
          Iconsax.search_normal_1_copy,
          color: Colors.white,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColor.firstColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        isDense: true,
        suffixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutBack,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _hideClear
              ? IconButton(
                  key: const ValueKey('clear'),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _searchCtrl.clear();
                      _hideClear = false;
                    });
                    context.read<SearchCubit>().clearSearch();
                  },
                  icon: const Icon(Iconsax.tag_cross_copy),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ),
      onChanged: (val) {
        setState(() => _hideClear = val.isNotEmpty);
        _onSearchChanged(val);
      },
      onSubmitted: (val) {
        final q = val.trim();
        if (q.isNotEmpty) {
          context.read<SearchCubit>().search(q, filters: _filters);
        }
      },
    );
  }

  Widget _buildFilterButton() {
    final isActive = _filters.isActive;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Bộ lọc tìm kiếm',
          onPressed: _openFilterSheet,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isActive
                    ? AppColor.secondColor
                    : Colors.white.withValues(alpha: 0.3),
              ),
            ),
          ),
          icon: Icon(
            Iconsax.filter_copy,
            color: isActive ? AppColor.secondColor : Colors.white,
          ),
        ),
        if (isActive)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Color(0xffF1D775),
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
