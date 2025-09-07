import 'package:movie_app/common/helpers/contants/app_url.dart';
import 'package:movie_app/core/config/network/dio_client.dart';
import 'package:movie_app/core/errol/app_exception.dart';
import 'package:movie_app/feature/home/data/models/detail_movie_model.dart';
import 'package:movie_app/feature/home/data/models/new_movie_model.dart';

abstract class MovieRemoteDatasource {
  Future<NewMovieModel> getLatestMovie (int page);
  Future<DetailMovieModel> getDetailMovie(String slug);
}

class MovieRemoteDatasourceImpl implements MovieRemoteDatasource {
  // final DioClient dioClient = DioClient(); // -> đây là vừa khai báo biến và vừa khai báo instance, và nó được tạo sẵn contructor luôn rồi 
  // final DioClient dioClient;
  // MovieRemoteDatasourceImpl({required this.dioClient}); -> truyền theo kiểu injection từ bên ngoài -> khi muốn test hoặc muốn quản lí từ bên ngoài
  // và lí do late final Animation conttrolor là vì ticker nó cần this trong state để khởi tạo. [this này sẽ có sau khi mà widget được build], nên nếu khởi tạo sớm thì không có context hay this nên nó phải khao báo trễ và khởi tạo trong init
  // final DioClient dioClient = DioClient();
  final DioClient dioClient;
  MovieRemoteDatasourceImpl({required this.dioClient});
  
  @override
  Future<NewMovieModel> getLatestMovie(int page)async {
    try {
      final response = await dioClient.get(
        AppUrl.getLatestMovie,
        queryParameters: {
          'page' : page
        }
        
      );
      if (response.data['status'] == true && response.data['msg'] == 'done') {
        print('Status OK, parsing model...');
        
        return NewMovieModel.fromMap(response.data) ;
      } else {
        throw ServerException('Failed to load movie detail');
      }
    } catch (e) {
      
      rethrow;
    }
  }
  @override
  Future<DetailMovieModel> getDetailMovie(String slug) async {
    try {
      final response = await dioClient.get(
        AppUrl.getDetailMovie(slug),
      );
      if (response.data['status'] == true && response.data['msg'] == 'done') {
        print('Status OK, parsing model...');
        
        return DetailMovieModel.fromMap(response.data);
      } else {
        throw ServerException('Failed to load movie detail');
      }
    } catch (e) {
      rethrow;
    }
  }
  // Ở tầng data thì tuyệt đối chỉ dùng để giao tiếp với api hoặt auth, còn phần bắt lỗi thì sẽ do repoimpl phụ trách vì nếu bạn dùng either trong data thì repo bây giờ chỉ là adaptor thôi và nó không được sạch vì repo nằm ở tầng domain và either cũng nằm ở tầng domain
  
}