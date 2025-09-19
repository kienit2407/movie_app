import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/common/helpers/sort_map.dart';
import 'package:movie_app/core/config/themes/app_color.dart';
import 'package:movie_app/feature/home/domain/entities/fillterType.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/genre_movie_entity.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_state.dart';
import 'package:movie_app/feature/movie_pagination/presentation/pages/all_movie_page.dart';
import 'package:shimmer/shimmer.dart';

class GenreBottomSheet extends StatefulWidget {
  const GenreBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    return await showModalBottomSheet(
      sheetAnimationStyle: AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
      ),
      isScrollControlled:true, //mặc định chiếm 50% màn hình nhưng muón chiếm toàn bộ container thì set true
      context: context,
      builder: (context) => GenreBottomSheet(),
    );
  }

  @override
  State<GenreBottomSheet> createState() => _GenreBottomSheetState();
}

class _GenreBottomSheetState extends State<GenreBottomSheet> {
  bool expandSort = false;
  int isSelectedGenre = 0;
  int isSelectedLang = 0;
  int isSelectedTime = 0;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: BlocConsumer<GenreCubit, GenreState>(
        listener: (context, state) {

        },
        builder: (context, state) {
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
                Container(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: 100,
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Iconsax.category),
                      Text(
                        'Thể loại',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: MediaQuery.of(context).size.height * .2,
                  // color: Colors.amber,
                  width: double.infinity,
                  child: _buildGenreContent(state),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Divider(thickness: .3, color: Color(0xff5E6070)),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          expandSort = !expandSort;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          spacing: 5,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Watch More',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xffF1D775),
                              ),
                            ),
                            Icon(
                              expandSort
                                  ? Iconsax.arrow_down_1_copy
                                  : Iconsax.arrow_up_2_copy,
                              size: 13,
                              color: Color(0xffF1D775),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(thickness: .3, color: Color(0xff5E6070)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                //Sort
                // AnimatedCrossFade -> có thể để hiển thị chuyển đổi giữa 2 widget
                //AnimateSize -> cách 2
                AnimatedSize(
                  curve: Curves.easeInOut,
                  duration: Duration(milliseconds: 200),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: expandSort
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  spacing: 5,
                                  children: [
                                    Icon(Iconsax.translate_copy, size: 18),
                                    Text(
                                      'Language',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment
                                        .start, //CĂN CHỈNH CÁC ITEM TRONG 1 DÒNG HOẶC CỘT
                                    children: List.generate(
                                      SortMap.sortLangMap.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              
                                            });
                                          },
                                          child: AnimatedContainer(
                                            curve: Curves.easeInOut,
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: BoxBorder.all(color: Color(0xff5E6070)),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              curve: Curves.easeInOut,
                                              duration: Duration(
                                                milliseconds: 200,
                                              ),
                                              style: TextStyle(
                                                fontSize: 10,
                                                // color: isSelectedLang[index]
                                                //     ? Color(0xffF1D775)
                                                //     :
                                                   color:  Colors.white,
                                              ),
                                              child: Text(
                                                SortMap
                                                    .sortLangMap[index]
                                                    .values
                                                    .single,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  spacing: 5,
                                  children: [
                                    Icon(Iconsax.sort_copy, size: 18),
                                    Text(
                                      'Sort',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    
                                  ],
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    alignment: WrapAlignment
                                        .start, //CĂN CHỈNH CÁC ITEM TRONG 1 DÒNG HOẶC CỘT
                                    children: List.generate(
                                      SortMap.sortFieldMap.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              
                                            });
                                            print(
                                              SortMap
                                                  .sortFieldMap[index]
                                                  .keys
                                                  .single,
                                            );
                                          },
                                          child: AnimatedContainer(
                                            curve: Curves.easeInOut,
                                            duration: Duration(
                                              milliseconds: 200,
                                            ),
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                // color: isSelectedTime[index]
                                                //     ? Color(0xffF1D775)
                                                //     : Color(0xff5E6070),
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: AnimatedDefaultTextStyle(
                                              curve: Curves.easeInOut,
                                              duration: Duration(
                                                milliseconds: 200,
                                              ),
                                              style: TextStyle(
                                                fontSize: 10,
                                                // color: isSelectedTime[index]
                                                //     ? Color(0xffF1D775)
                                                //     : Colors.white,
                                              ),
                                              child: Text(
                                                SortMap
                                                    .sortFieldMap[index]
                                                    .values
                                                    .single,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : SizedBox(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                //Button going to send the Req to Server
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Color(0xffF1D775),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      minimumSize: Size.fromHeight(40),
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      
                    },
                    child: Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lọc kết quả',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        Icon(Iconsax.arrow_right_1_copy),
                      ],
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

  Widget _buildGenreList(GenreMovieSuccess state) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment:
            WrapAlignment.start, //CĂN CHỈNH CÁC ITEM TRONG 1 DÒNG HOẶC CỘT
        children: List.generate(state.genreMovie.length, (index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                isSelectedGenre = index;
              });
            },
            child: AnimatedContainer(
              curve: Curves.easeInOut,
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  // color: isSelectedGenre[index]
                  //     ? Color(0xffF1D775)
                  //     : Color(0xff5E6070),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedDefaultTextStyle(
                curve: Curves.easeInOut,
                duration: Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 10,
                  // color: isSelectedGenre[index]
                  //     ? Color(0xffF1D775)
                  //     : Colors.white,
                ),
                child: Text(state.genreMovie[index].name),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildGenreShimmer() {
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

  Widget _buildGenreContent(GenreState state) {
    if (state is GenreMovieLoading) {
      return _buildGenreShimmer();
    } else if (state is GenreMovieSuccess) {
      return _buildGenreList(state);
    }
    // Initial state cũng hiển thị shimmer thay vì shrink
    return _buildGenreShimmer();
  }
}
// // Tạo base states có thể tái sử dụng
// abstract class DataState<T> extends Equatable {
//   const DataState();
// }

// class DataInitial<T> extends DataState<T> {
//   @override
//   List<Object> get props => [];
// }

// class DataLoading<T> extends DataState<T> {
//   @override
//   List<Object> get props => [];
// }

// class DataSuccess<T> extends DataState<T> {
//   final T data;
//   const DataSuccess(this.data);
  
//   @override
//   List<Object> get props => [data];
// }

// class DataFailure<T> extends DataState<T> {
//   final String message;
//   const DataFailure(this.message);
  
//   @override
//   List<Object> get props => [message];
// }