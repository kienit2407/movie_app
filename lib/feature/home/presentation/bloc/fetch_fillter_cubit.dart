import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/data/models/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/usecase/get_fillter_genre.dart';
import 'package:movie_app/feature/home/presentation/bloc/fetch_fillter_state.dart';

class FetchFillterCubit extends Cubit<FetchFillterState>  {
  FetchFillterCubit() : super(FetchFillterInitial());
  int _currentPage = 1;
  List<ItemEntity> _allItems = [];
  Future<void> fetchFillterGenre( FillterGenreMovieReq fillterGenreMovieReq) async {
    try {
      //reset danh sách lại từ đầu
      _allItems.clear();
      _currentPage = 1;
      emit(FetchFillterLoading()); //phát ra đang loading
      //bắt đầu gọi api với 1
      final result = await sl<GetFillterGenreUsecase>().call(params: fillterGenreMovieReq);
      result.fold(
        (l) {
          emit(FetchFillterFailure(message: l));
        },
        (data) {
          _allItems = data.items; // dữ liệu cho danh sách
          emit( 
            FetchFillterSuccess(
              fillterMovieGenreEntity: FillterMovieGenreEntity(
                items: _allItems, 
                titlePage: data.titlePage, 
                params: data.params
              ),
              hasReachedMax: data.items.isNotEmpty || data.params.pagination.currentPage < data.params.pagination.totalPages
            )
          );
        }
      );
    } catch (e) {
      rethrow;
    }
  }
  Future<void> loadMore (FillterGenreMovieReq fillterGenreMovieReq) async {
    try {
      if(state is FetchFillterSuccess && !(state as FetchFillterSuccess).hasReachedMax) return; //nếu hết dữ liệu thì trả về luôn
      _currentPage++;
      emit(FetchFillterLoadingMore());
      final result = await sl<GetFillterGenreUsecase>().call(params: fillterGenreMovieReq.copyWith(page: _currentPage.toString()));
      result.fold(
        (l) {
          emit(FetchFillterFailure(message: l));
        },
        (data) {
          _allItems.addAll(data.items); // dữ liệu cho danh sách
          emit( 
            FetchFillterSuccess(
              fillterMovieGenreEntity: FillterMovieGenreEntity(
                items: _allItems, 
                titlePage: data.titlePage, 
                params: data.params
              ),
              hasReachedMax: data.items.isNotEmpty || data.params.pagination.currentPage < data.params.pagination.totalPages
            )
          );
        }
      );
    } catch (e) {
      rethrow;
    }
  }
  
}
