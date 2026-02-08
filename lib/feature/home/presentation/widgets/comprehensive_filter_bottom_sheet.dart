import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/common/helpers/list_year.dart';
import 'package:movie_app/common/helpers/sort_map.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_state.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_state.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';
import 'package:shimmer/shimmer.dart';

class ComprehensiveFilterBottomSheet extends StatefulWidget {
  const ComprehensiveFilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    return await showModalBottomSheet(
      sheetAnimationStyle: const AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
      ),
      isScrollControlled: true,
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * .8,
      ),
      builder: (context) => const ComprehensiveFilterBottomSheet(),
    );
  }

  @override
  State<ComprehensiveFilterBottomSheet> createState() =>
      _ComprehensiveFilterBottomSheetState();
}

class _ComprehensiveFilterBottomSheetState
    extends State<ComprehensiveFilterBottomSheet> {
  String? selectedGenre;
  String? selectedLanguage;
  String? selectedSortField;
  String? selectedType;
  String? selectedCountry;
  String? selectedYear;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _yearScrollController = ScrollController();
  final ScrollController _languageScrollController = ScrollController();
  final ScrollController _sortFieldScrollController = ScrollController();
  final ScrollController _genreScrollController = ScrollController();
  final ScrollController _countryScrollController = ScrollController();

  bool expandCountry = false;
  bool expandYear = false;
  bool expandLanguage = false;
  bool expandSortField = false;
  bool expandGenre = false;
  bool expandSort = false;

  static const List<Map<String, String>> typeList = [
    {'slug': 'phim-bo', 'name': 'Phim Bộ'},
    {'slug': 'phim-le', 'name': 'Phim Lẻ'},
    {'slug': 'hoat-hinh', 'name': 'Hoạt Hình'},
    {'slug': 'tv-shows', 'name': 'TV Shows'},
    {'slug': 'phim-vietsub', 'name': 'Phim Vietsub'},
    {'slug': 'phim-thuyet-minh', 'name': 'Phim Thuyết Minh'},
    {'slug': 'phim-long-tieng', 'name': 'Phim Lồng Tiếng'},
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _yearScrollController.dispose();
    _languageScrollController.dispose();
    _sortFieldScrollController.dispose();
    _genreScrollController.dispose();
    _countryScrollController.dispose();
    super.dispose();
  }

  void _handleFiltedResult() {
    if (selectedType == null) {
      showWarningDialog();
      return;
    }
    final filteredResult = FillterMovieReq(
      typeList: selectedType ?? 'phim-bo',
      page: '1',
      sortField: selectedSortField ?? '_id',
      sortType: 'desc',
      sortLang: selectedLanguage,
      year: selectedYear,
      category: selectedGenre,
      country: selectedCountry,
      limit: '64',
      fillterType: Filltertype.list,
    );
    AppNavigator.push(context, AllMoviePage(fillterReq: filteredResult));
  }

  void showWarningDialog() {
    showAnimatedDialog(
      context: context,
      dialog: AppAlertDialog(
        content: "Làm ơn hãy chọn loại phim !",
        title: 'Chú ý!',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * .7;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: BlocConsumer<GenreCubit, GenreState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xff2F3345),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(alignment: Alignment.topCenter, child: _buildToggle()),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight - 60),
                  child: Scrollbar(
                    thickness: 4,
                    controller: _scrollController,
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          _buildSectionHeader(
                            Iconsax.category,
                            'Loại phim',
                            selectedType,
                            false,
                            displayName: selectedType != null
                                ? typeList.firstWhere(
                                    (t) => t['slug'] == selectedType,
                                    orElse: () => {
                                      'slug': '',
                                      'name': selectedType!,
                                    },
                                  )['name']
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _buildTypeFilter(),

                          BlocConsumer<CountryMovieCubit, CountryMovieState>(
                            listener: (context, state) {},
                            builder: (context, countryState) {
                              return _buildSectionHeader(
                                Iconsax.global,
                                'Quốc gia',
                                selectedCountry,
                                expandCountry,
                                displayName:
                                    selectedCountry != null &&
                                        countryState is CountryMovieSuccess
                                    ? countryState.countryMovie
                                          .firstWhere(
                                            (c) => c.slug == selectedCountry,
                                            orElse: () =>
                                                countryState.countryMovie.first,
                                          )
                                          .name
                                    : null,
                                onTap: () {
                                  setState(() {
                                    expandCountry = !expandCountry;
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildCountryFilter(),

                          _buildSectionHeader(
                            Iconsax.calendar,
                            'Năm',
                            selectedYear,
                            expandYear,
                            onTap: () {
                              setState(() {
                                expandYear = !expandYear;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildYearFilter(),

                          _buildSectionHeader(
                            Iconsax.translate_copy,
                            'Ngôn ngữ',
                            selectedLanguage,
                            expandLanguage,
                            onTap: () {
                              setState(() {
                                expandLanguage = !expandLanguage;
                              });
                            },
                            displayName: selectedLanguage != null
                                ? SortMap.sortLangMap
                                      .firstWhere(
                                        (s) => s.containsKey(selectedLanguage),
                                        orElse: () => {
                                          selectedLanguage!: selectedLanguage!,
                                        },
                                      )
                                      .values
                                      .first
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _buildLanguageFilter(),

                          _buildSectionHeader(
                            Iconsax.sort_copy,
                            'Sắp xếp',
                            selectedSortField,
                            onTap: () {
                              setState(() {
                                expandSort = !expandSort;
                              });
                            },
                            expandSortField,
                            displayName: selectedSortField != null
                                ? SortMap.sortFieldMap
                                      .firstWhere(
                                        (s) => s.containsKey(selectedSortField),
                                        orElse: () => {
                                          selectedSortField!:
                                              selectedSortField!,
                                        },
                                      )
                                      .values
                                      .first
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _buildSortFieldFilter(),

                          _buildSectionHeader(
                            Iconsax.filter,
                            'Thể loại',
                            selectedGenre,
                            expandGenre,
                            displayName:
                                selectedGenre != null &&
                                    state is GenreMovieSuccess &&
                                    state.genreMovie.isNotEmpty
                                ? state.genreMovie
                                      .firstWhere(
                                        (g) => g.slug == selectedGenre,
                                        orElse: () => state.genreMovie.first,
                                      )
                                      .name
                                : null,
                            onTap: () {
                              setState(() {
                                expandGenre = !expandGenre;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          _buildGenreContent(state),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFC77DFF),
                                  Color(0xFFFF9E9E),
                                  Color(0xFFFFD275),
                                ],
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
                                onTap: _handleFiltedResult,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  height: 50,
                                  alignment: Alignment.center,
                                  child: const Text(
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
                          SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    IconData icon,
    String title,
    String? selected,
    bool isExpand, {
    String? displayName,
    isExceptedExpand = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white.withOpacity(0.12)),
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
                Icon(icon, size: 16),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            isExceptedExpand
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        (displayName ?? selected) == null ||
                                (displayName ?? selected)!.isEmpty
                            ? "Tất cả"
                            : (displayName ?? selected)!,
                        style: TextStyle(
                          fontSize: 10,
                          color:
                              (displayName ?? selected) == null ||
                                  (displayName ?? selected)!.isEmpty
                              ? Colors.white
                              : const Color(0xffF1D775),
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
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(vertical: 5),
      width: 100,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey,
      ),
    );
  }

  Widget _buildTypeFilter() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(
          spacing: 8,
          alignment: WrapAlignment.start,
          children: List.generate(typeList.length, (index) {
            final slug = typeList[index]['slug'] as String;
            final label = typeList[index]['name'] as String;
            final bool isSelected = selectedType == slug;
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
              pressElevation: 2.0,
              visualDensity: VisualDensity.comfortable,
              selected: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (value) {
                setState(() {
                  selectedType = isSelected ? null : slug;
                });
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildYearFilter() {
    final years = YearHelper.getYears();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: expandYear ? MediaQuery.of(context).size.height * .25 : 0,
      child: Scrollbar(
        thickness: 4,
        thumbVisibility: true,
        controller: _yearScrollController,
        child: SingleChildScrollView(
          controller: _yearScrollController,
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: years.map((year) {
              final bool isSelected = selectedYear == year;

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
                  year,
                  style: TextStyle(
                    color: isSelected ? const Color(0xffF1D775) : Colors.white,
                    fontSize: 10,
                  ),
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                pressElevation: 2.0,
                visualDensity: VisualDensity.compact,
                selected: isSelected,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) {
                  setState(() {
                    selectedYear = isSelected ? null : year;
                  });
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageFilter() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: expandLanguage ? 50 : 0,
      child: Scrollbar(
        thickness: 4,
        thumbVisibility: true,
        controller: _languageScrollController,
        child: SingleChildScrollView(
          controller: _languageScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Wrap(
            spacing: 10,
            alignment: WrapAlignment.start,
            children: List.generate(SortMap.sortLangMap.length, (index) {
              final slug = SortMap.sortLangMap[index].keys.single;
              final bool isSelected = selectedLanguage == slug;
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
                  SortMap.sortLangMap[index].values.single,
                  style: TextStyle(
                    color: isSelected ? const Color(0xffF1D775) : Colors.white,
                    fontSize: 10,
                  ),
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                pressElevation: 2.0,
                visualDensity: VisualDensity.comfortable,
                selected: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) {
                  setState(() {
                    selectedLanguage = isSelected ? null : slug;
                  });
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSortFieldFilter() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: expandSort ? 50 : 0,
      child: Scrollbar(
        thickness: 4,
        thumbVisibility: true,
        controller: _sortFieldScrollController,
        child: SingleChildScrollView(
          controller: _sortFieldScrollController,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.start,
            children: List.generate(SortMap.sortFieldMap.length, (index) {
              final slug = SortMap.sortFieldMap[index].keys.single;
              final bool isSelected = selectedSortField == slug;
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
                  SortMap.sortFieldMap[index].values.single,
                  style: TextStyle(
                    color: isSelected ? const Color(0xffF1D775) : Colors.white,
                    fontSize: 10,
                  ),
                ),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                pressElevation: 2.0,
                visualDensity: VisualDensity.comfortable,
                selected: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                onSelected: (value) {
                  setState(() {
                    selectedSortField = isSelected ? null : slug;
                  });
                },
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreContent(GenreState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: expandGenre ? MediaQuery.of(context).size.height * .25 : 0,
      child: _buildGenreContentChild(state),
    );
  }

  Widget _buildGenreContentChild(GenreState state) {
    if (!expandGenre) return const SizedBox.shrink();

    if (state is GenreMovieLoading) {
      return _buildGenreShimmer();
    } else if (state is GenreMovieSuccess) {
      return _buildGenreList(state);
    }
    return _buildGenreShimmer();
  }

  Widget _buildGenreList(GenreMovieSuccess state) {
    return Scrollbar(
      thickness: 4,
      thumbVisibility: true,
      controller: _genreScrollController,
      child: SingleChildScrollView(
        controller: _genreScrollController,
        child: Wrap(
          spacing: 8,
          alignment: WrapAlignment.start,
          children: List.generate(state.genreMovie.length, (index) {
            final slug = state.genreMovie[index].slug;
            final bool isSelected = selectedGenre == slug;
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
                state.genreMovie[index].name,
                style: TextStyle(
                  color: isSelected ? const Color(0xffF1D775) : Colors.white,
                  fontSize: 10,
                ),
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              pressElevation: 2.0,
              visualDensity: VisualDensity.comfortable,
              selected: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (value) {
                setState(() {
                  selectedGenre = isSelected ? null : slug;
                });
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCountryFilter() {
    return BlocConsumer<CountryMovieCubit, CountryMovieState>(
      listener: (context, state) {},
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: expandCountry ? MediaQuery.of(context).size.height * .25 : 0,
          child: _buildStateManagement(state),
        );
      },
    );
  }

  Widget _buildStateManagement(CountryMovieState state) {
    if (!expandCountry) return const SizedBox.shrink();

    if (state is CountryMovieSuccess) {
      return _buildCountryItem(state);
    } else if (state is CountryMovieLoading) {
      return _buildShimmer();
    }
    return _buildShimmer();
  }

  Widget _buildCountryItem(CountryMovieSuccess state) {
    return Scrollbar(
      thickness: 4,
      thumbVisibility: true,
      controller: _countryScrollController,
      child: SingleChildScrollView(
        controller: _countryScrollController,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Wrap(
          spacing: 5,
          children: List.generate(state.countryMovie.length, (index) {
            final slug = state.countryMovie[index].slug;
            final bool isSelected = selectedCountry == slug;
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
                state.countryMovie[index].name,
                style: TextStyle(
                  color: isSelected ? const Color(0xffF1D775) : Colors.white,
                  fontSize: 10,
                ),
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              pressElevation: 2.0,
              visualDensity: VisualDensity.comfortable,
              selected: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              onSelected: (value) {
                setState(() {
                  selectedCountry = isSelected ? null : slug;
                });
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.start,
        children: List.generate(
          30,
          (index) => Shimmer.fromColors(
            baseColor: AppColor.bgApp.withOpacity(.3),
            highlightColor: const Color(0xff282B39).withOpacity(.3),
            child: Container(
              width: 50 + (index % 10),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(''),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreShimmer() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.start,
      children: List.generate(
        30,
        (index) => Container(
          width: 50 + (index % 10),
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(''),
        ),
      ),
    );
  }
}
