import 'dart:io';

void main() {
  final sourceFile = File('assets/audio/VIRAL!!! ADZAN KURDI MERDU versi USTADZ DAENG SYAWAL MUBARAK !! (320).mp3');
  final dest = File('assets/audio/adzan_kurdi.mp3');

  if (sourceFile.existsSync()) {
    sourceFile.copySync(dest.path);
    sourceFile.deleteSync();
    // ignore: avoid_print
    print('Renamed to adzan_kurdi.mp3 successfully!');
  } else {
    // ignore: avoid_print
    print('Source file not found! Maybe already renamed.');
  }
}
