import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_time_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Inisialisasi pengaturan notifikasi untuk Android dan iOS
  static Future<void> init() async {
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
    // Android
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
        
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

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
    // 1. Batalkan semua notifikasi lama supaya tidak dobel
    await cancelAllNotifications();

    final now = DateTime.now();
    int idCounter = 0; // ID unik untuk setiap notifikasi

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
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_time_channel', // ID channel
      'Pengingat Waktu Sholat', // Nama channel
      channelDescription: 'Notifikasi saat waktu sholat tiba',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      // Jika Anda punya custom sound adzan, bisa di set di sini nanti
      // sound: RawResourceAndroidNotificationSound('adzan_sound'),
    );

    // Detail untuk iOS
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      // sound: 'adzan_sound.wav',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Jadwalkan dengan format waktu spesifik zona waktu lokal
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
  }

  /// Membatalkan semua notifikasi
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
