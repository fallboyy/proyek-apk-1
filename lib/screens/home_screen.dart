import 'package:flutter/material.dart';
import '../models/prayer_time_model.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';
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

      // 3. Setup notifikasi jika diaktifkan
      if (PreferencesService.isNotificationEnabled) {
        await NotificationService.schedulePrayerNotifications(model);
      } else {
        await NotificationService.cancelAllNotifications();
      }

      // 4. Update UI
      setState(() {
        _prayerTimeModel = model;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat jadwal sholat.\nPastikan GPS atau koneksi internet Anda aktif.';
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
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    // State 2: Terjadi error (misal GPS tidak nyala)
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

    if (nextPrayer != null) {
      nextTime = _prayerTimeModel!.getTimeForPrayer(nextPrayer);
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
            targetPrayer: nextPrayer,
            onTimerComplete: _loadData, // Panggil _loadData saat waktu habis
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
