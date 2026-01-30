import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/components/alert_dialog/app_alert_dialog.dart';
import 'package:movie_app/common/helpers/list_year.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/core/config/utils/animated_dialog.dart';
import 'package:movie_app/core/config/utils/shimmer_movie_genre.dart';
import 'package:movie_app/feature/home/domain/entities/country_movie_entity.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_state.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';
import 'package:shimmer/shimmer.dart';

class YearBottomSheet extends StatefulWidget {
  const YearBottomSheet({super.key});

  static Future show(BuildContext context) async {
    showModalBottomSheet(
      sheetAnimationStyle: AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 200),
      ),
      context: context,
      builder: (context) => YearBottomSheet(),
    );
  }

  @override
  State<YearBottomSheet> createState() => _YearBottomSheetState();
}

class _YearBottomSheetState extends State<YearBottomSheet> {
  String? selectedYear;

  @override
  void initState() {
    super.initState();
  }

  void _handleFiltedResult() {
    if (selectedYear == null) {
      _showWarningDialog();
      return;
    }

    final filteredResult = FillterMovieReq(
      typeList: selectedYear!,
      fillterType: Filltertype.year,
    );
    AppNavigator.push(context, AllMoviePage(fillterReq: filteredResult));
  }

  void _showWarningDialog() {
    showAnimatedDialog(
      context: context,
      dialog: AppAlertDialog(content: "Chọn năm để lọc!", title: 'Cảnh báo!'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CountryMovieCubit, CountryMovieState>(
      listener: (context, state) {},
      builder: (context, state) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: _buildBottomSheetContent(state),
        );
      },
    );
  }

  Widget _buildBottomSheetContent(CountryMovieState state) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(bottom: 40),
      decoration: BoxDecoration(
        color: Color(0xff2F3345),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSheetHeader(),
          _buildYearSelector(state),
          SizedBox(height: 20),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildSheetHeader() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      width: 100,
      height: 5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey,
      ),
    );
  }

  Widget _buildYearSelector(CountryMovieState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleRow(),
          const SizedBox(height: 15),
          _buildStateManagement(state),
        ],
      ),
    );
  }

  Widget _buildTitleRow() {
    return Row(
      children: [
        Icon(Iconsax.global_copy),
        SizedBox(width: 5),
        Text('Năm', style: TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildStateManagement(CountryMovieState state) {
    if (state is CountryMovieSuccess) {
      return _buildCountryItem();
    } else if (state is CountryMovieLoading) {
      return _buildShimmer();
    }
    return _buildShimmer();
  }

  Widget _buildCountryItem() {
    final years = YearHelper.getYears(); // List<String>

    return SingleChildScrollView(
      
      scrollDirection: Axis.vertical,
      physics: BouncingScrollPhysics(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColor.buttonColor), top: BorderSide(color: AppColor.buttonColor),),
          color: Color(0xff2F3345),
        ),
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
                  // click lại lần nữa thì bỏ chọn
                  selectedYear = isSelected ? null : year;
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.start,
        children: List.generate(
          30,
          (index) => Shimmer.fromColors(
            baseColor: AppColor.bgApp.withOpacity(.3),
            highlightColor: Color(0xff282B39).withOpacity(.3),
            child: Container(
              width: 50 + (index % 10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(''),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
          onTap: _handleFiltedResult,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 50,
            alignment: Alignment.center,
            child: const Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lọc kết quả',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                Icon(Iconsax.arrow_right_1_copy, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
    // Padding(
    //   padding: const EdgeInsets.symmetric(horizontal: 20),
    //   child: Container(
    //     decoration: BoxDecoration(
    //       color: Color(0xffF1D775),
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     child: ElevatedButton(
    //       style: ElevatedButton.styleFrom(
    //         foregroundColor: Colors.black,
    //         elevation: 0,
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadiusGeometry.circular(10),
    //         ),
    //         minimumSize: Size.fromHeight(40),
    //         backgroundColor: Colors.transparent,
    //       ),
    //       onPressed: _handleFiltedResult,
    //       child: Row(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           Text(
    //             'Lọc kết quả',
    //             style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
    //           ),
    //           Icon(Iconsax.arrow_right_1_copy),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
