import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_genre_movie_req.dart';
import 'package:movie_app/feature/home/domain/entities/fillter_movie_genre_entity.dart';
import 'package:movie_app/feature/home/domain/entities/new_movie_entity.dart';
import 'package:movie_app/feature/home/domain/usecase/get_fillter_genre.dart';
import 'package:movie_app/feature/home/presentation/bloc/fetch_fillter_state.dart';

class FetchFillterCubit extends Cubit<FetchFillterState>  {
  FetchFillterCubit() : super(FetchFillterInitial());
  int _currentPage = 1;
  List<ItemEntity> _allItems = [];
  bool _hasReachedMax = true;
  Future<void> fetchFillterGenre(FillterMovieReq fillterGenreMovieReq) async {
    try {
      if(fillterGenreMovieReq.typeList.isEmpty){
        emit(FetchFillterFailure(message: 'Bn chưa chọn genr'));
        return;
      }
      //reset danh sách lại từ đầu
      _allItems.clear();
      _currentPage = 1;
      _hasReachedMax = true;
      emit(FetchFillterLoading()); //phát ra đang loading
      //bắt đầu gọi api với 1
      fetchApi(fillterGenreMovieReq);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadApi (FillterMovieReq fillterGenreMovieReq) async {
    if(!_hasReachedMax) return;
    emit(FetchFillterLoadingMore());
    _currentPage++;
    fetchApi(fillterGenreMovieReq.copyWith(page: _currentPage.toString()));
  }

  Future<void> fetchApi (FillterMovieReq fillterGenreMovieReq) async {
    try {
      final result = await sl<GetFillterGenreUsecase>().call(params: fillterGenreMovieReq);
      result.fold(
        (l) {
          emit(FetchFillterFailure(message: l));
        },
        (data) {
          _allItems = data.items; // dữ liệu cho danh sách
          _hasReachedMax = data.items.isNotEmpty || data.params.pagination.currentPage < data.params.pagination.totalPages;
          emit( 
            FetchFillterSuccess(
              fillterMovieGenreEntity: FillterMovieGenreEntity(
                items: _allItems, 
                titlePage: data.titlePage, 
                params: data.params
              ),
              hasReachedMax: _hasReachedMax
            )
          );
        }
      );
    } catch (e) {
      rethrow;
    }
  }
}
