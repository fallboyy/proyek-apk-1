import 'dart:io';

void main() {
  final sourceFile = File('assets/audio/ADZAN KURDI MIX KASHMIR MERDU TERBARU - UST DAENG SYAWAL MUBARAK (320).mp3');
  final destAsset = File('assets/audio/adzan_sound.mp3');
  final destRaw = File('android/app/src/main/res/raw/adzan_sound.mp3');

  if (sourceFile.existsSync()) {
    // Copy to both destinations
    sourceFile.copySync(destAsset.path);
    
    // Ensure raw directory exists
    final rawDir = Directory('android/app/src/main/res/raw');
    if (!rawDir.existsSync()) {
      rawDir.createSync(recursive: true);
    }
    sourceFile.copySync(destRaw.path);
    
    // Delete original
    sourceFile.deleteSync();
    // ignore: avoid_print
    print('Audio file processed successfully!');
  } else {
    // ignore: avoid_print
    print('Source file not found!');
  }
}
