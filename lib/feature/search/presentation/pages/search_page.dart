import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_state.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_history_view.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_result_view.dart';
import 'package:movie_app/feature/search/presentation/widgets/search_shimmer_loading.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<SearchCubit>(),
      child: const _SearchPageView(),
    );
  }
}

class _SearchPageView extends StatefulWidget {
  const _SearchPageView();

  @override
  State<_SearchPageView> createState() => _SearchPageViewState();
}

class _SearchPageViewState extends State<_SearchPageView> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  bool _hideClear = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    // gần đáy thì load more
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      final cubit = context.read<SearchCubit>();
      final state = cubit.state;

      if (state is SearchLoaded) {
        // ✅ còn trang + không đang load more mới gọi
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
        cubit.search(q);
      }
    });
  }

  @override
  void dispose() {
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
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColor.bgApp,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColor.firstColor.withOpacity(.4),
                          AppColor.firstColor.withOpacity(.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Iconsax.arrow_left_2_copy,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            focusNode: _focusNode,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Tìm kiếm phim, diễn viên...',
                              hintStyle: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                              prefixIcon: const Icon(
                                Iconsax.search_normal_1_copy,
                                color: Colors.white,
                              ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.1),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColor.firstColor,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              isDense: true,
                              suffixIcon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                switchInCurve: Curves.easeOutBack,
                                transitionBuilder: (child, animation) =>
                                    ScaleTransition(
                                      scale: animation,
                                      child: child,
                                    ),
                                child: _hideClear
                                    ? IconButton(
                                        key: const ValueKey('clear'),
                                        color: Colors.white,
                                        onPressed: () {
                                          setState(() {
                                            _searchCtrl.clear();
                                            _hideClear = false;
                                          });
                                          context
                                              .read<SearchCubit>()
                                              .clearSearch();
                                        },
                                        icon: const Icon(
                                          Iconsax.tag_cross_copy,
                                        ),
                                      )
                                    : const SizedBox.shrink(
                                        key: ValueKey('empty'),
                                      ),
                              ),
                            ),
                            onChanged: (val) {
                              setState(() => _hideClear = val.isNotEmpty);
                              _onSearchChanged(val);
                            },
                            onSubmitted: (val) {
                              final q = val.trim();
                              if (q.isNotEmpty) {
                                context.read<SearchCubit>().search(q);
                              }
                            },
                          ),
                        ),
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
                              context.read<SearchCubit>().search(keyword);
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
            ],
          ),
        ),
      ),
    );
  }
}
