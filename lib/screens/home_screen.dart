import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';
import 'package:alarm/alarm.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../widgets/prayer_card.dart';
import '../widgets/countdown_timer.dart';
import 'settings_screen.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrayerTimeModel? _prayerTimeModel;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Dipanggil saat countdown timer habis (waktu sholat tiba)
  void _onPrayerTimeReached() {
    // Refresh data untuk menghitung sholat berikutnya
    // (cancelAllNotifications di dalamnya sudah cerdas:
    //  hanya membatalkan alarm yang belum berbunyi,
    //  BUKAN yang sedang ringing/berkumandang)
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Sinkronisasikan tema dengan setting yang baru
      themeNotifier.value = PreferencesService.isDarkMode ? ThemeMode.dark : ThemeMode.light;

      LocationResult location;

      // 1. Dapatkan lokasi (manual atau otomatis)
      if (PreferencesService.useManualLocation) {
        location = LocationResult(
          latitude: PreferencesService.manualLatitude,
          longitude: PreferencesService.manualLongitude,
          cityName: PreferencesService.manualCityName,
        );
      } else {
        location = await LocationService.getCurrentLocation();
      }

      // 2. Hitung waktu sholat
      final model = PrayerTimeService.getPrayerTimes(
        latitude: location.latitude,
        longitude: location.longitude,
        cityName: location.cityName,
        date: DateTime.now(),
        methodKey: PreferencesService.calculationMethod,
        madhabKey: PreferencesService.madhab,
      );

      // 3. Setup notifikasi jika diaktifkan DAN aplikasi sedang aktif
      if (PreferencesService.isAppActive && PreferencesService.isNotificationEnabled) {
        await NotificationService.schedulePrayerNotifications(model);
      } else {
        await NotificationService.cancelEverything();
      }

      // 4. Update UI
      setState(() {
        _prayerTimeModel = model;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error _loadData: $e');
      setState(() {
        _errorMessage = 'Gagal memuat jadwal sholat.\nPastikan GPS atau koneksi internet Anda aktif.\n\nDetail: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer Sholat'),
        elevation: 0,
        actions: [
          // Master Switch untuk menghidupkan / mematikan fitur aplikasi
          Row(
            children: [
              Text(
                PreferencesService.isAppActive ? 'ON' : 'OFF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: PreferencesService.isAppActive ? AppColors.primaryGreen : Colors.grey,
                ),
              ),
              Switch(
                value: PreferencesService.isAppActive,
                activeThumbColor: AppColors.primaryGreen,
                onChanged: (val) async {
                  await PreferencesService.setAppActive(val);
                  _loadData();
                },
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Perbarui Lokasi GPS Terkini',
            onPressed: _loadData,
          ),
          // Tombol test suara adzan
          IconButton(
            icon: const Icon(Icons.volume_up),
            tooltip: 'Test / Stop Suara',
            onPressed: () async {
              // Hentikan dulu jika ada suara yang menyala
              await Alarm.stop(999);
              
              final testAlarmSettings = AlarmSettings(
                id: 999,
                dateTime: DateTime.now().add(const Duration(seconds: 1)),
                assetAudioPath: AdzanAudioHelper.getPath(PreferencesService.adzanAudio),
                loopAudio: false,
                vibrate: true,
                volume: 1.0,
                fadeDuration: 0.0,
                notificationSettings: const NotificationSettings(
                  title: 'Test Suara Adzan',
                  body: 'Mengetes pemutar suara',
                  stopButton: 'Stop',
                ),
              );
              await Alarm.set(alarmSettings: testAlarmSettings);
              
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Memutar... (Buka Panel Notifikasi untuk mematikan)'),
                  duration: const Duration(seconds: 5),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Pindah ke halaman setting dan tunggu jika ada perubahan
              final shouldRefresh = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
              // Jika user melakukan save di settings, load ulang data
              if (shouldRefresh == true) {
                _loadData();
              }
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // State 1: Sedang loading
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // State 2: Jika aplikasi dinonaktifkan (Master Switch OFF)
    if (!PreferencesService.isAppActive) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.power_settings_new, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi Nonaktif',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Nyalakan tombol (ON) di pojok kanan atas\nuntuk mengaktifkan alarm sholat.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // State 3: Terjadi error (misal GPS tidak nyala)
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: _loadData,
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    // State 3: Data berhasil di-load tapi kosong (jarang terjadi)
    if (_prayerTimeModel == null) {
      return const Center(child: Text('Data tidak tersedia'));
    }

    // Tentukan sholat sekarang dan berikutnya
    final nextPrayer = _prayerTimeModel!.getNextPrayer();
    final currentPrayer = _prayerTimeModel!.getCurrentPrayer();
    DateTime? nextTime;
    PrayerType? displayPrayer = nextPrayer;

    if (nextPrayer != null) {
      nextTime = _prayerTimeModel!.getTimeForPrayer(nextPrayer);
    } else {
      // Semua sholat hari ini sudah lewat → hitung Subuh besok
      displayPrayer = PrayerType.fajr;
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final tomorrowModel = PrayerTimeService.getPrayerTimes(
        latitude: _prayerTimeModel!.prayerTimes.coordinates.latitude,
        longitude: _prayerTimeModel!.prayerTimes.coordinates.longitude,
        cityName: _prayerTimeModel!.cityName,
        date: tomorrow,
        methodKey: PreferencesService.calculationMethod,
        madhabKey: PreferencesService.madhab,
      );
      nextTime = tomorrowModel.getTimeForPrayer(PrayerType.fajr);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primaryGreen,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          // Bagian Header: Lokasi dan Tanggal
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getGreeting(),
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.primaryGreen, size: 24),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _prayerTimeModel!.cityName,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _prayerTimeModel!.formattedDate,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),

          // Widget Countdown Timer
          CountdownTimer(
            targetTime: nextTime,
            targetPrayer: displayPrayer,
            onTimerComplete: _onPrayerTimeReached, // Bunyikan adzan saat waktu tiba
          ),

          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              'Jadwal Hari Ini',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // List Widget Jadwal Sholat
          ...PrayerType.values.map((type) {
            return PrayerCard(
              type: type,
              time: _prayerTimeModel!.getTimeForPrayer(type),
              isNext: type == nextPrayer,
              isCurrent: type == currentPrayer,
            );
          }),
        ],
      ),
    );
  }
}
