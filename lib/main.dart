import 'package:device_preview/device_preview.dart';
import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:movie_app/common/models/watch_progress_model.dart';
import 'package:movie_app/common/models/watch_history_entry.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/network/init_supabase.dart';
import 'package:movie_app/core/config/themes/app_theme.dart';
import 'package:movie_app/core/mini_player_overlay.dart';
import 'package:movie_app/core/mini_player_manager.dart';
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
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_cubit.dart';
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
import 'package:movie_app/feature/intro/presentation/splash/pages/splash.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('=== [1/8] WidgetsFlutterBinding initialized ===');

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('=== [2/8] Screen orientation set ===');

  await dotenv.load(fileName: 'assets/.env');
  debugPrint('=== [3/8] Dotenv loaded ===');

  try {
    final dir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${dir.path}/hive');
    if (await hiveDir.exists()) {
      await hiveDir.delete(recursive: true);
      debugPrint('=== Cleared Hive data directory ===');
    }
  } catch (e) {
    debugPrint('=== Failed to clear Hive directory: $e ===');
  }

  await Hive.initFlutter();
  
  Hive.registerAdapter(WatchProgressModelAdapter());
  Hive.registerAdapter(WatchHistoryEntryAdapter());
  debugPrint('=== [4/8] Hive initialized ===');

  final storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  HydratedBloc.storage = storage;
  debugPrint('=== [5/8] HydratedBloc storage initialized ===');

  await FastCachedImageConfig.init(
    clearCacheAfter: const Duration(hours: 10),
  );
  debugPrint('=== [6/8] FastCachedImage initialized ===');

  await initializeGetit();
  debugPrint('=== [7/8] GetIt initialized ===');

  debugPrint('=== Starting app... ===');
  runApp(MovieApp(router: goRouter));
}

class MovieApp extends StatelessWidget {
  final GoRouter router;
  const MovieApp({super.key, required this.router});

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
        BlocProvider(
          create: (context) => sl<PlayerCubit>(),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        theme: AppTheme.appTheme,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Overlay(
            initialEntries: [
              OverlayEntry(builder: (_) => child!),
              OverlayEntry(builder: (_) => MiniPlayerOverlay()),
            ],
          );
        },
      ),
    );
  }
}
