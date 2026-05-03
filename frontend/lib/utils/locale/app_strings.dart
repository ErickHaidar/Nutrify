import 'package:shared_preferences/shared_preferences.dart';
import 'package:nutrify/di/service_locator.dart';

/// Centralized localization strings for Nutrify.
/// Supports Indonesian (id) and English (en).
class AppStrings {
  AppStrings._();

  static String _currentLocale = 'id';

  static String get currentLocale => _currentLocale;

  static void init() {
    final prefs = getIt<SharedPreferences>();
    _currentLocale = prefs.getString('app_locale') ?? 'id';
  }

  static Future<void> setLocale(String locale) async {
    _currentLocale = locale;
    final prefs = getIt<SharedPreferences>();
    await prefs.setString('app_locale', locale);
  }

  static bool get isId => _currentLocale == 'id';

  // ─── Helper ──────────────────────────────────────────────────────────────
  static String _t(String id, String en) => isId ? id : en;

  // ─── Common ──────────────────────────────────────────────────────────────
  static String get appName => 'Nutrify';
  static String get save => _t('Simpan', 'Save');
  static String get cancel => _t('Batal', 'Cancel');
  static String get delete => _t('Hapus', 'Delete');
  static String get edit => _t('Edit', 'Edit');
  static String get close => _t('Tutup', 'Close');
  static String get ok => _t('Oke', 'OK');
  static String get confirm => _t('Konfirmasi', 'Confirm');
  static String get loading => _t('Memuat...', 'Loading...');
  static String get error => _t('Kesalahan', 'Error');
  static String get success => _t('Berhasil', 'Success');
  static String get failedToSave => _t('Gagal menyimpan', 'Failed to save');
  static String get understand => _t('Mengerti', 'Got it');
  static String get or_ => _t('Atau', 'Or');

  // ─── Splash ──────────────────────────────────────────────────────────────
  static String get splashSubtitle =>
      _t('Lacak kalorimu. Ubah hidupmu.', 'Track your calories. Transform your life.');
  static String get failedToStart =>
      _t('Nutrify gagal memulai.', 'Nutrify failed to start.');

  // ─── Login ───────────────────────────────────────────────────────────────
  static String get loginSubtitle =>
      _t('Pantau kalori Anda. Pantau hidup Anda.', 'Track your calories. Transform your life.');
  static String get enterEmail => _t('Masukkan Email Anda', 'Enter your email');
  static String get enterPassword => _t('Masukkan Kata Sandi', 'Enter password');
  static String get forgotPassword => _t('Lupa Password?', 'Forgot Password?');
  static String get login => _t('Masuk', 'Login');
  static String get loginFailed => _t('Login Gagal', 'Login Failed');
  static String get signInWithGoogle => _t('Masuk dengan Google', 'Sign in with Google');
  static String get dontHaveAccount => _t('Belum punya akun? ', "Don't have an account? ");
  static String get signUp => _t('Daftar', 'Sign Up');
  static String get comingSoon => _t('Segera hadir 🚀', 'Coming soon 🚀');
  static String get fillAllFields => _t('Harap isi semua field', 'Please fill in all fields');

  // ─── Sign Up ─────────────────────────────────────────────────────────────
  static String get createNewAccount => _t('Buat Akun Baru', 'Create New Account');
  static String get fullName => _t('NAMA LENGKAP', 'FULL NAME');
  static String get fullNameHint => _t('Masukkan Nama Anda', 'Enter your name');
  static String get emailLabel => _t('EMAIL', 'EMAIL');
  static String get passwordLabel => _t('KATA SANDI (6 KARAKTER)', 'PASSWORD (6 CHARACTERS)');
  static String get passwordHint => _t('Masukkan kata sandi Anda', 'Enter your password');
  static String get allFieldsRequired => _t('Semua field harus diisi', 'All fields are required');
  static String get onlyGmail => _t('Hanya akun @gmail.com yang diperbolehkan', 'Only @gmail.com accounts are allowed');
  static String get passwordMinLength => _t('Password minimal 6 karakter', 'Password must be at least 6 characters');
  static String get alreadyHaveAccount => _t('Sudah punya akun? Masuk', 'Already have an account? Sign in');
  static String get accountCreated => _t('Akun berhasil dibuat! Cek email Anda untuk konfirmasi.', 'Account created! Check your email for confirmation.');

  // ─── Forgot / Reset Password ─────────────────────────────────────────────
  static String get resetPassword => _t('Reset Password', 'Reset Password');
  static String get resetPasswordDesc =>
      _t('Masukkan email Anda. Kami akan kirim link reset password.',
         'Enter your email. We will send a reset password link.');
  static String get send => _t('Kirim', 'Send');
  static String get checkYourEmail => _t('Cek Email Anda!', 'Check Your Email!');
  static String get clickVerificationLink =>
      _t('Klik link verifikasi yang telah kami kirimkan ke email anda',
         'Click the verification link we sent to your email');
  static String get didntReceiveEmail => _t('Tidak menerima email? ', "Didn't receive the email? ");
  static String get resend => _t('Kirim Ulang', 'Resend');
  static String get emailResent => _t('Email verifikasi telah dikirim ulang', 'Verification email resent');
  static String get createNewPassword => _t('Buat Password Baru', 'Create New Password');
  static String get newPassword => _t('Password Baru', 'New Password');
  static String get enterNewPassword => _t('Masukkan password baru', 'Enter new password');
  static String get confirmPassword => _t('Konfirmasi Password', 'Confirm Password');
  static String get repeatNewPassword => _t('Ulangi password baru', 'Repeat new password');
  static String get savePassword => _t('Simpan Password', 'Save Password');
  static String get passwordUpdated =>
      _t('Password berhasil diperbarui. Silakan login.', 'Password updated successfully. Please login.');
  static String get passwordsMismatch => _t('Password dan konfirmasi tidak cocok', 'Passwords do not match');

  // ─── Auth error messages ─────────────────────────────────────────────────
  static String get wrongCredentials => _t('Email atau password salah', 'Wrong email or password');
  static String get confirmEmailFirst =>
      _t('Cek email Anda untuk konfirmasi akun terlebih dahulu', 'Check your email to confirm your account first');
  static String get emailAlreadyRegistered => _t('Email sudah terdaftar, silakan login', 'Email already registered, please login');
  static String get invalidEmail => _t('Format email tidak valid', 'Invalid email format');
  static String get tooManyAttempts => _t('Terlalu banyak percobaan. Tunggu sebentar.', 'Too many attempts. Please wait.');
  static String get authError => _t('Terjadi kesalahan autentikasi', 'Authentication error');
  static String get generalError => _t('Terjadi kesalahan. Silakan coba lagi.', 'An error occurred. Please try again.');
  static String get googleLoginFailed => _t('Login Google gagal', 'Google login failed');
  static String get failedToUpdate => _t('Gagal memperbarui password', 'Failed to update password');

  // ─── Bottom Navigation ───────────────────────────────────────────────────
  static String get navCalorie => _t('Kalori', 'Calories');
  static String get navHistory => _t('Riwayat', 'History');
  static String get navCommunity => _t('Komunitas', 'Community');
  static String get navProfile => _t('Profil', 'Profile');

  // ─── Home Screen ─────────────────────────────────────────────────────────
  static String get dailyCalorieTracking => _t('Tracking Kalori Harian', 'Daily Calorie Tracking');
  static String get details => _t('Rincian', 'Details');
  static String get dailyCalorieTarget => _t('Target Kalori Harian', 'Daily Calorie Target');
  static String get breakfast => _t('Makan Pagi', 'Breakfast');
  static String get lunch => _t('Makan Siang', 'Lunch');
  static String get dinner => _t('Makan Malam', 'Dinner');
  static String get snack => _t('Cemilan', 'Snack');
  static String get cal => _t('KAL', 'CAL');
  static String get kcal => _t('kkal', 'kcal');
  static String get kCal => _t('kCal', 'kCal');
  static String percentOfTarget(int percent) =>
      _t('$percent% dari target', '$percent% of target');
  static String get helloJourneyStarts =>
      _t('Halo! Perjalanan sehatmu baru dimulai.', 'Hello! Your health journey just started.');
  static String get completeProfileDesc =>
      _t('Lengkapi data profilmu sekarang untuk mendapatkan target nutrisi yang presisi dan personal.',
         'Complete your profile now to get precise and personalized nutrition targets.');
  static String get completeProfileNow => _t('Lengkapi Profil Sekarang', 'Complete Profile Now');

  // ─── Tracking Kalori Screen ──────────────────────────────────────────────
  static String get totalCalories => _t('Total Kalori', 'Total Calories');
  static String get remaining => _t('Sisa', 'Remaining');
  static String get macronutrients => _t('Makronutrien', 'Macronutrients');
  static String get carbohydrates => _t('Karbohidrat', 'Carbohydrates');
  static String get protein => _t('Protein', 'Protein');
  static String get fat => _t('Lemak', 'Fat');
  static String get historyPerMealTime => _t('Riwayat per Waktu Makan', 'History per Meal Time');
  static String get noRecordYet => _t('Belum ada catatan', 'No records yet');

  // ─── History Screen ──────────────────────────────────────────────────────
  static String get nutritionHistory => _t('History Nutrisi', 'Nutrition History');
  static String get targetCalorie => _t('Target Kalori', 'Calorie Target');
  static String get dailyCalorie => _t('Kalori Harian', 'Daily Calories');
  static String get noFoodRecordsToday =>
      _t('Belum ada catatan makanan untuk hari ini', 'No food records for today');

  // ─── Add Meal Screen ─────────────────────────────────────────────────────
  static String addMealTitle(String mealType) => _t('Tambah $mealType', 'Add $mealType');
  static String get searchFood => _t('Cari Makanan atau Minuman', 'Search food or drink');
  static String get noFoodAdded => _t('Belum ada makanan yang ditambahkan', 'No food added yet');
  static String get noResultsFound => _t('Tidak ada hasil ditemukan', 'No results found');
  static String get deleteFoodTitle => _t('Hapus Makanan', 'Delete Food');
  static String get deleteFoodConfirm =>
      _t('Apakah Anda yakin ingin menghapus makanan ini dari riwayat?',
         'Are you sure you want to remove this food from history?');

  // ─── Tutorial ────────────────────────────────────────────────────────────
  static String get tutorialTitle => _t('Panduan Menambah Makanan', 'Food Adding Guide');
  static String get tutSearchTitle => _t('Cari Makanan', 'Search Food');
  static String get tutSearchDesc =>
      _t(' : Ketik menu makanan atau minuman anda.', ' : Type your food or drink menu.');
  static String get tutQuickAddTitle => _t('Tambah cepat', 'Quick Add');
  static String get tutQuickAddDesc =>
      _t(' : Centang kotak checklist di kanan.', ' : Check the checkbox on the right.');
  static String get tutQuickAddSub =>
      _t('(Menggunakan porsi template standar, tidak mengedit)',
         '(Uses standard template serving, no editing)');
  static String get tutManualTitle => _t('Atur Manual', 'Manual Setup');
  static String get tutManualDesc =>
      _t(' : Klik area tengah kotak makanan.', ' : Click the center area of the food box.');
  static String get tutManualSub =>
      _t('(Sesuaikan takaran porsi (gram/buah) sebelum simpan)',
         '(Adjust serving size (gram/piece) before saving)');
  static String get tutSaveTitle => _t('Simpan', 'Save');
  static String get tutSaveDesc =>
      _t(' : Ketuk tombol ceklish disebelah pojok kanan bawah untuk simpan.\\n(Untuk Mencatat Kalori Anda)',
         ' : Tap the check button at the bottom right corner to save.\\n(To Record Your Calories)');

  // ─── Food Detail Screen ──────────────────────────────────────────────────
  static String get nutritionInfo => _t('Informasi Gizi', 'Nutrition Info');
  static String get size => _t('Ukuran', 'Size');
  static String get calories => _t('Kalori', 'Calories');
  static String get totalFat => _t('Lemak Total', 'Total Fat');
  static String get carbs => _t('Karbo', 'Carbs');
  static String get gram => _t('Gram(g)', 'Gram(g)');
  static String get piece => _t('Buah', 'Piece');
  static String get serving => _t('Porsi', 'Serving');
  static String get failedToSaveTitle => _t('Gagal menyimpan', 'Failed to save');

  // ─── Profile Screen ──────────────────────────────────────────────────────
  static String get generalSettings => _t('Pengaturan Umum', 'General Settings');
  static String get editProfile => _t('Edit Profil', 'Edit Profile');
  static String get preferences => _t('Preferensi', 'Preferences');
  static String get notification => _t('Notifikasi', 'Notifications');
  static String get language => _t('Bahasa', 'Language');
  static String get logout => _t('Keluar', 'Log Out');
  static String get height => _t('Tinggi', 'Height');
  static String get weight => _t('Berat', 'Weight');
  static String get age => _t('Usia', 'Age');
  static String get years => _t('Tahun', 'Years');
  static String get gender => _t('Jenis Kelamin', 'Gender');
  static String get target => _t('Target', 'Target');
  static String get notifEnabled =>
      _t('Notifikasi pengingat makan diaktifkan', 'Meal reminder notifications enabled');
  static String get notifDenied =>
      _t('Izin notifikasi ditolak. Silakan aktifkan di pengaturan sistem.',
         'Notification permission denied. Please enable in system settings.');
  static String get notifDisabled =>
      _t('Notifikasi pengingat makan dinonaktifkan', 'Meal reminder notifications disabled');

  // ─── Edit Profile Screen ─────────────────────────────────────────────────
  static String get bodyComposition => _t('Komposisi Tubuh', 'Body Composition');
  static String get heightCm => _t('TINGGI (CM)', 'HEIGHT (CM)');
  static String get weightKg => _t('BERAT (KG)', 'WEIGHT (KG)');
  static String get birthDate => _t('TANGGAL LAHIR', 'BIRTH DATE');
  static String get selectBirthDate => _t('Pilih tanggal lahir', 'Select birth date');
  static String get targetWeight => _t('Target Berat Badan', 'Target Weight');
  static String get activity => _t('Aktivitas', 'Activity');
  static String get selectOneActivity => _t('pilih satu aktivitas', 'select one activity');
  static String get lightActivity => _t('Aktivitas Ringan', 'Light Activity');
  static String get lightActivitySub => _t('Olahraga 1-3 kali seminggu', 'Exercise 1-3 times a week');
  static String get moderateActivity => _t('Aktivitas Sedang', 'Moderate Activity');
  static String get moderateActivitySub => _t('Olahraga 3-5 kali seminggu', 'Exercise 3-5 times a week');
  static String get highActivity => _t('Aktivitas Tinggi', 'High Activity');
  static String get highActivitySub => _t('Olahraga 6-7 kali seminggu', 'Exercise 6-7 times a week');
  static String get mainGoal => _t('Tujuan Utama', 'Main Goal');
  static String get estimatedCalorieTarget => _t('Estimasi Target Kalori Harian', 'Estimated Daily Calorie Target');
  static String get saveChanges => _t('Simpan Perubahan', 'Save Changes');
  static String get savedSuccessfully => _t('Berhasil Disimpan', 'Saved Successfully');
  static String get profileUpdated =>
      _t('Perubahan profil Anda telah berhasil diperbarui.', 'Your profile changes have been updated successfully.');
  static String get fillFieldsCorrectly => _t('Isi semua kolom dengan benar', 'Fill in all fields correctly');
  static String get openGallery => _t('Buka Galeri', 'Open Gallery');
  static String get openCamera => _t('Buka Kamera', 'Open Camera');
  static String get failedToPickImage => _t('Gagal memilih gambar', 'Failed to pick image');
  static String get male => _t('Laki-Laki', 'Male');
  static String get female => _t('Perempuan', 'Female');
  static String get cutting => _t('Cutting', 'Cutting');
  static String get maintain => _t('Maintain', 'Maintain');
  static String get bulking => _t('Bulking', 'Bulking');
  static String get loseFat => _t('Turunkan Lemak', 'Lose Fat');
  static String get stayFit => _t('Tetap Bugar', 'Stay Fit');
  static String get gainMuscle => _t('Tambah Otot', 'Gain Muscle');

  // ─── Body Data & Goals Screen ────────────────────────────────────────────
  static String get bodyDataGoals => _t('Data Tubuh & Target', 'Body Data & Goals');
  static String get personalInfo => _t('Informasi Personal', 'Personal Information');
  static String get heightBodyCm => _t('Tinggi Badan (cm)', 'Height (cm)');
  static String get birthDateLabel => _t('Tanggal Lahir', 'Birth Date');
  static String get selectDate => _t('Pilih tanggal', 'Select date');
  static String get weightBodyKg => _t('Berat Badan (kg)', 'Weight (kg)');
  static String get genderLabel => _t('Jenis Kelamin', 'Gender');
  static String get dailyActivity => _t('Aktivitas Harian', 'Daily Activity');
  static String get lightlyActive => _t('Aktivitas Ringan', 'Lightly Active');
  static String get lightlyActiveSub => _t('1-3 hari olahraga/minggu', '1-3 days exercise/week');
  static String get moderatelyActive => _t('Aktivitas Sedang', 'Moderately Active');
  static String get moderatelyActiveSub => _t('3-5 hari olahraga/minggu', '3-5 days exercise/week');
  static String get highlyActive => _t('Aktivitas Tinggi', 'Highly Active');
  static String get highlyActiveSub => _t('6-7 hari olahraga intensif', '6-7 days intense exercise');
  static String get mainTarget => _t('Target Utama', 'Main Target');
  static String get estimatedTarget => _t('Estimasi Target Kalori', 'Estimated Calorie Target');
  static String get estimatedDailyTarget => _t('Estimasi Target Kalori Harian', 'Estimated Daily Calorie Target');
  static String get saveProfile => _t('Simpan Profil', 'Save Profile');
  static String get fillAllFieldsFirst => _t('Isi semua field terlebih dahulu', 'Fill all fields first');

  // ─── Change Goal Screen ──────────────────────────────────────────────────
  static String get changeTarget => _t('Ubah Target', 'Change Target');
  static String get whatIsYourFocus => _t('Apa fokus kamu?', "What's your focus?");
  static String get chooseFocusDesc =>
      _t('pilih target utama untuk perjalanan kebugaranmu.', 'choose the main target for your fitness journey.');
  static String get confirmChanges => _t('Konfirmasi Perubahan', 'Confirm Changes');

  // ─── Community Screen ────────────────────────────────────────────────────
  static String get forYou => _t('Untuk Anda', 'For You');
  static String get following => _t('Diikuti', 'Following');
  static String get follow => _t('Ikuti', 'Follow');
  static String get noFollowingPosts =>
      _t('Belum ada postingan dari akun yang Anda ikuti.',
         'No posts from accounts you follow yet.');
  static String likes(String count) => _t('Suka $count', 'Like $count');
  static String comments(String count) => _t('Komentar $count', 'Comment $count');
  static String get justNow => _t('Baru saja', 'Just now');
  static String get showMore => _t('lihat selengkapnya...', 'show more...');

  // ─── Add Post Screen ─────────────────────────────────────────────────────
  static String get addNewPost => _t('Tambah Postingan Baru', 'Add New Post');
  static String get addPhotoOrImage => _t('Tambahkan Foto atau Gambar', 'Add Photo or Image');
  static String get description => _t('Deskripsi', 'Description');
  static String get writeDescription => _t('Tulis deskripsi...', 'Write a description...');
  static String get upload => _t('Unggah', 'Upload');
  static String get addPhotoOrDescFirst =>
      _t('Tambahkan foto atau deskripsi terlebih dahulu', 'Add a photo or description first');
  static String get uploadFailed =>
      _t('Gagal mengunggah postingan', 'Failed to upload post');

  // ─── OTP Verification ──────────────────────────────────────────────────
  static String get otpTitle =>
      _t('Verifikasi Email', 'Email Verification');
  static String otpSubtitle(String email) =>
      _t('Kami telah mengirim kode 6 digit ke\n$email', 'We sent a 6-digit code to\n$email');
  static String get verify => _t('Verifikasi', 'Verify');
  static String get otpInvalid =>
      _t('Kode OTP salah, silakan coba lagi', 'Invalid OTP code, please try again');
  static String get otpExpired =>
      _t('Kode OTP sudah kedaluwarsa, kirim ulang', 'OTP code expired, please resend');
  static String get otpVerificationFailed =>
      _t('Verifikasi gagal, silakan coba lagi', 'Verification failed, please try again');
  static String get otpResent =>
      _t('Kode OTP telah dikirim ulang', 'OTP code has been resent');
  static String resendIn(int seconds) =>
      _t('Kirim ulang dalam $seconds detik', 'Resend in $seconds seconds');
  static String get resendOtp => _t('Kirim Ulang Kode', 'Resend Code');

  // ─── Notification Modal ──────────────────────────────────────────────────
  static String get inbox => _t('Kotak Masuk', 'Inbox');
  static String get inboxSubtitle =>
      _t('Tetap teratur dengan pengingat makan harian Anda.',
         'Stay organized with your daily meal reminders.');
  static String get breakfastReminder => _t('Pengingat Makan Pagi', 'Breakfast Reminder');
  static String get lunchReminder => _t('Pengingat Makan Siang', 'Lunch Reminder');
  static String get dinnerReminder => _t('Pengingat Makan Malam', 'Dinner Reminder');
  static String get dinnerDefault =>
      _t('Tutup harimu dengan makan malam yang ringan', 'End your day with a light dinner');
  static String get lunchDefault =>
      _t('Isi energi anda dengan makan siang bernutrisi', 'Refuel with a nutritious lunch');
  static String get breakfastDefault =>
      _t('Jangan lupa catat sarapan sehatmu hari ini!', "Don't forget to log your healthy breakfast today!");
  static String scheduledMenu(String menu) =>
      _t('Menu yang dijadwalkan: $menu', 'Scheduled menu: $menu');

  // ─── Month names ─────────────────────────────────────────────────────────
  static List<String> get monthNames => isId
      ? ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
         'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember']
      : ['January', 'February', 'March', 'April', 'May', 'June',
         'July', 'August', 'September', 'October', 'November', 'December'];

  static List<String> get monthNamesShort => isId
      ? ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des']
      : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  // ─── Calendar / Date Picker ──────────────────────────────────────────────
  static String get selectYear => _t('PILIH TAHUN', 'SELECT YEAR');
  static String get selectMonth => _t('PILIH BULAN', 'SELECT MONTH');
  static String get selectDay => _t('PILIH HARI', 'SELECT DAY');
  static List<String> get dayLabels => isId
      ? ['MIN', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB']
      : ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  // ─── Language picker ─────────────────────────────────────────────────────
  static String get chooseLanguage => _t('Pilih Bahasa', 'Choose Language');
  static String get indonesian => _t('Bahasa Indonesia', 'Indonesian');
  static String get english => _t('Bahasa Inggris', 'English');
  static String get imagePreview => _t('Preview Gambar', 'Image Preview');
  static String get usePhoto => _t('Gunakan Foto', 'Use Photo');

  // ─── Help Screen ──────────────────────────────────────────────────────────
  static String get helpTitle => _t('Bantuan', 'Help');
  static String get aboutNutrify => _t('Tentang Nutrify', 'About Nutrify');
  static String get aboutNutrifyDesc =>
      _t('Nutrify adalah aplikasi pencatatan kalori harian yang membantu Anda melacak asupan makanan dan mencapai target nutrisi pribadi, baik untuk cutting, maintenance, maupun bulking.',
         'Nutrify is a daily calorie tracking app that helps you monitor food intake and achieve personal nutrition goals, whether for cutting, maintenance, or bulking.');
  static String get howToTrack => _t('Cara Melacak Kalori', 'How to Track Calories');
  static String get stepSearchTitle => _t('Cari Makanan', 'Search Food');
  static String get stepSearchDesc =>
      _t('Ketik nama makanan di kolom pencarian pada halaman Tambah Makanan.', 'Type the food name in the search field on the Add Meal page.');
  static String get stepSelectTitle => _t('Pilih & Atur Porsi', 'Select & Set Portion');
  static String get stepSelectDesc =>
      _t('Pilih makanan dari hasil pencarian, lalu atur jumlah porsi sesuai yang Anda konsumsi.', 'Select a food from search results, then adjust the serving size to match what you consumed.');
  static String get stepSaveTitle => _t('Simpan Catatan', 'Save Record');
  static String get stepSaveDesc =>
      _t('Tekan tombol simpan untuk mencatat kalori ke riwayat harian Anda.', 'Tap the save button to log the calories to your daily history.');
  static String get howToSetGoals => _t('Cara Mengatur Target', 'How to Set Goals');
  static String get goalGuideDesc =>
      _t('Buka halaman Profil → Edit Profil, lalu pilih target yang sesuai:', 'Go to Profile → Edit Profile, then choose your target:');
  static String get cuttingDesc => _t('Defisit 500 kkal/hari untuk menurunkan berat badan', '500 kcal/day deficit to lose weight');
  static String get maintainDesc => _t('Pertahankan kalori harian sesuai kebutuhan tubuh', 'Maintain daily calories according to body needs');
  static String get bulkingDesc => _t('Surplus 500 kkal/hari untuk menambah massa otot', '500 kcal/day surplus to gain muscle mass');
  static String get faq => _t('Pertanyaan Umum', 'FAQ');
  static String get faqQ1 => _t('Bagaimana cara mengubah target kalori?', 'How to change calorie target?');
  static String get faqA1 => _t('Buka Profil → Edit Profil → pilih tujuan (Cutting/Maintenance/Bulking). Target kalori akan dihitung otomatis.', 'Go to Profile → Edit Profile → select goal (Cutting/Maintenance/Bulking). Calorie target is calculated automatically.');
  static String get faqQ2 => _t('Apakah data makanan akurat?', 'Is the food data accurate?');
  static String get faqA2 => _t('Data nutrisi bersumber dari dataset resmi BPOM Indonesia dengan 1.800+ item makanan lokal.', 'Nutrition data is sourced from the official Indonesian BPOM dataset with 1,800+ local food items.');
  static String get faqQ3 => _t('Bagaimana cara mengubah bahasa?', 'How to change the language?');
  static String get faqA3 => _t('Buka Profil → Bahasa → pilih Bahasa Indonesia atau English.', 'Go to Profile → Language → select Indonesian or English.');
  static String get faqQ4 => _t('Apakah bisa menggunakan tanpa login?', 'Can I use it without logging in?');
  static String get faqA4 => _t('Tidak, Anda perlu membuat akun agar data kalori tersimpan dan bisa diakses di perangkat mana pun.', 'No, you need to create an account so calorie data is saved and accessible from any device.');
  static String get faqQ5 => _t('Bagaimana formula perhitungan kalori?', 'How is the calorie calculation formula?');
  static String get faqA5 => _t('Nutrify menggunakan formula Mifflin-St Jeor untuk menghitung BMR, dikalikan dengan faktor aktivitas (TDEE), lalu disesuaikan dengan target Anda.', 'Nutrify uses the Mifflin-St Jeor formula to calculate BMR, multiplied by activity factor (TDEE), then adjusted to your target.');
}
