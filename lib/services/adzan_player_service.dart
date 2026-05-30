import 'package:audioplayers/audioplayers.dart';

class AdzanPlayerService {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  /// Membunyikan suara adzan dari file asset
  static Future<void> playAdzan() async {
    try {
      // Hentikan jika sedang bermain
      if (_isPlaying) {
        await stopAdzan();
      }

      _isPlaying = true;

      // Set volume ke maksimum
      await _player.setVolume(1.0);

      // Putar dari asset Flutter
      await _player.play(AssetSource('audio/adzan_sound.mp3'));

      // Tandai selesai saat audio habis
      _player.onPlayerComplete.listen((_) {
        _isPlaying = false;
      });
    } catch (e) {
      _isPlaying = false;
    }
  }

  /// Menghentikan suara adzan
  static Future<void> stopAdzan() async {
    _isPlaying = false;
    await _player.stop();
  }

  /// Cek apakah adzan sedang diputar
  static bool get isPlaying => _isPlaying;

  /// Bersihkan resource
  static Future<void> dispose() async {
    await _player.dispose();
  }
}
