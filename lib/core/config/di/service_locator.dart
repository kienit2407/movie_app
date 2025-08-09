import 'package:get_it/get_it.dart';
import 'package:movie_app/feature/auth/data/repositoryImpl/auth_repository_Impl.dart';
import 'package:movie_app/feature/auth/data/sources/auth_supabase_service.dart';
import 'package:movie_app/feature/auth/domain/repositories/auth_repository.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_google.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_in.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_up.dart';
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
  sl.registerLazySingleton<AuthSupabaseService>(() => AuthSupabaseServiceImpl());
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<SignUpUsecase>(() => SignUpUsecase());
  sl.registerLazySingleton<SignInUsecase>(() => SignInUsecase());
  sl.registerLazySingleton<SiginWithGoogleUsecase>(() => SiginWithGoogleUsecase());
}