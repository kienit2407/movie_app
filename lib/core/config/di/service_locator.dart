import 'package:get_it/get_it.dart';
import 'package:movie_app/core/config/network/dio_client.dart';
import 'package:movie_app/feature/auth/data/repositoryImpl/auth_repository_Impl.dart';
import 'package:movie_app/feature/auth/data/sources/auth_supabase_service.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/feature/auth/domain/usecases/confirm_with_token.dart';
import 'package:movie_app/feature/auth/domain/usecases/req_reset_password.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_facebook.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_google.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_in.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_out.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_up.dart';
import 'package:movie_app/feature/home/data/repository/movie_repository_impl.dart';
import 'package:movie_app/feature/home/data/source/movie_remote_datasource.dart';
import 'package:movie_app/feature/home/domain/repository/movie_repository.dart';
import 'package:movie_app/feature/home/domain/usecase/get_country_movie.dart';
import 'package:movie_app/feature/home/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/home/domain/usecase/get_fillter_country.dart';
import 'package:movie_app/feature/home/domain/usecase/get_fillter_genre.dart';
import 'package:movie_app/feature/home/domain/usecase/get_genre_movie.dart';
import 'package:movie_app/feature/home/domain/usecase/get_latest_usecase.dart';
//khởi tạo instance
final sl = GetIt.instance;
//khởi tạo hàm để khởi động getit
Future<void> initializeGetit () async {
  // sl.registerLazySingleton<T>(() => T()); <- tạo instance duy nhất và nó chỉ tạo khi bị gọi lần đầu tiên
  //vd: dùng trong backend như: Api Service, AuthService,... <- khi bạn không chắc có sử dụng nó hay không
  // sl.registerSingleton<T>(T instance) <- tạo instance ngay lập tức sai khi khởi chạy
  //vd: Những thứ phải có ngay từ đầu như; theme, share prefs,...
  // sl.registerFactory<T>(( => T())) <- Mỗi lần gọi sẽ tạo ra một instance mới
  //vd: những instance mà bạn không muốn giữ state cũ của nó hoặc là có vòng đời ngắn
  // sl.registerLazySingletonAsync <- giống đầu tiên cũng chỉ tạo khi gọi như nó sẽ đợi tránh load dữ liêu cùng lúc
  // sl.registerSingletonAsync<T>(() => T()); <- sẽ chờ khởi tạo hoàn tất. Dùng khi load dữ liệu từ db hay api

  sl.registerLazySingletonAsync<DioClient>(() => DioClient.create()); // đăng kí một DioClient 
  await sl.isReady<DioClient>();
  sl.registerLazySingleton(()  => MovieRemoteDatasourceImpl(dioClient: sl<DioClient>())); //-> cái sl() chính là 1 cái kho trung tâm khi mà thấy nó cần một dioClient thì nó sẽ tìm kiếm và cấp cho thứ cần cái type đó

  sl.registerLazySingleton<AuthService>(() => AuthSupabaseServiceImpl());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<SignUpUsecase>(() => SignUpUsecase());
  sl.registerLazySingleton<SignInUsecase>(() => SignInUsecase());
  sl.registerLazySingleton<SiginWithGoogleUsecase>(() => SiginWithGoogleUsecase());
  sl.registerLazySingleton<SiginWithFacebookUsecase>(() => SiginWithFacebookUsecase());
  sl.registerLazySingleton<SignOutUsecase>(() => SignOutUsecase());
  sl.registerLazySingleton<ReqResetPasswordUsecase>(() => ReqResetPasswordUsecase());
  sl.registerLazySingleton<ConfirmWithTokenUsecase>(() => ConfirmWithTokenUsecase());
  sl.registerLazySingleton<MovieRemoteDatasource >(() => MovieRemoteDatasourceImpl(dioClient: sl()));
  sl.registerLazySingleton<MovieRepository>(() => MovieRepositoryImpl());
  sl.registerLazySingleton<GetLatestUsecase>(() => GetLatestUsecase());
  sl.registerLazySingleton<GetDetailMovieUsecase>(() => GetDetailMovieUsecase());
  sl.registerLazySingleton<GetGenreMovieUsecase>(() => GetGenreMovieUsecase());
  sl.registerLazySingleton<GetCountryMovieUsecase>(() => GetCountryMovieUsecase());
  sl.registerLazySingleton<GetFillterGenreUsecase>(() => GetFillterGenreUsecase());
  sl.registerLazySingleton<GetFillterCountryUsecase>(() => GetFillterCountryUsecase());
  
}