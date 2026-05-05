import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  /// Wajib dipanggil di main() sebelum runApp() berjalan
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ============================================================
  // PENGATURAN TEMA
  // ============================================================
  static bool get isDarkMode =>
      _prefs.getBool(PrefKeys.darkMode) ?? AppDefaults.defaultDarkMode;

  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(PrefKeys.darkMode, value);
  }

  // ============================================================
  // PENGATURAN NOTIFIKASI
  // ============================================================
  static bool get isNotificationEnabled =>
      _prefs.getBool(PrefKeys.notificationEnabled) ??
      AppDefaults.defaultNotificationEnabled;

  static Future<void> setNotificationEnabled(bool value) async {
    await _prefs.setBool(PrefKeys.notificationEnabled, value);
  }

  // ============================================================
  // PENGATURAN METODE PERHITUNGAN SHOLAT
  // ============================================================
  static String get calculationMethod =>
      _prefs.getString(PrefKeys.calculationMethod) ??
      AppDefaults.defaultCalculationMethod;

  static Future<void> setCalculationMethod(String value) async {
    await _prefs.setString(PrefKeys.calculationMethod, value);
  }

  static String get madhab =>
      _prefs.getString(PrefKeys.madhab) ?? AppDefaults.defaultMadhab;

  static Future<void> setMadhab(String value) async {
    await _prefs.setString(PrefKeys.madhab, value);
  }

  // ============================================================
  // PENGATURAN LOKASI (GPS vs Manual)
  // ============================================================
  static bool get useManualLocation =>
      _prefs.getBool(PrefKeys.useManualLocation) ?? false;

  static Future<void> setUseManualLocation(bool value) async {
    await _prefs.setBool(PrefKeys.useManualLocation, value);
  }

  static double get manualLatitude =>
      _prefs.getDouble(PrefKeys.manualLatitude) ?? AppDefaults.defaultLatitude;

  static Future<void> setManualLatitude(double value) async {
    await _prefs.setDouble(PrefKeys.manualLatitude, value);
  }

  static double get manualLongitude =>
      _prefs.getDouble(PrefKeys.manualLongitude) ??
      AppDefaults.defaultLongitude;

  static Future<void> setManualLongitude(double value) async {
    await _prefs.setDouble(PrefKeys.manualLongitude, value);
  }

  static String get manualCityName =>
      _prefs.getString(PrefKeys.manualCityName) ?? AppDefaults.defaultCityName;

  static Future<void> setManualCityName(String value) async {
    await _prefs.setString(PrefKeys.manualCityName, value);
  }
}
