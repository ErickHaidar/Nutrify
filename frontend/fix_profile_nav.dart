import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst(
    "_profileImagePath =\n                    getIt<SharedPreferences>().getString('profile_image');",
    "_profileImagePath =\n                    getIt<SharedPreferences>().getString('profile_image');\n                _isLocalAvatarNew = true;"
  );
  
  file.writeAsStringSync(content);
  print('Updated nav return in profile_screen.dart');
}
