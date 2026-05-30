import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:alarm/alarm.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_time_model.dart';
import '../utils/constants.dart';
import 'preferences_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi pengaturan notifikasi untuk Android dan iOS
  static Future<void> init() async {
    if (kIsWeb) return; // Notifikasi lokal tidak disupport di Web secara native

    // 1. Inisialisasi timezone (wajib untuk zonedSchedule)
    tz_data.initializeTimeZones();

    // 2. Setting untuk Android
    // '@mipmap/ic_launcher' menggunakan icon aplikasi bawaan sebagai icon notifikasi
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Setting untuk iOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // 4. Gabungkan setting platform
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // 5. Inisialisasi plugin
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle aksi jika user tap notifikasi (misal: navigasi ke screen tertentu)
      },
    );
  }

  /// Meminta izin notifikasi (terutama untuk Android 13+)
  static Future<void> requestPermissions() async {
    if (kIsWeb) return; // Skip untuk Web

    // Android 13+ Notifications
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    // Android 12+ Exact Alarms
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    // Minta izin System Alert Window (Muncul di atas aplikasi lain)
    if (!await Permission.systemAlertWindow.isGranted) {
      await Permission.systemAlertWindow.request();
    }

    // Minta izin abaikan optimasi baterai (agar tidak dimatikan paksa)
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    // iOS
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  /// Menjadwalkan semua notifikasi waktu sholat untuk hari ini
  static Future<void> schedulePrayerNotifications(PrayerTimeModel model) async {
    if (kIsWeb) return; // Skip untuk Web

    // 1. Batalkan semua notifikasi visual lama
    await _notificationsPlugin.cancelAll();
    
    // 1b. Batalkan alarm terjadwal yang BELUM berbunyi (jangan stop yang sedang ringing)
    final scheduledAlarms = await Alarm.getAlarms();
    for (final alarm in scheduledAlarms) {
      if (!await Alarm.isRinging(alarm.id)) {
        await Alarm.stop(alarm.id);
      }
    }

    final now = DateTime.now();
    int idCounter = 1; // ID unik untuk setiap notifikasi (alarm package tidak menerima id 0)

    // 2. Loop semua waktu sholat (Subuh, Dzuhur, dll)
    for (final type in PrayerType.values) {
      final prayerTime = model.getTimeForPrayer(type);

      // 3. Hanya jadwalkan jika waktunya belum lewat di hari ini
      if (prayerTime.isAfter(now)) {
        await _scheduleNotification(
          id: idCounter++,
          title: 'Waktu Sholat ${type.label}',
          body: 'Telah masuk waktu sholat ${type.label} untuk ${model.cityName} dan sekitarnya.',
          scheduledTime: prayerTime,
        );
      }
    }
  }

  /// Fungsi private untuk memanggil zonedSchedule
  static Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Detail untuk Android
    // PENTING: Channel ID harus baru jika sebelumnya sudah pernah terinstal
    // karena Android meng-cache settings channel (termasuk sound)
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'adzan_channel_v6', // ID channel baru (v6) untuk silent notification visual
      'Adzan Waktu Sholat',
      channelDescription: 'Menampilkan notifikasi saat waktu sholat tiba',
      importance: Importance.max,
      priority: Priority.high,
      playSound: false, // MATIKAN sound karena akan ditangani oleh package alarm
      enableVibration: false, // MATIKAN vibration karena ditangani alarm
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );

    // Detail untuk iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: 'adzan_sound.wav',
    );

    NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Jadwalkan dengan format waktu spesifik zona waktu lokal (Visual Pop-up)
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    // Jadwalkan suara dengan package Alarm (Background Audio / WakeLock)
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: scheduledTime,
      assetAudioPath: AdzanAudioHelper.getPath(PreferencesService.adzanAudio),
      loopAudio: false,
      vibrate: true,
      volume: 1.0,
      fadeDuration: 0.0,
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Matikan',
      ),
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }

  /// Membatalkan semua notifikasi dan alarm (termasuk yang sedang berbunyi)
  static Future<void> cancelAllNotifications() async {
    if (kIsWeb) return; // Skip untuk Web
    await _notificationsPlugin.cancelAll();
    
    // Stop semua alarm yang terjadwal tapi BELUM berbunyi
    final scheduledAlarms = await Alarm.getAlarms();
    for (final alarm in scheduledAlarms) {
      if (!await Alarm.isRinging(alarm.id)) {
        await Alarm.stop(alarm.id);
      }
    }
  }

  /// Membatalkan SEMUA alarm termasuk yang sedang berbunyi (dipakai saat Master Switch OFF)
  static Future<void> cancelEverything() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
    await Alarm.stopAll();
  }
}
