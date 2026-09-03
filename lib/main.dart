import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:movie_app/common/models/favorite_movie_entry.dart';
import 'package:movie_app/common/models/watch_progress_model.dart';
import 'package:movie_app/common/models/watch_history_entry.dart';
import 'package:movie_app/common/components/internet_status_banner.dart';
import 'package:movie_app/common/bloc/AuthWithSocial/auth_with_social_cubit.dart';
import 'package:movie_app/common/bloc/localization.dart';
import 'package:movie_app/core/config/routes/app_router.dart';
import 'package:movie_app/core/config/di/service_locator.dart';
import 'package:movie_app/core/config/network/init_supabase.dart';
import 'package:movie_app/core/config/themes/app_theme.dart';
import 'package:movie_app/core/enum/language_enum.dart';
import 'package:movie_app/core/player_overlay_host.dart';
import 'package:movie_app/core/player_overlay_controller.dart';
import 'package:movie_app/core/movie_sharing/movie_deep_link_service.dart';
import 'package:movie_app/core/observability/app_observability.dart';
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
import 'package:movie_app/feature/auth/presentation/session/auth_session_cubit.dart';
import 'package:movie_app/feature/auth/data/saved_account_store.dart';
import 'package:movie_app/feature/auth/presentation/session/saved_accounts_cubit.dart';
import 'package:movie_app/feature/detail_movie/presentation/bloc/player_cubit.dart';
import 'package:movie_app/feature/home/domain/usecase/get_country_movie.dart';
import 'package:movie_app/feature/home/domain/usecase/get_movies_by_filter_usecase.dart';
import 'package:movie_app/feature/home/domain/usecase/get_genre_movie.dart';
import 'package:movie_app/feature/home/domain/usecase/get_latest_usecase.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_navigation.dart';
import 'package:movie_app/feature/home/notification/comment_notification.dart';
import 'package:movie_app/feature/home/notification/new_movie_inbox.dart';
import 'package:movie_app/feature/home/notification/new_movie_notification_service.dart';
import 'package:movie_app/feature/home/notification/new_movie_worker.dart';
import 'package:movie_app/feature/home/presentation/bloc/carousel_display_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/country_movie_cubit.dart';
import 'package:movie_app/feature/home/presentation/bloc/genre_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/bloc/splash_cubit.dart';
import 'package:movie_app/feature/intro/presentation/splash/pages/splash.dart';
import 'package:movie_app/feature/library/data/user_library_repository.dart';
import 'package:movie_app/feature/library/presentation/cubit/user_library_cubit.dart';
import 'package:movie_app/feature/movie_pagination/presentation/bloc/fetch_fillter_cubit.dart';
import 'package:movie_app/feature/search/presentation/bloc/search_cubit.dart';
import 'package:movie_app/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:workmanager/workmanager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppObservability.initialize();
  Bloc.observer = AppObservability.blocObserver();
  MovieDeepLinkService.instance.initialize();
  PaintingBinding.instance.imageCache.maximumSize = 250;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 80 << 20;
  debugPrint('=== [1/8] WidgetsFlutterBinding initialized ===');
  // 1. Chỉ set orientation trên Mobile

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  debugPrint('=== [2/8] Screen orientation set ===');

  await dotenv.load(fileName: 'assets/.env');
  await supaBaseInit.initSupabase();
  debugPrint('=== [3/8] Dotenv loaded ===');
  final dir = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: dir);
  debugPrint('=== [4/8] HydratedBloc storage initialized ===');

  await Hive.initFlutter();

  // Lịch sử tìm kiếm đã chuyển sang Supabase theo tài khoản. Xóa box local
  // cũ một lần để không giữ dữ liệu dùng chung trên thiết bị.
  try {
    await Hive.deleteBoxFromDisk('search_history');
  } catch (error) {
    debugPrint('Không thể xóa search_history local cũ: $error');
  }

  Hive.registerAdapter(FavoriteMovieEntryAdapter());
  Hive.registerAdapter(WatchProgressModelAdapter());
  Hive.registerAdapter(WatchHistoryEntryAdapter());
  debugPrint('=== [5/8] Hive initialized ===');
  await FastCachedImageConfig.init(clearCacheAfter: const Duration(days: 7));

  debugPrint('=== [6/8] FastCachedImage initialized ===');
  // ZerorateHlsSDK.initialize();

  await initializeGetit();
  debugPrint('=== [7/8] GetIt initialized ===');

  await Workmanager().initialize(newMovieCallbackDispatcher);
  await sl<NewMovieNotificationService>().initialize(
    onPayload: NewMovieNotificationNavigation.handlePayload,
    readLaunchPayload: true,
  );
  await LiquidGlassWidgets.initialize(enablePerformanceMonitor: false);
  debugPrint('=== Starting app... ===');
  runApp(
    LiquidGlassWidgets.wrap(
      adaptiveQuality: true,
      child: MovieApp(router: goRouter),
    ),
  );
}

final playerOverlayBackButtonDispatcher = PlayerOverlayBackButtonDispatcher(
  PlayerOverlayController.instance,
);

class MovieApp extends StatelessWidget {
  final GoRouter router;
  const MovieApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      rebuildFactor: (oldData, newData) {
        final playerOverlay = PlayerOverlayController.instance;
        final keepPortraitScale =
            playerOverlay.isVisible &&
            playerOverlay.target == PlayerOverlayTarget.expanded &&
            newData.orientation == Orientation.landscape;

        // Các tab phía dưới player chỉ hỗ trợ portrait. Không cho ScreenUtil
        // đổi scaleWidth/scaleHeight theo khung ngang trong lúc player phủ kín;
        // nếu không 140.w có thể lớn hơn 300 px trong khi 260.h chỉ còn ~200 px.
        if (keepPortraitScale) return false;
        return RebuildFactors.size(oldData, newData);
      },
      builder: (_, __) => MultiBlocProvider(
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
          BlocProvider(create: (context) => AuthSessionCubit()),
          BlocProvider(create: (context) => LocalizationCubit()),
          BlocProvider(
            create: (context) => SavedAccountsCubit(store: SavedAccountStore()),
          ),
          BlocProvider(
            create: (context) =>
                UserLibraryCubit(repository: sl<UserLibraryRepository>()),
          ),
          BlocProvider(
            create: (context) => NewMovieInboxCubit(
              sl<NewMovieInboxStore>(),
              commentRepository: sl<CommentNotificationRepository>(),
              badgeUpdater: sl<NewMovieNotificationService>(),
            ),
          ),
          BlocProvider(
            create: (context) =>
                ResetPasswordCubit(sl<ReqResetPasswordUsecase>()),
          ),
          BlocProvider(
            create: (context) =>
                ConfirmTokenCubit(sl<ConfirmWithTokenUsecase>()),
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
          BlocProvider(create: (context) => sl<SearchCubit>()),
          BlocProvider(create: (context) => sl<PlayerCubit>()),
        ],
        child: BlocBuilder<LocalizationCubit, Language>(
          builder: (context, language) => GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: MaterialApp.router(
              locale: language.locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context).appTitle,
              routeInformationProvider: router.routeInformationProvider,
              routeInformationParser: router.routeInformationParser,
              routerDelegate: router.routerDelegate,
              backButtonDispatcher: playerOverlayBackButtonDispatcher,
              theme: AppTheme.appTheme,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                return Overlay(
                  initialEntries: [
                    OverlayEntry(
                      builder: (_) {
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // ==========================
                            // APP THẬT
                            // ==========================
                            PlayerOverlayHost(
                              router: router,
                              child: child ?? const SizedBox.shrink(),
                            ),
                            const InternetStatusBanner(),

                            // ==========================
                            // SPLASH PHỦ LÊN APP
                            // ==========================
                            const Positioned.fill(
                              child: StartupSplashOverlay(),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
