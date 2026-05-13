import 'dart:io';

void main() async {
  final url = 'https://github.com/islamic-network/cdn/raw/master/audio/adhan/alafasy.mp3';
  final dir = Directory('android/app/src/main/res/raw');
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  
  final file = File('android/app/src/main/res/raw/adzan_sound.mp3');
  final request = await HttpClient().getUrl(Uri.parse(url));
  final response = await request.close();
  await response.pipe(file.openWrite());
  // ignore: avoid_print
  print('Download complete.');
}
