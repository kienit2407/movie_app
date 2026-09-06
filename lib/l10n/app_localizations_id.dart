// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Liquid Phim';

  @override
  String get appTagline => 'Film kapan saja, di mana saja';

  @override
  String get commonAgree => 'OK';

  @override
  String get commonCancel => 'Batal';

  @override
  String get commonClose => 'Tutup';

  @override
  String get commonDone => 'Selesai';

  @override
  String get commonSave => 'Simpan';

  @override
  String get commonDelete => 'Hapus';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonReport => 'Laporkan';

  @override
  String get commonRetry => 'Coba lagi';

  @override
  String get commonReset => 'Atur ulang';

  @override
  String get commonAll => 'Semua';

  @override
  String get commonSeeMore => 'Lihat lainnya';

  @override
  String get commonCollapse => 'Tampilkan lebih sedikit';

  @override
  String get commonLoading => 'Memuat...';

  @override
  String get commonUpdating => 'Memperbarui';

  @override
  String get commonUnderstood => 'Mengerti';

  @override
  String get commonNoData => 'Tidak ada data';

  @override
  String get commonNotAvailable => 'T/A';

  @override
  String get commonWarningTitle => 'Peringatan';

  @override
  String get commonNoticeTitle => 'Pemberitahuan';

  @override
  String get commonCongratulationsTitle => 'Selamat!';

  @override
  String get commonBack => 'Kembali';

  @override
  String get commonGoHome => 'Ke beranda';

  @override
  String commonSelectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dipilih',
      one: '1 dipilih',
      zero: 'Tidak ada yang dipilih',
    );
    return '$_temp0';
  }

  @override
  String commonErrorWithDetails(String error) {
    return 'Kesalahan: $error';
  }

  @override
  String commonDurationHoursMinutes(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hours jam',
      one: '1 jam',
    );
    String _temp1 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes menit',
      one: '1 menit',
    );
    return '$_temp0 $_temp1';
  }

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get settingsLanguageSystem => 'Gunakan bahasa perangkat';

  @override
  String get settingsLanguageVietnamese => 'Tiếng Việt';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageJapanese => '日本語';

  @override
  String get settingsLanguageThai => 'ไทย';

  @override
  String get settingsLanguageKorean => '한국어';

  @override
  String get settingsLanguageChineseSimplified => '简体中文';

  @override
  String get settingsLanguageChineseTraditional => '繁體中文';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get settingsGeneralSection => 'Umum';

  @override
  String get settingsAppLanguage => 'Bahasa aplikasi';

  @override
  String get settingsAccountSection => 'Akun';

  @override
  String get settingsSwitchAccount => 'Ganti akun';

  @override
  String get settingsAddAccount => 'Tambah akun';

  @override
  String get settingsAccountSwitchFailed =>
      'Tidak dapat mengganti akun. Silakan masuk kembali ke akun tersebut.';

  @override
  String get settingsSignOutFailed => 'Tidak dapat keluar. Silakan coba lagi.';

  @override
  String get navHome => 'Beranda';

  @override
  String get navSearch => 'Cari';

  @override
  String get navFavorites => 'Favorit';

  @override
  String get navProfile => 'Profil';

  @override
  String get navNotifications => 'Notifikasi';

  @override
  String get internetOffline => 'Tidak ada koneksi Internet';

  @override
  String get internetBackOnline => 'Kembali online';

  @override
  String get authJoinMember => 'Bergabung sebagai anggota';

  @override
  String get authSignInTitle => 'Masuk ke Liquid Phim';

  @override
  String get authSignIn => 'Masuk';

  @override
  String get authSignInFailed => 'Gagal masuk. Silakan coba lagi.';

  @override
  String get authSignInToComment =>
      'Masuk untuk berkomentar dan berinteraksi dengan komunitas.';

  @override
  String get authGoogleSyncDescription =>
      'Lanjutkan dengan Google untuk menyinkronkan akun dan bergabung dengan komunitas.';

  @override
  String get authGoogleConsent =>
      'Dengan melanjutkan, Anda menyetujui penggunaan akun Google Anda dengan Liquid Phim.';

  @override
  String get authContinueWithGoogle => 'Lanjutkan dengan Google';

  @override
  String get authGoogleSignInFailed =>
      'Tidak dapat masuk dengan Google. Silakan coba lagi.';

  @override
  String get authGoogleSignInCheckFailed =>
      'Tidak dapat masuk dengan Google. Periksa koneksi Anda lalu coba lagi.';

  @override
  String get authSessionUpdateFailed =>
      'Tidak dapat memperbarui sesi masuk Anda.';

  @override
  String get authLoginRequired => 'Anda harus masuk.';

  @override
  String get authLoginRequiredForAction =>
      'Anda harus masuk untuk melakukan tindakan ini.';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Kata sandi';

  @override
  String get authFullName => 'Nama lengkap';

  @override
  String get authForgotPassword => 'Lupa kata sandi?';

  @override
  String get authOrContinueWith => 'Atau lanjutkan dengan';

  @override
  String get authAlreadyHaveAccount => 'Sudah memiliki akun?';

  @override
  String get authFullNameRequired => 'Nama lengkap tidak boleh kosong.';

  @override
  String get authFullNameLength =>
      'Nama lengkap harus berisi antara 3 dan 15 karakter.';

  @override
  String get authEmailRequired => 'Email tidak boleh kosong.';

  @override
  String get authEmailInvalid => 'Masukkan alamat email yang valid.';

  @override
  String get authPasswordRequired => 'Kata sandi tidak boleh kosong.';

  @override
  String get authPasswordLength =>
      'Kata sandi harus berisi antara 6 dan 15 karakter.';

  @override
  String get authAccountAlreadyExists =>
      'Akun ini sudah ada. Silakan pilih email lain.';

  @override
  String get authWeakPassword =>
      'Kata sandi ini terlalu lemah. Masukkan kata sandi yang lebih kuat.';

  @override
  String get authInvalidCredentials =>
      'Email atau kata sandi salah. Silakan coba lagi.';

  @override
  String get authUnexpectedError => 'Terjadi kesalahan. Silakan coba lagi.';

  @override
  String get authSignUpFailed =>
      'Tidak dapat membuat akun Anda. Silakan coba lagi.';

  @override
  String get authSignUpSucceeded => 'Akun Anda telah dibuat.';

  @override
  String get authSignInSucceeded => 'Berhasil masuk.';

  @override
  String get authSignOutSucceeded => 'Berhasil keluar.';

  @override
  String get authTokenConfirmed => 'Kode verifikasi dikonfirmasi.';

  @override
  String get authTokenInvalid => 'Kode verifikasi salah.';

  @override
  String get homeEnableNewMovieNotificationsTitle =>
      'Dapatkan notifikasi film baru?';

  @override
  String get homeEnableNewMovieNotificationsBody =>
      'Liquid Phim dapat memeriksa secara berkala di latar belakang dan memberi tahu Anda saat menemukan film baru. Sistem operasi mungkin menunda pemeriksaan lebih dari 20 menit untuk menghemat baterai.';

  @override
  String get homeEnableNotifications => 'Aktifkan notifikasi';

  @override
  String get homeDoNotEnable => 'Nanti saja';

  @override
  String get homeNotificationPermissionDisabled =>
      'Izin notifikasi dinonaktifkan. Anda dapat mengaktifkannya kembali di pengaturan ponsel.';

  @override
  String get homeLoadMoviesFailed =>
      'Film tidak dapat dimuat.\nTarik ke bawah untuk mencoba lagi.';

  @override
  String get homeRecommended => 'Direkomendasikan';

  @override
  String get homeGenres => 'Genre';

  @override
  String get homeCountries => 'Negara';

  @override
  String get homeYear => 'Tahun';

  @override
  String get homeFreshMovies => 'Rilis terbaru!';

  @override
  String get homeKoreanMovies => 'Film Korea';

  @override
  String get homeChineseMovies => 'Film Tiongkok';

  @override
  String get homeUsUkMovies => 'Film AS & Inggris';

  @override
  String get homeWatchMovie => 'Tonton';

  @override
  String get homeInformation => 'Info';

  @override
  String get homeViewAll => 'Lihat semua';

  @override
  String get homeWhatToWatch => 'Apa yang ingin Anda tonton hari ini?';

  @override
  String get homeViewMore => 'Lihat lainnya';

  @override
  String homeAppVersion(String version, String buildNumber) {
    return 'Versi: $version ($buildNumber)';
  }

  @override
  String get filterMovieType => 'Jenis film';

  @override
  String get filterSeries => 'Serial';

  @override
  String get filterSingleMovies => 'Film';

  @override
  String get filterAnimation => 'Animasi';

  @override
  String get filterTvShows => 'Acara TV';

  @override
  String get filterSubtitled => 'Bersubtitel';

  @override
  String get filterVoiceOver => 'Sulih suara narasi';

  @override
  String get filterDubbed => 'Dubbing';

  @override
  String get filterChooseMovieType => 'Silakan pilih jenis film.';

  @override
  String get filterChooseGenre => 'Silakan pilih genre.';

  @override
  String get filterChooseCountry => 'Pilih negara untuk memfilter.';

  @override
  String get filterChooseYear => 'Pilih tahun untuk memfilter.';

  @override
  String get filterLanguage => 'Bahasa';

  @override
  String get filterSortBy => 'Urutkan berdasarkan';

  @override
  String get filterSortDirection => 'Arah pengurutan';

  @override
  String get filterDescending => 'Menurun';

  @override
  String get filterAscending => 'Menaik';

  @override
  String get filterMostViewed => 'Paling banyak ditonton';

  @override
  String get filterNewest => 'Terbaru';

  @override
  String get filterReleaseYear => 'Tahun rilis';

  @override
  String get filterApply => 'Terapkan filter';

  @override
  String get filterResults => 'Filter hasil';

  @override
  String get searchAttentionTitle => 'Perhatian';

  @override
  String get searchEnterKeywordBeforeFiltering =>
      'Masukkan kata kunci sebelum memfilter film.';

  @override
  String get searchNoResults => 'Tidak ada hasil ditemukan';

  @override
  String get searchMovieActorHint => 'Cari film, aktor...';

  @override
  String get searchFilterTooltip => 'Filter pencarian';

  @override
  String get searchStartPrompt => 'Masukkan judul film untuk mulai mencari';

  @override
  String get searchRecent => 'Pencarian terbaru';

  @override
  String get searchLoadingGenres => 'Memuat genre...';

  @override
  String get searchLoadingCountries => 'Memuat negara...';

  @override
  String get searchNoMovies => 'Tidak ada film';

  @override
  String get searchTryDifferentFilters => 'Coba filter lain';

  @override
  String get librarySignOutTitle => 'Keluar?';

  @override
  String get librarySignOutConfirmation =>
      'Apakah Anda yakin ingin keluar dari akun ini?';

  @override
  String get librarySignOut => 'Keluar';

  @override
  String libraryDeleteSelectedMoviesTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count film yang dipilih?',
      one: 'Hapus film yang dipilih?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteHistoryMovieTitle => 'Hapus film ini dari riwayat?';

  @override
  String libraryDeleteHistoryConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count film dari riwayat tontonan?',
      one: 'Hapus film ini dari riwayat tontonan?',
    );
    return '$_temp0';
  }

  @override
  String get libraryDeleteFavoriteMovieTitle => 'Hapus film ini dari favorit?';

  @override
  String libraryDeleteFavoritesConfirmation(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hapus $count film dari favorit?',
      one: 'Hapus film ini dari favorit?',
    );
    return '$_temp0';
  }

  @override
  String get libraryCancelSelection => 'Batalkan pilihan';

  @override
  String get libraryDeleteSelectedMovies => 'Hapus film yang dipilih';

  @override
  String get libraryCannotResumeMovie =>
      'Film ini tidak dapat dilanjutkan sekarang.';

  @override
  String get libraryYourProfile => 'Profil Anda';

  @override
  String get librarySignInProfileDescription =>
      'Masuk untuk mengedit profil dan menyinkronkan riwayat tontonan Anda.';

  @override
  String get libraryWatchHistory => 'Riwayat tontonan';

  @override
  String get libraryNoWatchHistory => 'Belum ada riwayat tontonan';

  @override
  String get libraryFavorites => 'Favorit';

  @override
  String get librarySignInToSaveFavorites =>
      'Masuk untuk menyimpan film favorit';

  @override
  String get libraryFavoritesSyncDescription =>
      'Daftar Anda akan disinkronkan di semua perangkat.';

  @override
  String get libraryNoFavorites => 'Belum ada film favorit';

  @override
  String get libraryRemoveFromList => 'Hapus dari daftar';

  @override
  String libraryContinueProgress(int progress) {
    return 'Lanjutkan $progress%';
  }

  @override
  String libraryDateDayMonth(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.MMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '$dateString';
  }

  @override
  String get libraryLoadFailed =>
      'Tidak dapat memuat pustaka Anda. Silakan coba lagi.';

  @override
  String get libraryFavoriteUpdateFailed =>
      'Tidak dapat memperbarui favorit. Silakan coba lagi.';

  @override
  String get libraryFavoriteRemoveFailed =>
      'Tidak dapat menghapus favorit. Silakan coba lagi.';

  @override
  String get libraryHistorySyncLater =>
      'Riwayat Anda akan disinkronkan lagi nanti.';

  @override
  String get libraryHistoryDeleteFailed =>
      'Tidak dapat menghapus riwayat tontonan. Silakan coba lagi.';

  @override
  String get profileEdit => 'Edit profil';

  @override
  String get profileChangePhoto => 'Ganti foto';

  @override
  String get profileName => 'Nama';

  @override
  String get profileNameDescription =>
      'Nama ini akan muncul di profil Liquid Phim Anda.';

  @override
  String get profileNameHint => 'Masukkan nama tampilan';

  @override
  String get profileClearName => 'Hapus nama';

  @override
  String get profileEmailDescription =>
      'Email ini terhubung ke akun Anda dan hanya ditampilkan di sini.';

  @override
  String get profileChangeAvatar => 'Ganti foto profil';

  @override
  String get profileTakePhoto => 'Ambil foto';

  @override
  String get profileUploadPhoto => 'Unggah foto';

  @override
  String get profileViewPhoto => 'Lihat foto';

  @override
  String get profileAvatar => 'Foto profil';

  @override
  String get profileCropAvatar => 'Pangkas foto profil';

  @override
  String get profileAvatarUpdated => 'Foto profil diperbarui.';

  @override
  String get profileAvatarUpdateFailed =>
      'Tidak dapat memperbarui foto profil. Silakan coba lagi.';

  @override
  String get profilePhotoOpenFailed =>
      'Tidak dapat membuka foto. Periksa izin akses foto.';

  @override
  String get profileNameUpdated => 'Nama tampilan diperbarui.';

  @override
  String get profileNameUpdateFailed =>
      'Tidak dapat memperbarui nama. Silakan coba lagi.';

  @override
  String get profileNameRequired => 'Nama tidak boleh kosong.';

  @override
  String get profileUpdatedProfileReadFailed =>
      'Tidak dapat membaca profil yang diperbarui.';

  @override
  String get detailCastUnavailable => 'Informasi pemeran tidak tersedia';

  @override
  String get detailCast => 'Pemeran';

  @override
  String get detailRecommendationsLoadFailed =>
      'Tidak dapat memuat rekomendasi';

  @override
  String get detailNoRecommendations => 'Tidak ada rekomendasi';

  @override
  String detailEpisodeNotFound(int episode) {
    return 'Episode $episode tidak tersedia di server saat ini.';
  }

  @override
  String get detailNoEpisodes => 'Tidak ada episode tersedia';

  @override
  String get detailWatchThisVersion => 'Tonton versi ini';

  @override
  String get detailServer => 'Server';

  @override
  String detailServerNumber(int number) {
    return 'Server $number';
  }

  @override
  String detailEpisodeRange(int count) {
    return 'Episode 1–$count';
  }

  @override
  String get detailEnterEpisode => 'Masukkan episode';

  @override
  String get detailLoadMovieError => 'Tidak dapat memuat film';

  @override
  String get detailEpisodesTab => 'Episode';

  @override
  String get detailRecommendationsTab => 'Rekomendasi';

  @override
  String get detailCommentsTab => 'Komentar';

  @override
  String get detailInTheaters => 'Sedang tayang di bioskop';

  @override
  String get detailExclusiveSubtitles => 'Subtitle eksklusif';

  @override
  String get detailDirectorLabel => 'Sutradara:';

  @override
  String get detailCreatedDateLabel => 'Ditambahkan pada:';

  @override
  String get detailProductionYearLabel => 'Tahun produksi:';

  @override
  String get detailCountryLabel => 'Negara:';

  @override
  String get detailWatchLatestEpisode => 'Tonton episode terbaru';

  @override
  String get detailWatchMovie => 'Tonton film';

  @override
  String get detailIntroduction => 'Ikhtisar';

  @override
  String get detailFavorite => 'Favorit';

  @override
  String get detailContent => 'Sinopsis';

  @override
  String get detailNoPlayableEpisodes =>
      'Film ini belum memiliki episode yang dapat diputar. Silakan coba lagi nanti.';

  @override
  String get detailDetails => 'Detail';

  @override
  String get detailVideoQuality => 'Kualitas video';

  @override
  String detailViews(String count) {
    return '$count tayangan';
  }

  @override
  String detailLikes(String count) {
    return '$count suka';
  }

  @override
  String get detailUpdatedJustNow => 'Baru saja diperbarui';

  @override
  String get playerSubtitleServer => 'Bersubtitel';

  @override
  String get playerNowPlaying => 'Sedang diputar';

  @override
  String playerNowPlayingEpisode(String episode) {
    return 'Sedang diputar: $episode';
  }

  @override
  String playerEpisodeAndServer(String episode, String server) {
    return '$episode — $server';
  }

  @override
  String get playerSourceUnavailable =>
      'Server ini tidak memiliki sumber yang dapat diputar.';

  @override
  String get playerSourceLoadFailed => 'Tidak dapat memuat sumber film ini.';

  @override
  String get playerAutoplayEnabled => 'Putar otomatis diaktifkan';

  @override
  String get playerAutoplayDisabled => 'Putar otomatis dinonaktifkan';

  @override
  String get playerNoMoreEpisodes => 'Anda telah mencapai episode terakhir';

  @override
  String get playerFirstEpisode => 'Ini adalah episode pertama';

  @override
  String get playerPlaybackFailed =>
      'Video tidak dapat diputar. Silakan coba lagi.';

  @override
  String get playerPlay => 'Putar';

  @override
  String get playerPause => 'Jeda';

  @override
  String get playerPullDownToCloseComments =>
      'Tarik ke bawah untuk menutup komentar';

  @override
  String get playerPlayOnTv => 'Putar di TV';

  @override
  String get playerEpisodeList => 'Daftar episode';

  @override
  String get playerVideoProgress => 'Progres video';

  @override
  String get playerClose => 'Tutup pemutar';

  @override
  String get playerContinueWatchingTitle => 'Lanjut menonton?';

  @override
  String playerContinueWatchingBody(String episode) {
    return 'Anda sedang menonton $episode. Ingin melanjutkan atau mulai ulang dari episode 1?';
  }

  @override
  String get playerRestartFromBeginning => 'Mulai ulang dari awal';

  @override
  String get playerContinue => 'Lanjutkan';

  @override
  String get commentsReply => 'Balas';

  @override
  String commentsReplyCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count balasan',
      one: '1 balasan',
      zero: 'Tidak ada balasan',
    );
    return '$_temp0';
  }

  @override
  String get commentsLoadFailedTitle => 'Tidak dapat memuat komentar';

  @override
  String get commentsEmptyTitle => 'Belum ada komentar';

  @override
  String get commentsEmptySubtitle =>
      'Jadilah yang pertama membagikan pendapat Anda.';

  @override
  String get commentsEditHint => 'Edit komentar...';

  @override
  String commentsReplyToHint(String name) {
    return 'Balas $name...';
  }

  @override
  String get commentsAddReplyHint => 'Tambahkan balasan...';

  @override
  String get commentsComposerHint => 'Tulis komentar...';

  @override
  String get commentsEditingStatus => 'Mengedit komentar';

  @override
  String commentsReplyingStatus(String name) {
    return 'Membalas $name';
  }

  @override
  String get commentsWrite => 'Tulis komentar';

  @override
  String get commentsSend => 'Kirim';

  @override
  String get commentsCloseMenu => 'Tutup menu komentar';

  @override
  String get commentsCopied => 'Komentar disalin';

  @override
  String get commentsYourComment => 'Komentar Anda';

  @override
  String get commentsReportReasonTitle =>
      'Mengapa Anda melaporkan komentar ini?';

  @override
  String get commentsReportSent => 'Laporan terkirim. Terima kasih.';

  @override
  String get commentsDeleteTitle => 'Hapus komentar?';

  @override
  String get commentsRepliesPreserved => 'Balasan akan tetap disimpan.';

  @override
  String get commentsDeleteAction => 'Hapus komentar';

  @override
  String get commentsSortTitle => 'Urutkan komentar';

  @override
  String get commentsPopular => 'Populer';

  @override
  String get commentsNewest => 'Terbaru';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count komentar',
      one: '1 komentar',
      zero: 'Komentar',
    );
    return '$_temp0';
  }

  @override
  String get commentsCopy => 'Salin komentar';

  @override
  String get commentsEdited => 'Diedit';

  @override
  String get commentsDeleted => 'Komentar dihapus';

  @override
  String get commentsJustNow => 'baru saja';

  @override
  String commentsMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count menit yang lalu',
      one: '1 menit yang lalu',
    );
    return '$_temp0';
  }

  @override
  String commentsHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jam yang lalu',
      one: '1 jam yang lalu',
    );
    return '$_temp0';
  }

  @override
  String commentsDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hari yang lalu',
      one: '1 hari yang lalu',
    );
    return '$_temp0';
  }

  @override
  String commentsWeeksAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minggu yang lalu',
      one: '1 minggu yang lalu',
    );
    return '$_temp0';
  }

  @override
  String commentsMonthsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bulan yang lalu',
      one: '1 bulan yang lalu',
    );
    return '$_temp0';
  }

  @override
  String commentsYearsAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tahun yang lalu',
      one: '1 tahun yang lalu',
    );
    return '$_temp0';
  }

  @override
  String get commentsSpamReason => 'Spam';

  @override
  String get commentsHarassmentReason => 'Pelecehan atau penyalahgunaan';

  @override
  String get commentsSpoilerReason => 'Spoiler film';

  @override
  String get commentsInappropriateReason => 'Konten tidak pantas';

  @override
  String get commentsOtherReason => 'Alasan lain';

  @override
  String get commentsLoadFailed =>
      'Tidak dapat memuat komentar. Silakan coba lagi.';

  @override
  String get commentsLoadMoreFailed => 'Tidak dapat memuat komentar lainnya.';

  @override
  String get commentsRepliesLoadFailed => 'Tidak dapat memuat balasan.';

  @override
  String get commentsRepliesLoadMoreFailed =>
      'Tidak dapat memuat balasan lainnya.';

  @override
  String get commentsSendFailed =>
      'Tidak dapat mengirim komentar. Teks Anda tetap disimpan.';

  @override
  String get commentsEditFailed => 'Tidak dapat mengedit komentar.';

  @override
  String get commentsDeleteFailed => 'Tidak dapat menghapus komentar.';

  @override
  String get commentsReactionFailed => 'Tidak dapat memperbarui reaksi.';

  @override
  String get commentsReportFailed =>
      'Komentar ini sudah dilaporkan atau laporan tidak dapat dikirim.';

  @override
  String get commentsOperationInProgress => 'Tindakan ini sedang berlangsung.';

  @override
  String get notificationsEmpty => 'Tidak ada notifikasi baru';

  @override
  String get notificationsRepliedToYourComment => 'membalas komentar Anda';

  @override
  String get notificationsLikedYourComment => 'menyukai komentar Anda';

  @override
  String get notificationsToday => 'Hari ini';

  @override
  String get notificationsYesterday => 'Kemarin';

  @override
  String get notificationsUnknownUser => 'Seseorang';

  @override
  String get notificationsNewMovieTitle => 'Film baru';

  @override
  String notificationsNewMoviesTitle(int count) {
    return '$count film baru';
  }

  @override
  String notificationsMovieAdded(String movieName) {
    return '$movieName baru saja ditambahkan ke Liquid Phim.';
  }

  @override
  String get notificationsNewMovieChannelDescription =>
      'Notifikasi saat Liquid Phim menemukan film baru';

  @override
  String get castChooseDevice => 'Pilih perangkat';

  @override
  String get castAirPlayUnavailableTitle => 'Tidak dapat membuka AirPlay';

  @override
  String get castAirPlayUnavailableBody =>
      'Pastikan iPhone dan TV atau Mac Anda berada di jaringan Wi-Fi yang sama, lalu coba lagi.';

  @override
  String get castVideoUnavailableTitle => 'Tidak ada video tersedia';

  @override
  String get castVideoUnavailableBody =>
      'Tunggu hingga video dimuat, lalu pilih perangkat Google Cast.';

  @override
  String get castConnectionFailedTitle =>
      'Tidak dapat terhubung ke Google Cast';

  @override
  String get castConnectionFailedBody =>
      'Periksa layanan Google Play dan pastikan ponsel Anda serta Chromecast atau Google TV berada di jaringan Wi-Fi yang sama.';

  @override
  String get castAirPlayAndBluetoothDevices =>
      'Perangkat AirPlay dan Bluetooth';

  @override
  String get castConnecting => 'Menghubungkan...';

  @override
  String get castSearching => 'Mencari perangkat Google Cast...';

  @override
  String get castNoDevices => 'Tidak ada perangkat ditemukan';

  @override
  String get castSameWifiGuidance =>
      'Pastikan ponsel Anda serta Chromecast atau Google TV berada di jaringan Wi-Fi yang sama.';

  @override
  String get castSearchAgain => 'Cari lagi';

  @override
  String get castDefaultDeviceName => 'Perangkat Google Cast';

  @override
  String shareMovieSubject(String movieName) {
    return 'Tonton $movieName di Liquid Phim';
  }

  @override
  String get shareOpenFailed => 'Tidak dapat membuka lembar berbagi.';

  @override
  String get rankingTopFavorites => 'TOP film favorit';

  @override
  String get rankingTopLiquidPhim => 'TOP 30 Liquid Phim';

  @override
  String get rankingTopHotMovies => 'TOP 30 film populer';

  @override
  String get rankingMostViewed => 'PALING BANYAK DITONTON';

  @override
  String get rankingMostLiked => 'PALING BANYAK DISUKAI';

  @override
  String get rankingEmptyLikes =>
      'Peringkat akan muncul setelah film mendapatkan suka.';

  @override
  String get rankingEmptyViews =>
      'Peringkat akan muncul setelah film mendapatkan tayangan.';

  @override
  String get rankingLoadFailed => 'Tidak dapat memuat peringkat.';

  @override
  String playerEpisodeNumber(int number) {
    return 'Episode $number';
  }

  @override
  String libraryMonthLabel(int month) {
    return 'Bulan $month';
  }
}
