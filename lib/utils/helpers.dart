import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart' as date_local;

/// ============================================================
/// INISIALISASI LOCALE
/// ============================================================

/// Panggil sekali di main() sebelum app jalan
Future<void> initializeLocale() async {
  await date_local.initializeDateFormatting('id_ID', null);
}

/// ============================================================
/// FORMAT WAKTU
/// ============================================================

/// Format DateTime ke "HH:mm" (24 jam)
/// Contoh: 04:35, 12:05, 18:22
String formatTime(DateTime time) {
  return DateFormat('HH:mm').format(time);
}

/// Format DateTime ke "hh:mm a" (12 jam)
/// Contoh: 04:35 AM, 12:05 PM
String formatTime12(DateTime time) {
  return DateFormat('hh:mm a').format(time);
}

/// ============================================================
/// FORMAT TANGGAL
/// ============================================================

/// Format tanggal lengkap Indonesia: "Senin, 5 Mei 2025"
String formatDateFull(DateTime date) {
  return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
}

/// Format tanggal singkat: "5 Mei 2025"
String formatDateShort(DateTime date) {
  return DateFormat('d MMMM yyyy', 'id_ID').format(date);
}

/// Format tanggal angka: "05/05/2025"
String formatDateNumeric(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

/// ============================================================
/// COUNTDOWN HELPERS
/// ============================================================

/// Konversi Duration ke format "HH : MM : SS"
/// Contoh: Duration(hours: 2, minutes: 30, seconds: 15) → "02 : 30 : 15"
String formatCountdown(Duration duration) {
  if (duration.isNegative) return '00 : 00 : 00';

  final hours = duration.inHours.toString().padLeft(2, '0');
  final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');

  return '$hours : $minutes : $seconds';
}

/// Konversi Duration ke format pendek tanpa detik: "2j 30m"
String formatCountdownShort(Duration duration) {
  if (duration.isNegative) return '0m';

  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;

  if (hours > 0) {
    return '${hours}j ${minutes}m';
  }
  return '${minutes}m';
}

/// ============================================================
/// VALIDASI
/// ============================================================

/// Validasi apakah string bisa jadi latitude (-90 s/d 90)
bool isValidLatitude(String value) {
  final lat = double.tryParse(value);
  if (lat == null) return false;
  return lat >= -90 && lat <= 90;
}

/// Validasi apakah string bisa jadi longitude (-180 s/d 180)
bool isValidLongitude(String value) {
  final lng = double.tryParse(value);
  if (lng == null) return false;
  return lng >= -180 && lng <= 180;
}

/// ============================================================
/// STRING HELPERS
/// ============================================================

/// Capitalize huruf pertama
/// Contoh: "subuh" → "Subuh"
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Greeting berdasarkan waktu
/// Pagi / Siang / Sore / Malam
String getGreeting({DateTime? now}) {
  final hour = (now ?? DateTime.now()).hour;

  if (hour < 10) return 'Selamat Pagi';
  if (hour < 15) return 'Selamat Siang';
  if (hour < 18) return 'Selamat Sore';
  return 'Selamat Malam';
}
