import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_th.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('th'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'Liquid Phim'**
  String get appTitle;

  /// Tagline displayed on the splash or branding screen
  ///
  /// In en, this message translates to:
  /// **'Movies anytime, anywhere'**
  String get appTagline;

  /// Generic confirmation action
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get commonAgree;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// Generic close action or tooltip
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// Generic done action
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// Generic save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// Generic delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// Generic edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// Generic report action
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get commonReport;

  /// Generic retry action
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonRetry;

  /// Generic reset action
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// Option representing all available values
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get commonAll;

  /// Action that expands content
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get commonSeeMore;

  /// Action that collapses content
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get commonCollapse;

  /// Generic loading state
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get commonLoading;

  /// Fallback text while movie information is being updated
  ///
  /// In en, this message translates to:
  /// **'Updating'**
  String get commonUpdating;

  /// Acknowledgement action in an informational dialog
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get commonUnderstood;

  /// Generic empty data state
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get commonNoData;

  /// Fallback value when information is unavailable
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get commonNotAvailable;

  /// Generic warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get commonWarningTitle;

  /// Generic informational dialog title
  ///
  /// In en, this message translates to:
  /// **'Notice'**
  String get commonNoticeTitle;

  /// Generic success dialog title
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get commonCongratulationsTitle;

  /// Generic back navigation tooltip
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get commonBack;

  /// Action on the router error page that navigates home
  ///
  /// In en, this message translates to:
  /// **'Go to home'**
  String get commonGoHome;

  /// Number of selected list items
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Nothing selected} =1{1 selected} other{{count} selected}}'**
  String commonSelectedCount(int count);

  /// Generic error containing technical details
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String commonErrorWithDetails(String error);

  /// Movie duration containing hours and minutes
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour} other{{hours} hours}} {minutes, plural, =1{1 minute} other{{minutes} minutes}}'**
  String commonDurationHoursMinutes(int hours, int minutes);

  /// Application language setting title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Option that follows the operating system language
  ///
  /// In en, this message translates to:
  /// **'Use device language'**
  String get settingsLanguageSystem;

  /// Vietnamese language option written in its native name
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get settingsLanguageVietnamese;

  /// English language option written in its native name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// Japanese language option written in its native name
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get settingsLanguageJapanese;

  /// Thai language option written in its native name
  ///
  /// In en, this message translates to:
  /// **'ไทย'**
  String get settingsLanguageThai;

  /// Korean language option written in its native name
  ///
  /// In en, this message translates to:
  /// **'한국어'**
  String get settingsLanguageKorean;

  /// Simplified Chinese language option written in its native name
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get settingsLanguageChineseSimplified;

  /// Traditional Chinese language option written in its native name
  ///
  /// In en, this message translates to:
  /// **'繁體中文'**
  String get settingsLanguageChineseTraditional;

  /// Settings page title and settings button tooltip
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// General settings section heading
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneralSection;

  /// App language row and language picker title
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingsAppLanguage;

  /// Account settings section heading
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountSection;

  /// Switch account row and bottom sheet title
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get settingsSwitchAccount;

  /// Action that starts sign-in for another account
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get settingsAddAccount;

  /// Error shown when a saved account session cannot be restored
  ///
  /// In en, this message translates to:
  /// **'Could not switch accounts. Please sign in to that account again.'**
  String get settingsAccountSwitchFailed;

  /// Error shown when signing out fails
  ///
  /// In en, this message translates to:
  /// **'Could not sign out. Please try again.'**
  String get settingsSignOutFailed;

  /// Home tab accessibility label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Search tab accessibility label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// Favorites tab accessibility label
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// Profile tab accessibility label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Notifications page title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get navNotifications;

  /// Banner shown while the device is offline
  ///
  /// In en, this message translates to:
  /// **'No Internet connection'**
  String get internetOffline;

  /// Banner shown when Internet access returns
  ///
  /// In en, this message translates to:
  /// **'Back online'**
  String get internetBackOnline;

  /// Action inviting a signed-out user to authenticate
  ///
  /// In en, this message translates to:
  /// **'Join as a member'**
  String get authJoinMember;

  /// Sign-in page heading
  ///
  /// In en, this message translates to:
  /// **'Sign in to Liquid Phim'**
  String get authSignInTitle;

  /// Sign-in action
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignIn;

  /// Fallback sign-in failure message
  ///
  /// In en, this message translates to:
  /// **'Sign-in was unsuccessful. Please try again.'**
  String get authSignInFailed;

  /// Sign-in benefit shown when authentication is required for comments
  ///
  /// In en, this message translates to:
  /// **'Sign in to comment and interact with the community.'**
  String get authSignInToComment;

  /// Description of Google sign-in benefits
  ///
  /// In en, this message translates to:
  /// **'Continue with Google to sync your account and join the community.'**
  String get authGoogleSyncDescription;

  /// Consent copy below the Google sign-in action
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to use your Google account with Liquid Phim.'**
  String get authGoogleConsent;

  /// Google sign-in action
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get authContinueWithGoogle;

  /// Google sign-in failure message
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google. Please try again.'**
  String get authGoogleSignInFailed;

  /// Google sign-in failure message that asks the user to check and retry
  ///
  /// In en, this message translates to:
  /// **'Could not sign in with Google. Please check your connection and try again.'**
  String get authGoogleSignInCheckFailed;

  /// Authentication session refresh failure
  ///
  /// In en, this message translates to:
  /// **'Could not update your sign-in session.'**
  String get authSessionUpdateFailed;

  /// Message shown when a signed-in user is required
  ///
  /// In en, this message translates to:
  /// **'You need to sign in.'**
  String get authLoginRequired;

  /// Message shown when an action requires authentication
  ///
  /// In en, this message translates to:
  /// **'You need to sign in to perform this action.'**
  String get authLoginRequiredForAction;

  /// Email field label or hint
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmail;

  /// Password field label or hint
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPassword;

  /// Full name field label or hint
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get authFullName;

  /// Forgot password action
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPassword;

  /// Separator before social sign-in options
  ///
  /// In en, this message translates to:
  /// **'Or continue with'**
  String get authOrContinueWith;

  /// Prompt on the sign-up page
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get authAlreadyHaveAccount;

  /// Full name validation error
  ///
  /// In en, this message translates to:
  /// **'Full name cannot be blank.'**
  String get authFullNameRequired;

  /// Full name length validation error
  ///
  /// In en, this message translates to:
  /// **'Full name must contain between 3 and 15 characters.'**
  String get authFullNameLength;

  /// Email validation error
  ///
  /// In en, this message translates to:
  /// **'Email cannot be blank.'**
  String get authEmailRequired;

  /// Email format validation error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get authEmailInvalid;

  /// Password validation error
  ///
  /// In en, this message translates to:
  /// **'Password cannot be blank.'**
  String get authPasswordRequired;

  /// Password length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must contain between 6 and 15 characters.'**
  String get authPasswordLength;

  /// Sign-up failure when an account already exists
  ///
  /// In en, this message translates to:
  /// **'This account already exists. Please choose another email.'**
  String get authAccountAlreadyExists;

  /// Weak password validation returned by authentication
  ///
  /// In en, this message translates to:
  /// **'This password is too weak. Please enter a stronger password.'**
  String get authWeakPassword;

  /// Invalid sign-in credentials message
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect. Please try again.'**
  String get authInvalidCredentials;

  /// Generic authentication failure
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authUnexpectedError;

  /// Generic sign-up failure
  ///
  /// In en, this message translates to:
  /// **'Could not create your account. Please try again.'**
  String get authSignUpFailed;

  /// Sign-up success message
  ///
  /// In en, this message translates to:
  /// **'Your account has been created.'**
  String get authSignUpSucceeded;

  /// Sign-in success message
  ///
  /// In en, this message translates to:
  /// **'Signed in successfully.'**
  String get authSignInSucceeded;

  /// Sign-out success message
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully.'**
  String get authSignOutSucceeded;

  /// Password reset token confirmation success
  ///
  /// In en, this message translates to:
  /// **'Verification code confirmed.'**
  String get authTokenConfirmed;

  /// Password reset token validation failure
  ///
  /// In en, this message translates to:
  /// **'The verification code is incorrect.'**
  String get authTokenInvalid;

  /// Title of the new movie notification opt-in dialog
  ///
  /// In en, this message translates to:
  /// **'Get new movie notifications?'**
  String get homeEnableNewMovieNotificationsTitle;

  /// Explanation in the new movie notification opt-in dialog
  ///
  /// In en, this message translates to:
  /// **'Liquid Phim can check periodically in the background and notify you when new movies are found. The operating system might delay checks by more than 20 minutes to save battery.'**
  String get homeEnableNewMovieNotificationsBody;

  /// Action that enables new movie notifications
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get homeEnableNotifications;

  /// Action that declines new movie notifications
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get homeDoNotEnable;

  /// Message shown when notification permission is not granted
  ///
  /// In en, this message translates to:
  /// **'Notification permission is disabled. You can enable it again in your phone settings.'**
  String get homeNotificationPermissionDisabled;

  /// Home page movie loading error with retry guidance
  ///
  /// In en, this message translates to:
  /// **'Could not load movies.\nPull down to try again.'**
  String get homeLoadMoviesFailed;

  /// Recommended movies filter
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get homeRecommended;

  /// Genres filter or section label
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get homeGenres;

  /// Countries filter or section label
  ///
  /// In en, this message translates to:
  /// **'Countries'**
  String get homeCountries;

  /// Year filter label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get homeYear;

  /// Heading for newly released movies
  ///
  /// In en, this message translates to:
  /// **'Fresh releases!'**
  String get homeFreshMovies;

  /// Heading for the Korean movie section
  ///
  /// In en, this message translates to:
  /// **'Korean movies'**
  String get homeKoreanMovies;

  /// Heading for the Chinese movie section
  ///
  /// In en, this message translates to:
  /// **'Chinese movies'**
  String get homeChineseMovies;

  /// Heading for the US and UK movie section
  ///
  /// In en, this message translates to:
  /// **'US & UK movies'**
  String get homeUsUkMovies;

  /// Primary action that starts movie playback
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get homeWatchMovie;

  /// Action that opens movie information
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get homeInformation;

  /// Action that opens all items in a section
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get homeViewAll;

  /// Heading above movie type recommendations
  ///
  /// In en, this message translates to:
  /// **'What would you like to watch today?'**
  String get homeWhatToWatch;

  /// Action to show more movie recommendations
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get homeViewMore;

  /// Application version and build number
  ///
  /// In en, this message translates to:
  /// **'Version: {version} ({buildNumber})'**
  String homeAppVersion(String version, String buildNumber);

  /// Movie type filter heading
  ///
  /// In en, this message translates to:
  /// **'Movie type'**
  String get filterMovieType;

  /// Series movie type
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get filterSeries;

  /// Single movie type
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get filterSingleMovies;

  /// Animation movie type
  ///
  /// In en, this message translates to:
  /// **'Animation'**
  String get filterAnimation;

  /// TV show movie type
  ///
  /// In en, this message translates to:
  /// **'TV shows'**
  String get filterTvShows;

  /// Content with subtitles
  ///
  /// In en, this message translates to:
  /// **'Subtitled'**
  String get filterSubtitled;

  /// Content with voice-over narration
  ///
  /// In en, this message translates to:
  /// **'Voice-over'**
  String get filterVoiceOver;

  /// Dubbed content
  ///
  /// In en, this message translates to:
  /// **'Dubbed'**
  String get filterDubbed;

  /// Validation message when no movie type is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a movie type.'**
  String get filterChooseMovieType;

  /// Validation message when no genre is selected
  ///
  /// In en, this message translates to:
  /// **'Please select a genre.'**
  String get filterChooseGenre;

  /// Validation message when no country is selected
  ///
  /// In en, this message translates to:
  /// **'Select a country to filter by.'**
  String get filterChooseCountry;

  /// Validation message when no year is selected
  ///
  /// In en, this message translates to:
  /// **'Select a year to filter by.'**
  String get filterChooseYear;

  /// Content language filter heading
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get filterLanguage;

  /// Sort field heading
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get filterSortBy;

  /// Ascending or descending sort heading
  ///
  /// In en, this message translates to:
  /// **'Sort direction'**
  String get filterSortDirection;

  /// Descending sort option
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get filterDescending;

  /// Ascending sort option
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get filterAscending;

  /// Most viewed sort option
  ///
  /// In en, this message translates to:
  /// **'Most viewed'**
  String get filterMostViewed;

  /// Newest sort option
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get filterNewest;

  /// Release year sort option
  ///
  /// In en, this message translates to:
  /// **'Release year'**
  String get filterReleaseYear;

  /// Action that applies all selected filters
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get filterApply;

  /// Action that applies a simple filter
  ///
  /// In en, this message translates to:
  /// **'Filter results'**
  String get filterResults;

  /// Search validation dialog title
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get searchAttentionTitle;

  /// Validation shown when filters are opened without a search keyword
  ///
  /// In en, this message translates to:
  /// **'Enter a keyword before filtering movies.'**
  String get searchEnterKeywordBeforeFiltering;

  /// Search empty result message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get searchNoResults;

  /// Search input hint
  ///
  /// In en, this message translates to:
  /// **'Search movies, actors...'**
  String get searchMovieActorHint;

  /// Tooltip and title for search filters
  ///
  /// In en, this message translates to:
  /// **'Search filters'**
  String get searchFilterTooltip;

  /// Prompt shown before the first search
  ///
  /// In en, this message translates to:
  /// **'Enter a movie title to start searching'**
  String get searchStartPrompt;

  /// Recent search history heading
  ///
  /// In en, this message translates to:
  /// **'Recent searches'**
  String get searchRecent;

  /// Loading state for genres in search filters
  ///
  /// In en, this message translates to:
  /// **'Loading genres...'**
  String get searchLoadingGenres;

  /// Loading state for countries in search filters
  ///
  /// In en, this message translates to:
  /// **'Loading countries...'**
  String get searchLoadingCountries;

  /// Movie list empty state
  ///
  /// In en, this message translates to:
  /// **'No movies'**
  String get searchNoMovies;

  /// Guidance shown when filters return no movies
  ///
  /// In en, this message translates to:
  /// **'Try different filters'**
  String get searchTryDifferentFilters;

  /// Sign-out confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get librarySignOutTitle;

  /// Sign-out confirmation dialog body
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of this account?'**
  String get librarySignOutConfirmation;

  /// Sign-out action and tooltip
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get librarySignOut;

  /// Title for deleting selected movies
  ///
  /// In en, this message translates to:
  /// **'Delete {count, plural, =1{the selected movie?} other{{count} selected movies?}}'**
  String libraryDeleteSelectedMoviesTitle(int count);

  /// Title for deleting one history item
  ///
  /// In en, this message translates to:
  /// **'Delete this movie from history?'**
  String get libraryDeleteHistoryMovieTitle;

  /// Confirmation for removing movies from watch history
  ///
  /// In en, this message translates to:
  /// **'Remove {count, plural, =1{this movie} other{{count} movies}} from watch history?'**
  String libraryDeleteHistoryConfirmation(int count);

  /// Title for deleting one favorite movie
  ///
  /// In en, this message translates to:
  /// **'Remove this movie from favorites?'**
  String get libraryDeleteFavoriteMovieTitle;

  /// Confirmation for removing movies from favorites
  ///
  /// In en, this message translates to:
  /// **'Remove {count, plural, =1{this movie} other{{count} movies}} from favorites?'**
  String libraryDeleteFavoritesConfirmation(int count);

  /// Tooltip that exits selection mode
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get libraryCancelSelection;

  /// Tooltip that deletes selected movies
  ///
  /// In en, this message translates to:
  /// **'Delete selected movies'**
  String get libraryDeleteSelectedMovies;

  /// Error shown when playback cannot resume from history
  ///
  /// In en, this message translates to:
  /// **'Cannot resume this movie right now.'**
  String get libraryCannotResumeMovie;

  /// Profile section title
  ///
  /// In en, this message translates to:
  /// **'Your profile'**
  String get libraryYourProfile;

  /// Description shown to a signed-out user on the profile page
  ///
  /// In en, this message translates to:
  /// **'Sign in to edit your profile and sync your watch history.'**
  String get librarySignInProfileDescription;

  /// Watch history heading
  ///
  /// In en, this message translates to:
  /// **'Watch history'**
  String get libraryWatchHistory;

  /// Empty watch history message
  ///
  /// In en, this message translates to:
  /// **'No watch history yet'**
  String get libraryNoWatchHistory;

  /// Favorites page title
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get libraryFavorites;

  /// Signed-out favorites page heading
  ///
  /// In en, this message translates to:
  /// **'Sign in to save favorite movies'**
  String get librarySignInToSaveFavorites;

  /// Signed-out favorites page description
  ///
  /// In en, this message translates to:
  /// **'Your list will be synced across your devices.'**
  String get libraryFavoritesSyncDescription;

  /// Empty favorites message
  ///
  /// In en, this message translates to:
  /// **'No favorite movies yet'**
  String get libraryNoFavorites;

  /// Tooltip for deleting a library movie card
  ///
  /// In en, this message translates to:
  /// **'Remove from list'**
  String get libraryRemoveFromList;

  /// Playback progress action on a library movie card
  ///
  /// In en, this message translates to:
  /// **'Continue {progress}%'**
  String libraryContinueProgress(int progress);

  /// Short month and day label for a watch history group
  ///
  /// In en, this message translates to:
  /// **'{date}'**
  String libraryDateDayMonth(DateTime date);

  /// Library loading failure
  ///
  /// In en, this message translates to:
  /// **'Could not load your library. Please try again.'**
  String get libraryLoadFailed;

  /// Favorite update failure
  ///
  /// In en, this message translates to:
  /// **'Could not update favorites. Please try again.'**
  String get libraryFavoriteUpdateFailed;

  /// Favorite removal failure
  ///
  /// In en, this message translates to:
  /// **'Could not remove the favorite. Please try again.'**
  String get libraryFavoriteRemoveFailed;

  /// Deferred watch history synchronization message
  ///
  /// In en, this message translates to:
  /// **'Your history will be synced again later.'**
  String get libraryHistorySyncLater;

  /// Watch history deletion failure
  ///
  /// In en, this message translates to:
  /// **'Could not delete watch history. Please try again.'**
  String get libraryHistoryDeleteFailed;

  /// Edit profile page title
  ///
  /// In en, this message translates to:
  /// **'Edit profile'**
  String get profileEdit;

  /// Action for changing the profile photo
  ///
  /// In en, this message translates to:
  /// **'Change photo'**
  String get profileChangePhoto;

  /// Display name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profileName;

  /// Display name explanation
  ///
  /// In en, this message translates to:
  /// **'This name will appear on your Liquid Phim profile.'**
  String get profileNameDescription;

  /// Display name input hint
  ///
  /// In en, this message translates to:
  /// **'Enter a display name'**
  String get profileNameHint;

  /// Tooltip that clears the display name field
  ///
  /// In en, this message translates to:
  /// **'Clear name'**
  String get profileClearName;

  /// Email privacy explanation on the edit profile page
  ///
  /// In en, this message translates to:
  /// **'This email is linked to your account and is only shown here.'**
  String get profileEmailDescription;

  /// Avatar action sheet heading
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profileChangeAvatar;

  /// Camera avatar source action
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get profileTakePhoto;

  /// Gallery avatar source action
  ///
  /// In en, this message translates to:
  /// **'Upload photo'**
  String get profileUploadPhoto;

  /// Action that opens the current avatar
  ///
  /// In en, this message translates to:
  /// **'View photo'**
  String get profileViewPhoto;

  /// Full-screen profile photo page title
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profileAvatar;

  /// Image cropper title
  ///
  /// In en, this message translates to:
  /// **'Crop profile photo'**
  String get profileCropAvatar;

  /// Avatar update success message
  ///
  /// In en, this message translates to:
  /// **'Profile photo updated.'**
  String get profileAvatarUpdated;

  /// Avatar update failure message
  ///
  /// In en, this message translates to:
  /// **'Could not update the profile photo. Please try again.'**
  String get profileAvatarUpdateFailed;

  /// Photo picker failure message
  ///
  /// In en, this message translates to:
  /// **'Could not open the photo. Check photo access permission.'**
  String get profilePhotoOpenFailed;

  /// Display name update success message
  ///
  /// In en, this message translates to:
  /// **'Display name updated.'**
  String get profileNameUpdated;

  /// Display name update failure message
  ///
  /// In en, this message translates to:
  /// **'Could not update the name. Please try again.'**
  String get profileNameUpdateFailed;

  /// Display name required validation message
  ///
  /// In en, this message translates to:
  /// **'Name cannot be blank.'**
  String get profileNameRequired;

  /// Failure while reading the profile immediately after an update
  ///
  /// In en, this message translates to:
  /// **'Could not read the updated profile.'**
  String get profileUpdatedProfileReadFailed;

  /// Empty cast message
  ///
  /// In en, this message translates to:
  /// **'Cast information is unavailable'**
  String get detailCastUnavailable;

  /// Cast tab or section title
  ///
  /// In en, this message translates to:
  /// **'Cast'**
  String get detailCast;

  /// Movie recommendations loading failure
  ///
  /// In en, this message translates to:
  /// **'Could not load recommendations'**
  String get detailRecommendationsLoadFailed;

  /// Empty movie recommendations message
  ///
  /// In en, this message translates to:
  /// **'No recommendations'**
  String get detailNoRecommendations;

  /// Dialog message when an episode does not exist on the selected server
  ///
  /// In en, this message translates to:
  /// **'Episode {episode} is unavailable on the current server.'**
  String detailEpisodeNotFound(int episode);

  /// Empty episode list message
  ///
  /// In en, this message translates to:
  /// **'No episodes available'**
  String get detailNoEpisodes;

  /// Action that starts a particular server or dub version
  ///
  /// In en, this message translates to:
  /// **'Watch this version'**
  String get detailWatchThisVersion;

  /// Single movie server section label
  ///
  /// In en, this message translates to:
  /// **'Server'**
  String get detailServer;

  /// Fallback server name
  ///
  /// In en, this message translates to:
  /// **'Server {number}'**
  String detailServerNumber(int number);

  /// Episode range heading
  ///
  /// In en, this message translates to:
  /// **'Episodes 1–{count}'**
  String detailEpisodeRange(int count);

  /// Episode search input hint
  ///
  /// In en, this message translates to:
  /// **'Enter episode'**
  String get detailEnterEpisode;

  /// Movie detail loading error title
  ///
  /// In en, this message translates to:
  /// **'Could not load movie'**
  String get detailLoadMovieError;

  /// Episodes tab title
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get detailEpisodesTab;

  /// Recommendations tab title
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get detailRecommendationsTab;

  /// Comments tab title
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get detailCommentsTab;

  /// Badge for theatrical movies
  ///
  /// In en, this message translates to:
  /// **'In theaters'**
  String get detailInTheaters;

  /// Badge for exclusive subtitles
  ///
  /// In en, this message translates to:
  /// **'Exclusive subtitles'**
  String get detailExclusiveSubtitles;

  /// Movie director metadata label
  ///
  /// In en, this message translates to:
  /// **'Director:'**
  String get detailDirectorLabel;

  /// Movie record creation date metadata label
  ///
  /// In en, this message translates to:
  /// **'Added on:'**
  String get detailCreatedDateLabel;

  /// Movie production year metadata label
  ///
  /// In en, this message translates to:
  /// **'Production year:'**
  String get detailProductionYearLabel;

  /// Movie country metadata label
  ///
  /// In en, this message translates to:
  /// **'Country:'**
  String get detailCountryLabel;

  /// Action that starts the latest episode
  ///
  /// In en, this message translates to:
  /// **'Watch latest episode'**
  String get detailWatchLatestEpisode;

  /// Action that starts a full movie
  ///
  /// In en, this message translates to:
  /// **'Watch movie'**
  String get detailWatchMovie;

  /// Movie description section heading
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get detailIntroduction;

  /// Favorite movie action label
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get detailFavorite;

  /// Movie synopsis heading in the quick detail dialog
  ///
  /// In en, this message translates to:
  /// **'Synopsis'**
  String get detailContent;

  /// Dialog message when a movie has no playable episodes
  ///
  /// In en, this message translates to:
  /// **'This movie does not have any playable episodes yet. Please try again later.'**
  String get detailNoPlayableEpisodes;

  /// Movie details section or action
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailDetails;

  /// Video quality selection sheet title
  ///
  /// In en, this message translates to:
  /// **'Video quality'**
  String get detailVideoQuality;

  /// Formatted movie view count
  ///
  /// In en, this message translates to:
  /// **'{count} views'**
  String detailViews(String count);

  /// Formatted movie like count
  ///
  /// In en, this message translates to:
  /// **'{count} likes'**
  String detailLikes(String count);

  /// Relative update time less than one minute ago
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get detailUpdatedJustNow;

  /// Fallback name for a subtitle server
  ///
  /// In en, this message translates to:
  /// **'Subtitled'**
  String get playerSubtitleServer;

  /// Label for the currently playing episode or server
  ///
  /// In en, this message translates to:
  /// **'Now playing'**
  String get playerNowPlaying;

  /// Currently playing episode label
  ///
  /// In en, this message translates to:
  /// **'Now playing: {episode}'**
  String playerNowPlayingEpisode(String episode);

  /// Now-playing subtitle containing episode and server names
  ///
  /// In en, this message translates to:
  /// **'{episode} — {server}'**
  String playerEpisodeAndServer(String episode, String server);

  /// Player error when a server contains no source URL
  ///
  /// In en, this message translates to:
  /// **'This server has no playable source.'**
  String get playerSourceUnavailable;

  /// Player source loading failure
  ///
  /// In en, this message translates to:
  /// **'Could not load this movie source.'**
  String get playerSourceLoadFailed;

  /// Toast shown after enabling episode autoplay
  ///
  /// In en, this message translates to:
  /// **'Autoplay enabled'**
  String get playerAutoplayEnabled;

  /// Toast shown after disabling episode autoplay
  ///
  /// In en, this message translates to:
  /// **'Autoplay disabled'**
  String get playerAutoplayDisabled;

  /// Toast shown when navigating after the final episode
  ///
  /// In en, this message translates to:
  /// **'You have reached the last episode'**
  String get playerNoMoreEpisodes;

  /// Toast shown when navigating before the first episode
  ///
  /// In en, this message translates to:
  /// **'This is the first episode'**
  String get playerFirstEpisode;

  /// Generic video playback failure
  ///
  /// In en, this message translates to:
  /// **'Could not play the video. Please try again.'**
  String get playerPlaybackFailed;

  /// Action or accessibility label that starts playback
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get playerPlay;

  /// Action or accessibility label that pauses playback
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get playerPause;

  /// Accessibility label for dismissing the comments sheet
  ///
  /// In en, this message translates to:
  /// **'Pull down to close comments'**
  String get playerPullDownToCloseComments;

  /// Casting action tooltip
  ///
  /// In en, this message translates to:
  /// **'Play on TV'**
  String get playerPlayOnTv;

  /// Episode list button tooltip
  ///
  /// In en, this message translates to:
  /// **'Episode list'**
  String get playerEpisodeList;

  /// Accessibility label for the video seek bar
  ///
  /// In en, this message translates to:
  /// **'Video progress'**
  String get playerVideoProgress;

  /// Tooltip that closes the persistent player
  ///
  /// In en, this message translates to:
  /// **'Close player'**
  String get playerClose;

  /// Resume playback dialog title
  ///
  /// In en, this message translates to:
  /// **'Continue watching?'**
  String get playerContinueWatchingTitle;

  /// Resume playback dialog body
  ///
  /// In en, this message translates to:
  /// **'You were watching {episode}. Would you like to continue or restart from episode 1?'**
  String playerContinueWatchingBody(String episode);

  /// Action that restarts playback from episode 1
  ///
  /// In en, this message translates to:
  /// **'Restart from the beginning'**
  String get playerRestartFromBeginning;

  /// Action that resumes playback from history
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get playerContinue;

  /// Action that replies to a comment
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commentsReply;

  /// Number of replies to a comment
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No replies} =1{1 reply} other{{count} replies}}'**
  String commentsReplyCount(int count);

  /// Comments loading error title
  ///
  /// In en, this message translates to:
  /// **'Could not load comments'**
  String get commentsLoadFailedTitle;

  /// Empty comments title
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commentsEmptyTitle;

  /// Empty comments guidance
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your thoughts.'**
  String get commentsEmptySubtitle;

  /// Comment composer hint while editing
  ///
  /// In en, this message translates to:
  /// **'Edit comment...'**
  String get commentsEditHint;

  /// Comment composer hint while replying to a person
  ///
  /// In en, this message translates to:
  /// **'Reply to {name}...'**
  String commentsReplyToHint(String name);

  /// Reply composer hint
  ///
  /// In en, this message translates to:
  /// **'Add a reply...'**
  String get commentsAddReplyHint;

  /// Default comment composer hint
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get commentsComposerHint;

  /// Comment composer editing status
  ///
  /// In en, this message translates to:
  /// **'Editing comment'**
  String get commentsEditingStatus;

  /// Comment composer reply status
  ///
  /// In en, this message translates to:
  /// **'Replying to {name}'**
  String commentsReplyingStatus(String name);

  /// Comment input accessibility label
  ///
  /// In en, this message translates to:
  /// **'Write a comment'**
  String get commentsWrite;

  /// Send comment action tooltip
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get commentsSend;

  /// Accessibility label for closing a comment action menu
  ///
  /// In en, this message translates to:
  /// **'Close comment menu'**
  String get commentsCloseMenu;

  /// Toast after copying a comment
  ///
  /// In en, this message translates to:
  /// **'Comment copied'**
  String get commentsCopied;

  /// Action sheet title for the signed-in user's own comment
  ///
  /// In en, this message translates to:
  /// **'Your comment'**
  String get commentsYourComment;

  /// Comment report reason sheet title
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this comment?'**
  String get commentsReportReasonTitle;

  /// Toast after successfully reporting a comment
  ///
  /// In en, this message translates to:
  /// **'Report sent. Thank you.'**
  String get commentsReportSent;

  /// Delete comment confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete comment?'**
  String get commentsDeleteTitle;

  /// Delete comment confirmation explanation
  ///
  /// In en, this message translates to:
  /// **'Replies will be preserved.'**
  String get commentsRepliesPreserved;

  /// Delete comment confirmation action
  ///
  /// In en, this message translates to:
  /// **'Delete comment'**
  String get commentsDeleteAction;

  /// Comment sort sheet title and tooltip
  ///
  /// In en, this message translates to:
  /// **'Sort comments'**
  String get commentsSortTitle;

  /// Popular comment sort option
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get commentsPopular;

  /// Newest comment sort option
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get commentsNewest;

  /// Comments section count heading
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Comments} =1{1 comment} other{{count} comments}}'**
  String commentsCount(int count);

  /// Comment context menu copy action
  ///
  /// In en, this message translates to:
  /// **'Copy comment'**
  String get commentsCopy;

  /// Label for an edited comment
  ///
  /// In en, this message translates to:
  /// **'Edited'**
  String get commentsEdited;

  /// Placeholder shown for a deleted comment
  ///
  /// In en, this message translates to:
  /// **'Comment deleted'**
  String get commentsDeleted;

  /// Relative time for an event less than one minute ago
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get commentsJustNow;

  /// Relative time in minutes
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String commentsMinutesAgo(int count);

  /// Relative time in hours
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String commentsHoursAgo(int count);

  /// Relative time in days
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String commentsDaysAgo(int count);

  /// Relative time in weeks
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 week ago} other{{count} weeks ago}}'**
  String commentsWeeksAgo(int count);

  /// Relative time in months
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month ago} other{{count} months ago}}'**
  String commentsMonthsAgo(int count);

  /// Relative time in years
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year ago} other{{count} years ago}}'**
  String commentsYearsAgo(int count);

  /// Comment report reason for spam
  ///
  /// In en, this message translates to:
  /// **'Spam'**
  String get commentsSpamReason;

  /// Comment report reason for harassment
  ///
  /// In en, this message translates to:
  /// **'Harassment or abuse'**
  String get commentsHarassmentReason;

  /// Comment report reason for spoilers
  ///
  /// In en, this message translates to:
  /// **'Movie spoiler'**
  String get commentsSpoilerReason;

  /// Comment report reason for inappropriate content
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get commentsInappropriateReason;

  /// Fallback comment report reason
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get commentsOtherReason;

  /// Initial comments loading failure
  ///
  /// In en, this message translates to:
  /// **'Could not load comments. Please try again.'**
  String get commentsLoadFailed;

  /// Pagination failure for comments
  ///
  /// In en, this message translates to:
  /// **'Could not load more comments.'**
  String get commentsLoadMoreFailed;

  /// Initial replies loading failure
  ///
  /// In en, this message translates to:
  /// **'Could not load replies.'**
  String get commentsRepliesLoadFailed;

  /// Pagination failure for replies
  ///
  /// In en, this message translates to:
  /// **'Could not load more replies.'**
  String get commentsRepliesLoadMoreFailed;

  /// Comment submission failure
  ///
  /// In en, this message translates to:
  /// **'Could not send the comment. Your text has been preserved.'**
  String get commentsSendFailed;

  /// Comment editing failure
  ///
  /// In en, this message translates to:
  /// **'Could not edit the comment.'**
  String get commentsEditFailed;

  /// Comment deletion failure
  ///
  /// In en, this message translates to:
  /// **'Could not delete the comment.'**
  String get commentsDeleteFailed;

  /// Comment reaction update failure
  ///
  /// In en, this message translates to:
  /// **'Could not update the reaction.'**
  String get commentsReactionFailed;

  /// Comment report failure
  ///
  /// In en, this message translates to:
  /// **'This comment has already been reported or the report could not be sent.'**
  String get commentsReportFailed;

  /// Message shown when the same comment operation is already running
  ///
  /// In en, this message translates to:
  /// **'This action is already in progress.'**
  String get commentsOperationInProgress;

  /// Empty notification inbox message
  ///
  /// In en, this message translates to:
  /// **'No new notifications'**
  String get notificationsEmpty;

  /// Action phrase in a reply notification
  ///
  /// In en, this message translates to:
  /// **'replied to your comment'**
  String get notificationsRepliedToYourComment;

  /// Action phrase in a reaction notification
  ///
  /// In en, this message translates to:
  /// **'liked your comment'**
  String get notificationsLikedYourComment;

  /// Notification date group for today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notificationsToday;

  /// Notification date group for yesterday
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get notificationsYesterday;

  /// Fallback actor name in a notification
  ///
  /// In en, this message translates to:
  /// **'Someone'**
  String get notificationsUnknownUser;

  /// Notification channel and single new movie notification title
  ///
  /// In en, this message translates to:
  /// **'New movie'**
  String get notificationsNewMovieTitle;

  /// Notification title for multiple new movies
  ///
  /// In en, this message translates to:
  /// **'{count} new movies'**
  String notificationsNewMoviesTitle(int count);

  /// Single new movie notification body
  ///
  /// In en, this message translates to:
  /// **'{movieName} was just added to Liquid Phim.'**
  String notificationsMovieAdded(String movieName);

  /// Android new movie notification channel description
  ///
  /// In en, this message translates to:
  /// **'Notifications when Liquid Phim discovers new movies'**
  String get notificationsNewMovieChannelDescription;

  /// Casting device sheet title
  ///
  /// In en, this message translates to:
  /// **'Choose a device'**
  String get castChooseDevice;

  /// AirPlay launch failure dialog title
  ///
  /// In en, this message translates to:
  /// **'Could not open AirPlay'**
  String get castAirPlayUnavailableTitle;

  /// AirPlay launch failure guidance
  ///
  /// In en, this message translates to:
  /// **'Make sure your iPhone and TV or Mac are on the same Wi-Fi network, then try again.'**
  String get castAirPlayUnavailableBody;

  /// Casting dialog title when video is not ready
  ///
  /// In en, this message translates to:
  /// **'No video available'**
  String get castVideoUnavailableTitle;

  /// Casting guidance when video is not ready
  ///
  /// In en, this message translates to:
  /// **'Wait for the video to load, then choose a Google Cast device.'**
  String get castVideoUnavailableBody;

  /// Google Cast connection failure title
  ///
  /// In en, this message translates to:
  /// **'Could not connect to Google Cast'**
  String get castConnectionFailedTitle;

  /// Google Cast connection failure guidance
  ///
  /// In en, this message translates to:
  /// **'Check Google Play services and make sure your phone and Chromecast or Google TV are on the same Wi-Fi network.'**
  String get castConnectionFailedBody;

  /// AirPlay route picker item title
  ///
  /// In en, this message translates to:
  /// **'AirPlay and Bluetooth devices'**
  String get castAirPlayAndBluetoothDevices;

  /// Casting device connection state
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get castConnecting;

  /// Casting device discovery loading state
  ///
  /// In en, this message translates to:
  /// **'Searching for Google Cast devices...'**
  String get castSearching;

  /// Casting device discovery empty state
  ///
  /// In en, this message translates to:
  /// **'No devices found'**
  String get castNoDevices;

  /// Casting device discovery guidance
  ///
  /// In en, this message translates to:
  /// **'Make sure your phone and Chromecast or Google TV are on the same Wi-Fi network.'**
  String get castSameWifiGuidance;

  /// Action that restarts casting device discovery
  ///
  /// In en, this message translates to:
  /// **'Search again'**
  String get castSearchAgain;

  /// Fallback Google Cast device name
  ///
  /// In en, this message translates to:
  /// **'Google Cast device'**
  String get castDefaultDeviceName;

  /// Movie share sheet subject
  ///
  /// In en, this message translates to:
  /// **'Watch {movieName} on Liquid Phim'**
  String shareMovieSubject(String movieName);

  /// Share sheet launch failure
  ///
  /// In en, this message translates to:
  /// **'Could not open the share sheet.'**
  String get shareOpenFailed;

  /// Favorite movies ranking title
  ///
  /// In en, this message translates to:
  /// **'TOP favorite movies'**
  String get rankingTopFavorites;

  /// Overall Liquid Phim ranking title
  ///
  /// In en, this message translates to:
  /// **'Liquid Phim TOP 30'**
  String get rankingTopLiquidPhim;

  /// Hot single movies ranking title
  ///
  /// In en, this message translates to:
  /// **'TOP 30 hot movies'**
  String get rankingTopHotMovies;

  /// Most viewed ranking subtitle
  ///
  /// In en, this message translates to:
  /// **'MOST VIEWED'**
  String get rankingMostViewed;

  /// Most liked ranking subtitle
  ///
  /// In en, this message translates to:
  /// **'MOST LIKED'**
  String get rankingMostLiked;

  /// Empty most-liked ranking message
  ///
  /// In en, this message translates to:
  /// **'The ranking will appear after movies receive likes.'**
  String get rankingEmptyLikes;

  /// Empty most-viewed ranking message
  ///
  /// In en, this message translates to:
  /// **'The ranking will appear after movies receive views.'**
  String get rankingEmptyViews;

  /// Ranking loading failure
  ///
  /// In en, this message translates to:
  /// **'Could not load the ranking.'**
  String get rankingLoadFailed;

  /// Episode number label
  ///
  /// In en, this message translates to:
  /// **'Episode {number}'**
  String playerEpisodeNumber(int number);

  /// Month label
  ///
  /// In en, this message translates to:
  /// **'Month {month}'**
  String libraryMonthLabel(int month);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'en',
    'ja',
    'ko',
    'th',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hans':
            return AppLocalizationsZhHans();
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'th':
      return AppLocalizationsTh();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
