import 'package:adhan/adhan.dart';
import '../models/prayer_time_model.dart';
import '../utils/constants.dart';

class PrayerTimeService {
  /// Menghitung jadwal sholat berdasarkan koordinat, tanggal, dan metode
  static PrayerTimeModel getPrayerTimes({
    required double latitude,
    required double longitude,
    required String cityName,
    required DateTime date,
    required String methodKey,
    required String madhabKey,
  }) {
    // 1. Setup Koordinat
    final coordinates = Coordinates(latitude, longitude);
    
    // 2. Setup Tanggal
    final dateComponents = DateComponents.from(date);
    
    // 3. Setup Parameter Perhitungan
    final calculationMethod = CalculationMethodHelper.getMethod(methodKey);
    final params = calculationMethod.getParameters();
    
    // 4. Setup Madhab (mempengaruhi waktu Ashar)
    params.madhab = MadhabHelper.getMadhab(madhabKey);
    
    // Hitung waktu sholat dengan library adhan
    final prayerTimes = PrayerTimes(
      coordinates, 
      dateComponents, 
      params,
    );
    
    return PrayerTimeModel(
      prayerTimes: prayerTimes,
      cityName: cityName,
      date: date,
    );
  }
}
