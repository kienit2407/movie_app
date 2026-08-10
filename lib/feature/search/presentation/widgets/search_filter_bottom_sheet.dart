import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/list_year.dart';
import 'package:movie_app/common/helpers/sort_map.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_state.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_state.dart';
import 'package:movie_app/feature/search/domain/entities/search_filter_params.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final SearchFilterParams initialFilters;

  const SearchFilterBottomSheet({super.key, required this.initialFilters});

  static Future<SearchFilterParams?> show(
    BuildContext context, {
    required SearchFilterParams initialFilters,
  }) {
    return showModalBottomSheet<SearchFilterParams>(
      useRootNavigator: true,
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .82,
      ),
      builder: (_) => SearchFilterBottomSheet(initialFilters: initialFilters),
    );
  }

  @override
  State<SearchFilterBottomSheet> createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  late SearchFilterParams _filters;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _genreScrollController = ScrollController();
  final ScrollController _countryScrollController = ScrollController();
  final ScrollController _yearScrollController = ScrollController();

  bool _expandSortField = false;
  bool _expandSortType = false;
  bool _expandLanguage = false;
  bool _expandGenre = false;
  bool _expandCountry = false;
  bool _expandYear = false;

  static const _sortTypeOptions = [
    {'slug': 'desc', 'name': 'Giảm dần'},
    {'slug': 'asc', 'name': 'Tăng dần'},
  ];

  static const _sortFieldOptions = [
    {'slug': '_id', 'name': 'Xem nhiều'},
    {'slug': 'modified.time', 'name': 'Mới nhất'},
    {'slug': 'year', 'name': 'Năm phát hành'},
  ];

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _genreScrollController.dispose();
    _countryScrollController.dispose();
    _yearScrollController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() => _filters = SearchFilterParams.defaults);
  }

  void _apply() {
    Navigator.pop(context, _filters);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * .7;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xff2F3345),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildToggle(),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight - 54),
              child: Scrollbar(
                thickness: 4,
                controller: _scrollController,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTitleRow(),
                      _buildSectionHeader(
                        icon: Iconsax.sort_copy,
                        title: 'Sắp xếp',
                        selectedLabel: _sortFieldLabel,
                        isExpand: _expandSortField,
                        onTap: () => setState(
                          () => _expandSortField = !_expandSortField,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildChipPanel(
                        isExpanded: _expandSortField,
                        height: 54,
                        child: _buildStringChips(
                          options: _sortFieldOptions,
                          selected: _filters.sortField,
                          onSelected: (slug) => setState(
                            () => _filters = _filters.copyWith(sortField: slug),
                          ),
                        ),
                      ),
                      _buildSectionHeader(
                        icon: Iconsax.arrow_swap_horizontal,
                        title: 'Chiều sắp xếp',
                        selectedLabel: _sortTypeLabel,
                        isExpand: _expandSortType,
                        onTap: () =>
                            setState(() => _expandSortType = !_expandSortType),
                      ),
                      const SizedBox(height: 10),
                      _buildChipPanel(
                        isExpanded: _expandSortType,
                        height: 54,
                        child: _buildStringChips(
                          options: _sortTypeOptions,
                          selected: _filters.sortType,
                          onSelected: (slug) => setState(
                            () => _filters = _filters.copyWith(sortType: slug),
                          ),
                        ),
                      ),
                      _buildSectionHeader(
                        icon: Iconsax.translate_copy,
                        title: 'Ngôn ngữ',
                        selectedLabel: _languageLabel,
                        isExpand: _expandLanguage,
                        onTap: () =>
                            setState(() => _expandLanguage = !_expandLanguage),
                      ),
                      const SizedBox(height: 10),
                      _buildChipPanel(
                        isExpanded: _expandLanguage,
                        height: 54,
                        child: _buildStringChips(
                          options: SortMap.sortLangMap
                              .map(
                                (item) => {
                                  'slug': item.keys.single.toString(),
                                  'name': item.values.single.toString(),
                                },
                              )
                              .toList(),
                          selected: _filters.sortLang,
                          allowClear: true,
                          onSelected: (slug) => setState(
                            () => _filters = _filters.copyWith(
                              sortLang: slug,
                              clearSortLang: slug == null,
                            ),
                          ),
                        ),
                      ),
                      _buildGenreSection(),
                      _buildCountrySection(),
                      _buildSectionHeader(
                        icon: Iconsax.calendar,
                        title: 'Năm',
                        selectedLabel: _filters.year,
                        isExpand: _expandYear,
                        onTap: () => setState(() => _expandYear = !_expandYear),
                      ),
                      const SizedBox(height: 10),
                      _buildScrollableChipPanel(
                        isExpanded: _expandYear,
                        controller: _yearScrollController,
                        child: _buildStringChips(
                          options: YearHelper.getYears()
                              .map((year) => {'slug': year, 'name': year})
                              .toList(),
                          selected: _filters.year,
                          allowClear: true,
                          onSelected: (slug) => setState(
                            () => _filters = _filters.copyWith(
                              year: slug,
                              clearYear: slug == null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: _buildApplyButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _sortFieldLabel =>
      _labelFromOptions(_sortFieldOptions, _filters.sortField);

  String get _sortTypeLabel =>
      _labelFromOptions(_sortTypeOptions, _filters.sortType);

  String? get _languageLabel {
    if (_filters.sortLang == null) return null;
    return SortMap.sortLangMap
        .firstWhere(
          (item) => item.containsKey(_filters.sortLang),
          orElse: () => {_filters.sortLang!: _filters.sortLang!},
        )
        .values
        .first;
  }

  String _labelFromOptions(List<Map<String, String>> options, String slug) {
    return options.firstWhere(
      (item) => item['slug'] == slug,
      orElse: () => {'slug': slug, 'name': slug},
    )['name']!;
  }

  Widget _buildToggle() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: 100,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      child: Row(
        children: [
          const Icon(Iconsax.filter, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Bộ lọc tìm kiếm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: _reset,
            child: const Text(
              'Đặt lại',
              style: TextStyle(color: Color(0xffF1D775)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isExpand,
    required VoidCallback onTap,
    String? selectedLabel,
  }) {
    final hasSelected = selectedLabel != null && selectedLabel.isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: Colors.white),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      hasSelected ? selectedLabel : 'Tất cả',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        color: hasSelected
                            ? const Color(0xffF1D775)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Icon(
                    isExpand
                        ? Iconsax.arrow_down_1_copy
                        : Iconsax.arrow_right_3_copy,
                    size: 13,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChipPanel({
    required bool isExpanded,
    required double height,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: isExpanded ? height : 0,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: isExpanded ? child : const SizedBox.shrink(),
    );
  }

  Widget _buildScrollableChipPanel({
    required bool isExpanded,
    required ScrollController controller,
    required Widget child,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: isExpanded ? MediaQuery.of(context).size.height * .25 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: isExpanded
          ? Scrollbar(
              thickness: 4,
              thumbVisibility: true,
              controller: controller,
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: child,
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildStringChips({
    required List<Map<String, String>> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
    bool allowClear = false,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((item) {
        final slug = item['slug']!;
        final label = item['name']!;
        final isSelected = selected == slug;

        return ChoiceChip(
          showCheckmark: false,
          side: BorderSide(
            color: isSelected
                ? const Color(0xffF1D775)
                : const Color(0xff5E6070),
          ),
          backgroundColor: const Color(0xff2F3345),
          selectedColor: const Color(0xff2F3345),
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xffF1D775) : Colors.white,
              fontSize: 10,
            ),
          ),
          labelPadding: const EdgeInsets.symmetric(horizontal: 2),
          visualDensity: VisualDensity.comfortable,
          selected: isSelected,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: (_) {
            if (isSelected && allowClear) {
              onSelected(null);
              return;
            }
            onSelected(slug);
          },
        );
      }).toList(),
    );
  }

  Widget _buildGenreSection() {
    return BlocBuilder<GenreCubit, GenreState>(
      builder: (context, state) {
        String? selectedGenreName;
        if (_filters.category != null && state is GenreMovieSuccess) {
          for (final genre in state.genreMovie) {
            if (genre.slug == _filters.category) {
              selectedGenreName = genre.name;
              break;
            }
          }
        }

        final header = _buildSectionHeader(
          icon: Iconsax.filter,
          title: 'Thể loại',
          selectedLabel: selectedGenreName ?? _filters.category,
          isExpand: _expandGenre,
          onTap: () => setState(() => _expandGenre = !_expandGenre),
        );

        if (state is! GenreMovieSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 10),
              _buildChipPanel(
                isExpanded: _expandGenre,
                height: 44,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Đang tải thể loại...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 10),
            _buildScrollableChipPanel(
              isExpanded: _expandGenre,
              controller: _genreScrollController,
              child: _buildStringChips(
                options: state.genreMovie
                    .map((genre) => {'slug': genre.slug, 'name': genre.name})
                    .toList(),
                selected: _filters.category,
                allowClear: true,
                onSelected: (slug) => setState(
                  () => _filters = _filters.copyWith(
                    category: slug,
                    clearCategory: slug == null,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCountrySection() {
    return BlocBuilder<CountryMovieCubit, CountryMovieState>(
      builder: (context, state) {
        String? selectedCountryName;
        if (_filters.country != null && state is CountryMovieSuccess) {
          for (final country in state.countryMovie) {
            if (country.slug == _filters.country) {
              selectedCountryName = country.name;
              break;
            }
          }
        }

        final header = _buildSectionHeader(
          icon: Iconsax.global,
          title: 'Quốc gia',
          selectedLabel: selectedCountryName ?? _filters.country,
          isExpand: _expandCountry,
          onTap: () => setState(() => _expandCountry = !_expandCountry),
        );

        if (state is! CountryMovieSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              const SizedBox(height: 10),
              _buildChipPanel(
                isExpanded: _expandCountry,
                height: 44,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'Đang tải quốc gia...',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 10),
            _buildScrollableChipPanel(
              isExpanded: _expandCountry,
              controller: _countryScrollController,
              child: _buildStringChips(
                options: state.countryMovie
                    .map(
                      (country) => {'slug': country.slug, 'name': country.name},
                    )
                    .toList(),
                selected: _filters.country,
                allowClear: true,
                onSelected: (slug) => setState(
                  () => _filters = _filters.copyWith(
                    country: slug,
                    clearCountry: slug == null,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildApplyButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC77DFF), Color(0xFFFF9E9E), Color(0xFFFFD275)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFC77DFF).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _apply,
          borderRadius: BorderRadius.circular(12),
          child: const SizedBox(
            height: 50,
            child: Center(
              child: Text(
                'Áp dụng bộ lọc',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
