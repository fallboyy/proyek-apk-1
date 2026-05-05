import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

/// Enum untuk jenis waktu sholat
enum PrayerType {
  fajr,
  dhuhr,
  asr,
  maghrib,
  isha,
}

/// Extension untuk menampilkan nama sholat dalam Bahasa Indonesia
extension PrayerTypeExtension on PrayerType {
  /// Nama sholat dalam Bahasa Indonesia
  String get label {
    switch (this) {
      case PrayerType.fajr:
        return 'Subuh';
      case PrayerType.dhuhr:
        return 'Dzuhur';
      case PrayerType.asr:
        return 'Ashar';
      case PrayerType.maghrib:
        return 'Maghrib';
      case PrayerType.isha:
        return 'Isya';
    }
  }

  /// Emoji / ikon representasi waktu sholat
  String get icon {
    switch (this) {
      case PrayerType.fajr:
        return '🌅';
      case PrayerType.dhuhr:
        return '☀️';
      case PrayerType.asr:
        return '🌤️';
      case PrayerType.maghrib:
        return '🌇';
      case PrayerType.isha:
        return '🌙';
    }
  }
}

/// Model utama yang membungkus jadwal sholat harian
class PrayerTimeModel {
  /// Waktu sholat dari library adhan
  final PrayerTimes prayerTimes;

  /// Nama kota/lokasi
  final String cityName;

  /// Tanggal jadwal sholat
  final DateTime date;

  PrayerTimeModel({
    required this.prayerTimes,
    required this.cityName,
    required this.date,
  });

  /// Ambil waktu DateTime berdasarkan PrayerType
  DateTime getTimeForPrayer(PrayerType type) {
    switch (type) {
      case PrayerType.fajr:
        return prayerTimes.fajr;
      case PrayerType.dhuhr:
        return prayerTimes.dhuhr;
      case PrayerType.asr:
        return prayerTimes.asr;
      case PrayerType.maghrib:
        return prayerTimes.maghrib;
      case PrayerType.isha:
        return prayerTimes.isha;
    }
  }

  /// Ambil waktu sholat dalam format string "HH:mm"
  String getFormattedTime(PrayerType type) {
    final time = getTimeForPrayer(type);
    return DateFormat('HH:mm').format(time);
  }

  /// Tentukan sholat berikutnya berdasarkan waktu sekarang
  PrayerType? getNextPrayer({DateTime? now}) {
    final currentTime = now ?? DateTime.now();

    for (final type in PrayerType.values) {
      final prayerTime = getTimeForPrayer(type);
      if (prayerTime.isAfter(currentTime)) {
        return type;
      }
    }

    // Jika semua sholat hari ini sudah lewat, sholat berikutnya adalah Subuh (besok)
    return null;
  }

  /// Tentukan sholat yang sedang berlangsung (terakhir masuk waktu)
  PrayerType? getCurrentPrayer({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    PrayerType? current;

    for (final type in PrayerType.values) {
      final prayerTime = getTimeForPrayer(type);
      if (prayerTime.isBefore(currentTime) ||
          prayerTime.isAtSameMomentAs(currentTime)) {
        current = type;
      }
    }

    return current;
  }

  /// Hitung durasi sisa menuju sholat berikutnya
  Duration? getTimeUntilNextPrayer({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final next = getNextPrayer(now: currentTime);

    if (next != null) {
      final nextTime = getTimeForPrayer(next);
      return nextTime.difference(currentTime);
    }

    // Jika semua sholat hari ini sudah lewat, hitung ke Subuh besok
    // Ini akan di-handle di service layer dengan jadwal hari berikutnya
    return null;
  }

  /// Daftar semua waktu sholat sebagai Map
  Map<PrayerType, DateTime> get allPrayerTimes {
    return {
      for (final type in PrayerType.values) type: getTimeForPrayer(type),
    };
  }

  /// Tanggal dalam format Indonesia "Senin, 5 Mei 2025"
  String get formattedDate {
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  /// Tanggal singkat "5 Mei 2025"
  String get shortDate {
    return DateFormat('d MMMM yyyy', 'id_ID').format(date);
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('Jadwal Sholat - $cityName ($shortDate)');
    for (final type in PrayerType.values) {
      buffer.writeln('  ${type.label}: ${getFormattedTime(type)}');
    }
    return buffer.toString();
  }
}
