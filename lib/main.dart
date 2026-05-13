import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';
import 'services/preferences_service.dart';
import 'services/notification_service.dart';
import 'utils/helpers.dart';
import 'utils/constants.dart';

// Notifier global agar tema bisa langsung berubah ketika disetting tanpa perlu restart
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  // Wajib dipanggil sebelum inisialisasi plugin-plugin Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Kunci orientasi aplikasi agar selalu Portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 1. Inisialisasi SharedPreferences (Pengaturan user)
  await PreferencesService.init();

  // 2. Inisialisasi Notifikasi (Android & iOS)
  await NotificationService.init();
  
  // 3. Inisialisasi Lokalisasi (Bahasa Indonesia untuk tanggal, dll)
  await initializeLocale();

  // 4. Minta izin notifikasi dari user (penting untuk Android 13+)
  await NotificationService.requestPermissions();

  // 5. Atur tema awal berdasarkan pengaturan tersimpan
  themeNotifier.value = PreferencesService.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const TimerSholatApp());
}

class TimerSholatApp extends StatelessWidget {
  const TimerSholatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          title: 'Timer Sholat',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          
          // ==========================================
          // TEMA TERANG (LIGHT MODE)
          // ==========================================
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.primaryGreen,
            scaffoldBackgroundColor: AppColors.lightBackground,
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              secondary: AppColors.teal,
            ),
            cardColor: AppColors.lightCard,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // ==========================================
          // TEMA GELAP (DARK MODE)
          // ==========================================
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.primaryGreen,
            scaffoldBackgroundColor: AppColors.darkBackground,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              secondary: AppColors.teal,
              surface: AppColors.darkSurface,
            ),
            cardColor: AppColors.darkCard,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.darkSurface,
              foregroundColor: Colors.white,
              centerTitle: true,
              elevation: 0,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Entry point halaman utama
          home: const HomeScreen(),
        );
      },
    );
  }
}
