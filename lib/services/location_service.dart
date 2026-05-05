import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../utils/constants.dart';

/// Class pembantu untuk mengembalikan hasil lokasi
class LocationResult {
  final double latitude;
  final double longitude;
  final String cityName;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.cityName,
  });
}

class LocationService {
  /// Mendapatkan lokasi saat ini beserta nama kotanya
  static Future<LocationResult> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // 1. Cek apakah service GPS (Location Services) di device aktif
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Jika tidak aktif, gunakan fallback (Jakarta)
        return _getDefaultLocation();
      }

      // 2. Cek permission dari user
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Minta permission jika belum diberikan
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Jika ditolak, gunakan fallback
          return _getDefaultLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Jika ditolak permanen, gunakan fallback
        return _getDefaultLocation();
      }

      // 3. Ambil koordinat posisi saat ini (GPS)
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Ubah koordinat menjadi nama kota (Reverse Geocoding)
      String city = await getCityNameFromCoordinates(
        position.latitude,
        position.longitude,
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        cityName: city,
      );
    } catch (e) {
      // Jika terjadi error (misalnya koneksi/GPS bermasalah), gunakan fallback
      return _getDefaultLocation();
    }
  }

  /// Mendapatkan nama kota dari koordinat latitude & longitude
  static Future<String> getCityNameFromCoordinates(
      double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        
        // Prioritaskan nama kota (locality), lalu kabupaten (subAdministrativeArea)
        String? city = place.locality;
        if (city == null || city.isEmpty) {
          city = place.subAdministrativeArea;
        }
        if (city == null || city.isEmpty) {
          city = place.administrativeArea;
        }
        
        if (city != null && city.isNotEmpty) {
          // Terkadang nama kota diawali dengan kata "Kota " atau "Kabupaten ",
          // bisa dibersihkan di sini jika diperlukan, atau langsung kembalikan.
          return city;
        }
      }
      return AppDefaults.defaultCityName;
    } catch (e) {
      return AppDefaults.defaultCityName;
    }
  }

  /// Helper untuk mengembalikan lokasi default (berdasarkan constants)
  static LocationResult _getDefaultLocation() {
    return LocationResult(
      latitude: AppDefaults.defaultLatitude,
      longitude: AppDefaults.defaultLongitude,
      cityName: AppDefaults.defaultCityName,
    );
  }
}
