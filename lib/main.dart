import 'package:device_preview/device_preview.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:movie_app/common/models/watch_progress_model.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/network/init_supabase.dart';
import 'package:movie_app/core/config/themes/app_theme.dart';
import 'package:movie_app/core/config/utils/support_rotate_screen.dart';
import 'package:movie_app/core/mini_player_overlay.dart';
import 'package:movie_app/feature/auth/domain/usecases/confirm_with_token.dart';
import 'package:movie_app/feature/auth/domain/usecases/req_reset_password.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_facebook.dart';
import 'package:movie_app/feature/auth/domain/usecases/sigin_with_google.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_in.dart';
import 'package:movie_app/feature/auth/domain/usecases/sign_up.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/confirm_token_cubit.dart';
import 'package:movie_app/feature/auth/presentation/reset_password/bloc/reset_password_cubit.dart';
import 'package:movie_app/feature/auth/presentation/sign_in/bloc/sign_in_cubit.dart';
import 'package:movie_app/feature/auth/presentation/sign_up/bloc/sign_up_cubit.dart';
import 'package:movie_app/feature/home/domain/usecase/get_country_movie.dart';
import 'package:movie_app/feature/detail_movie/domain/usecase/get_detail_movie_usecase.dart';
import 'package:movie_app/feature/home/domain/usecase/get_movies_by_filter_usecase.dart';
import 'package:movie_app/feature/home/domain/usecase/get_genre_movie.dart';
import 'package:movie_app/feature/home/domain/usecase/get_latest_usecase.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/home/presentation/pages/home_page.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=== [1/6] WidgetsFlutterBinding initialized ===');

  SupportRotateScreen.onlyPotrait();
  debugPrint('=== [2/6] Screen orientation set ===');

  // Khởi tạo tất cả dependencies TRƯỚC KHI runApp
  await dotenv.load(fileName: 'assets/.env');
  debugPrint('=== [4/7] Dotenv loaded ===');

  await Hive.initFlutter();
  Hive.registerAdapter(WatchProgressModelAdapter());
  debugPrint('=== [5/7] Hive initialized ===');

  await FastCachedImageConfig.init(
    clearCacheAfter: const Duration(hours: 10), // Tự động xóa sau 15 ngày
  );
  debugPrint('=== [6/7] FastCachedImage initialized ===');

  await initializeGetit();
  debugPrint('=== [7/7] GetIt initialized ===');

  debugPrint('=== Starting app... ===');
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => SplashCubit()..appStarted()),
        BlocProvider(create: (context) => SignUpCubit(sl<SignUpUsecase>())),
        BlocProvider(create: (context) => SignInCubit(sl<SignInUsecase>())),
        BlocProvider(
          create: (context) => AuthWithSocialCubit(
            sl<SiginWithGoogleUsecase>(),
            sl<SiginWithFacebookUsecase>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              ResetPasswordCubit(sl<ReqResetPasswordUsecase>()),
        ),
        BlocProvider(
          create: (context) => ConfirmTokenCubit(sl<ConfirmWithTokenUsecase>()),
        ),
        BlocProvider(
          create: (context) =>
              CarouselDisplayCubit(sl<GetLatestUsecase>())..getLatestMovie(),
        ),
        BlocProvider(
          create: (context) => FetchFillterCubit(
            getMoviesByFilterUsecase: sl<GetMoviesByFilterUsecase>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              GenreCubit(sl<GetGenreMovieUsecase>())..getGenreMovie(),
        ),
        BlocProvider(
          create: (context) =>
              CountryMovieCubit(sl<GetCountryMovieUsecase>())
                ..getCountryMovie(),
        ),
        BlocProvider(
          create: (context) => sl<SearchCubit>(),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        home: Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) => Navigator(
                onGenerateRoute: (settings) {
                  return MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  );
                },
              ),
            ),
            OverlayEntry(builder: (context) => const MiniPlayerOverlay()),
          ],
        ),
      ),
    );
  }
}
