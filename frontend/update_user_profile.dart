import 'dart:io';

void main() {
  final file = File('lib/screens/user_profile_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:nutrify/utils/locale/app_strings.dart';")) {
    content = "import 'package:nutrify/utils/locale/app_strings.dart';\n$content";
  }
  
  // Replace strings
  content = content.replaceAll("'Gagal membuka chat: \$e'", "AppStrings.failedToOpenChat(e.toString())");
  content = content.replaceAll("Text('Postingan',", "Text(AppStrings.posts,");
  content = content.replaceAll("Text('Mengikuti',", "Text(AppStrings.followingCountLabel,");
  content = content.replaceAll("Text('Pengikut',", "Text(AppStrings.followersCountLabel,");
  
  content = content.replaceAll("isFollowing ? 'Diikuti' : isRequested ? 'Diminta' : 'Ikuti'", "isFollowing ? AppStrings.followingStatus : isRequested ? AppStrings.requestedStatus : AppStrings.followStatus");
  content = content.replaceAll("Text('Kirim Pesan'", "Text(AppStrings.sendMessage");
  
  content = content.replaceAll("'Akun Privat'", "AppStrings.privateAccount");
  content = content.replaceAll("'Ikuti akun ini untuk melihat postingan.'", "AppStrings.followToSeePosts");
  
  content = content.replaceAll("'Belum ada postingan'", "AppStrings.noPostsYet");
  
  file.writeAsStringSync(content);
  print('Updated user_profile_screen.dart');
}
