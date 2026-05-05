import 'dart:io';

void main() {
  final file = File('lib/screens/comment_detail_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    "text: c.userName,",
    "text: isParent ? c.userName : '\${c.userName}' + AppStrings.tiktokReplyIndicator + '\${_parent.userName}',"
  );
  
  file.writeAsStringSync(content);
  print('Updated comment_detail_screen.dart for TikTok style');
}
