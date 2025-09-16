import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:movie_app/common/helpers/navigation/app_navigation.dart';
import 'package:movie_app/common/helpers/sort_map.dart';
import 'package:movie_app/feature/home/data/models/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_state.dart';
import 'package:movie_app/feature/moviePagination/all_movie_page.dart';

class GenreBottomSheet extends StatefulWidget {
  const GenreBottomSheet({super.key});

  static Future<void> show(BuildContext context) async {
    return await showModalBottomSheet(
      sheetAnimationStyle: AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
      ),
      isScrollControlled:
          true, //mặc định chiếm 50% màn hình nhưng muón chiếm toàn bộ container thì set true
      context: context,
      builder: (context) => GenreBottomSheet(),
    );
  }

  @override
  State<GenreBottomSheet> createState() => _GenreBottomSheetState();
}

class _GenreBottomSheetState extends State<GenreBottomSheet> {
  bool expandSort = false;
  List<bool> isSelectedGenre = [];
  List<bool> isSelectedLang = List.filled(SortMap.sortLangMap.length, false);
  List<bool> isSelectedTime = List.filled(2, false);
  String? typeList;
  String? lang;
  String? sortField;
  
  @override
  void initState() {
    super.initState();
    final genreCubit = context.read<GenreCubit>();

    if (genreCubit.state is GenreMovieSuccess) {
      final genreLengh =
          (genreCubit.state as GenreMovieSuccess).genreMovie.length;
      isSelectedGenre = List<bool>.filled(genreLengh, false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: BlocBuilder<GenreCubit, GenreState>(
        builder: (context, state) {
          if (state is GenreMovieSuccess) {
            // Đồng bộ isSelectedGenre nếu cần
            if (isSelectedGenre.length != state.genreMovie.length) {
              isSelectedGenre = List<bool>.filled(
                state.genreMovie.length,
                false,
              );
            }
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
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment
                            .start, //CĂN CHỈNH CÁC ITEM TRONG 1 DÒNG HOẶC CỘT
                        children: List.generate(state.genreMovie.length, (
                          index,
                        ) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if(isSelectedGenre[index]){
                                  
                                  isSelectedGenre[index] =!isSelectedGenre[index];  
                                } else {
                                  isSelectedGenre = List<bool>.filled(state.genreMovie.length,false);
                                  isSelectedGenre[index] = !isSelectedGenre[index];
                                }
                              });
                              
                              print(state.genreMovie[index].slug);
                            },
                            child: AnimatedContainer(
                              curve: Curves.easeInOut,
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelectedGenre[index]
                                      ? Color(0xffF1D775)
                                      : Color(0xff5E6070),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AnimatedDefaultTextStyle(
                                curve: Curves.easeInOut,
                                duration: Duration(milliseconds: 200),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelectedGenre[index]
                                      ? Color(0xffF1D775)
                                      : Colors.white,
                                ),
                                child: Text(state.genreMovie[index].name),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
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
                            isSelectedLang = List.filled(3, false);
                            isSelectedTime = List.filled(2 , false);
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
                        child: expandSort ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Language',
                              style: TextStyle(fontWeight: FontWeight.w700),
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
                                          if(isSelectedLang[index]) {
                                            isSelectedLang[index] = !isSelectedLang[index];
                                          } else {
                                            isSelectedLang = List<bool>.filled(3, false);
                                            isSelectedLang[index] = !isSelectedLang[index];
                                          }
                                        });
                                        print(
                                          SortMap
                                              .sortLangMap[index]
                                              .keys
                                              .single,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        curve: Curves.easeInOut,
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelectedLang[index]
                                                ? Color(0xffF1D775)
                                                : Color(0xff5E6070),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: AnimatedDefaultTextStyle(
                                          curve: Curves.easeInOut,
                                          duration: Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelectedLang[index]
                                                ? Color(0xffF1D775)
                                                : Colors.white,
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
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              'Sắp xếp',
                              style: TextStyle(fontWeight: FontWeight.w700),
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
                                          if(isSelectedTime[index]) {
                                            isSelectedTime[index] = !isSelectedTime[index];
                                          } else {
                                            isSelectedTime = List<bool>.filled(3, false);
                                            isSelectedTime[index] = !isSelectedTime[index];
                                          }
                                        });
                                        print(
                                          SortMap.sortFieldMap[index].keys.single,
                                        );
                                      },
                                      child: AnimatedContainer(
                                        curve: Curves.easeInOut,
                                        duration: Duration(milliseconds: 200),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelectedTime[index]
                                                ? Color(0xffF1D775)
                                                : Color(0xff5E6070),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: AnimatedDefaultTextStyle(
                                          curve: Curves.easeInOut,
                                          duration: Duration(milliseconds: 200),
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: isSelectedTime[index]
                                                ? Color(0xffF1D775)
                                                : Colors.white,
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
                        ) : SizedBox(),
                      ),
                    ) 
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
                        String? lang;
                        String? time;
                        String? typeList;
                        final selectedGenre = isSelectedGenre.indexWhere((selected) => selected);
                        final selectedLang = isSelectedLang.indexWhere((selected) => selected);
                        final selectedTime = isSelectedTime.indexWhere((selected) => selected);
                        if(selectedTime != -1) {
                          time = SortMap.sortFieldMap[selectedTime].keys.single;
                        }
                        if(selectedLang != -1) {
                          lang = SortMap.sortLangMap[selectedLang].keys.single;
                        }
                        if(selectedGenre != -1) {
                          typeList = state.genreMovie[selectedGenre].slug;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bạn chưa chọn type'),));
                          return;
                        }
                        
                        FillterGenreMovieReq fillterResult = FillterGenreMovieReq(
                              typeList: typeList,
                              sortField: time,
                              sortLang: lang
                            );
                        AppNavigator.pushReplacement(
                            context,
                            AllMoviePage(
                              fillterReq: fillterResult
                            )
                          );
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
          }
          return SizedBox.shrink();
        },
      ),
    );
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