import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';

/// ============================================================
/// WARNA TEMA
/// ============================================================

class AppColors {
  // --- Dark Mode ---
  static const Color darkBackground = Color(0xFF0A1628);
  static const Color darkSurface = Color(0xFF121E36);
  static const Color darkCard = Color(0xFF182844);
  static const Color darkCardActive = Color(0xFF1B3A5C);

  // --- Light Mode ---
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardActive = Color(0xFFE8F5E9);

  // --- Accent (Hijau Islami) ---
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color emerald = Color(0xFF2ECC71);
  static const Color teal = Color(0xFF009688);
  static const Color darkEmerald = Color(0xFF00695C);

  // --- Gradient ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [emerald, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0D2137), Color(0xFF0A1628)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient countdownGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF009688)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Teks ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textDark = Color(0xFF212121);
  static const Color textDarkSecondary = Color(0xFF757575);

  // --- Lainnya ---
  static const Color gold = Color(0xFFFFD700);
  static const Color error = Color(0xFFEF5350);
}

/// ============================================================
/// DEFAULT VALUES
/// ============================================================

class AppDefaults {
  /// Default koordinat: Jakarta, Indonesia
  static const double defaultLatitude = -6.2088;
  static const double defaultLongitude = 106.8456;
  static const String defaultCityName = 'Jakarta';

  /// Default metode perhitungan: Kemenag / MUI (menggunakan method muslim_world_league
  /// karena paling mendekati metode Kemenag Indonesia)
  static const String defaultCalculationMethod = 'muslim_world_league';

  /// Default madhab
  static const String defaultMadhab = 'shafi';

  /// Notifikasi default aktif
  static const bool defaultNotificationEnabled = true;

  /// Dark mode default aktif
  static const bool defaultDarkMode = true;
}

/// ============================================================
/// MAPPING CALCULATION METHOD
/// ============================================================

class CalculationMethodHelper {
  /// Map string key → CalculationMethod dari library adhan
  static final Map<String, CalculationMethod> methods = {
    'muslim_world_league': CalculationMethod.muslim_world_league,
    'egyptian': CalculationMethod.egyptian,
    'karachi': CalculationMethod.karachi,
    'umm_al_qura': CalculationMethod.umm_al_qura,
    'dubai': CalculationMethod.dubai,
    'qatar': CalculationMethod.qatar,
    'kuwait': CalculationMethod.kuwait,
    'singapore': CalculationMethod.singapore,
    'north_america': CalculationMethod.north_america,
    'turkey': CalculationMethod.turkey,
    'tehran': CalculationMethod.tehran,
  };

  /// Label user-friendly untuk setiap metode
  static final Map<String, String> labels = {
    'muslim_world_league': 'Muslim World League (MWL)',
    'egyptian': 'Egyptian General Authority',
    'karachi': 'University of Islamic Sciences, Karachi',
    'umm_al_qura': 'Umm Al-Qura University, Makkah',
    'dubai': 'Dubai',
    'qatar': 'Qatar',
    'kuwait': 'Kuwait',
    'singapore': 'Singapore',
    'north_america': 'ISNA (North America)',
    'turkey': 'Diyanet İşleri Başkanlığı (Turkey)',
    'tehran': 'Institute of Geophysics, Tehran',
  };

  /// Ambil CalculationMethod dari key string
  static CalculationMethod getMethod(String key) {
    return methods[key] ?? CalculationMethod.muslim_world_league;
  }

  /// Ambil label dari key string
  static String getLabel(String key) {
    return labels[key] ?? 'Muslim World League (MWL)';
  }
}

/// ============================================================
/// MADHAB MAPPING
/// ============================================================

class MadhabHelper {
  static final Map<String, Madhab> values = {
    'shafi': Madhab.shafi,
    'hanafi': Madhab.hanafi,
  };

  static final Map<String, String> labels = {
    'shafi': "Syafi'i",
    'hanafi': 'Hanafi',
  };

  static Madhab getMadhab(String key) {
    return values[key] ?? Madhab.shafi;
  }

  static String getLabel(String key) {
    return labels[key] ?? "Syafi'i";
  }
}

/// ============================================================
/// SHARED PREFERENCES KEYS
/// ============================================================

class PrefKeys {
  static const String calculationMethod = 'calculation_method';
  static const String madhab = 'madhab';
  static const String notificationEnabled = 'notification_enabled';
  static const String darkMode = 'dark_mode';
  static const String manualLatitude = 'manual_latitude';
  static const String manualLongitude = 'manual_longitude';
  static const String manualCityName = 'manual_city_name';
  static const String useManualLocation = 'use_manual_location';
}
