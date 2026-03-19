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
import 'package:movie_app/feature/home/domain/usecase/get_genre_movie.dart';
import 'package:movie_app/feature/home/domain/usecase/get_latest_usecase.dart';
import 'package:movie_app/feature/home/domain/usecase/get_movies_by_filter_usecase.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeGetit() async {
  sl.registerLazySingletonAsync<DioClient>(() => DioClient.create());
  await sl.isReady<DioClient>();

  sl.registerLazySingleton<MovieRemoteDatasource>(
    () => MovieRemoteDatasourceImpl(dioClient: sl<DioClient>()),
  );

  sl.registerLazySingleton<AuthService>(() => AuthSupabaseServiceImpl());

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthService>()),
  );

  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(sl<MovieRemoteDatasource>()),
  );

  sl.registerLazySingleton<SignUpUsecase>(
    () => SignUpUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignInUsecase>(
    () => SignInUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SiginWithGoogleUsecase>(
    () => SiginWithGoogleUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SiginWithFacebookUsecase>(
    () => SiginWithFacebookUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<SignOutUsecase>(
    () => SignOutUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ReqResetPasswordUsecase>(
    () => ReqResetPasswordUsecase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ConfirmWithTokenUsecase>(
    () => ConfirmWithTokenUsecase(sl<AuthRepository>()),
  );

  sl.registerLazySingleton<GetLatestUsecase>(
    () => GetLatestUsecase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetDetailMovieUsecase>(
    () => GetDetailMovieUsecase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetGenreMovieUsecase>(
    () => GetGenreMovieUsecase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetCountryMovieUsecase>(
    () => GetCountryMovieUsecase(sl<MovieRepository>()),
  );
  sl.registerLazySingleton<GetMoviesByFilterUsecase>(
    () => GetMoviesByFilterUsecase(sl<MovieRepository>()),
  );
}
