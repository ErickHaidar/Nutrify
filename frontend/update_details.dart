import 'dart:io';

void main() {
  // Chat Detail
  final chatFile = File('lib/screens/chat_detail_screen.dart');
  var chatContent = chatFile.readAsStringSync();
  
  if (!chatContent.contains("import 'package:nutrify/utils/locale/app_strings.dart';")) {
    chatContent = "import 'package:nutrify/utils/locale/app_strings.dart';\n" + chatContent;
  }
  
  chatContent = chatContent.replaceAll("'Gagal mengirim pesan'", "AppStrings.failedToSendMsg");
  chatContent = chatContent.replaceAll("'Kamera'", "AppStrings.camera");
  chatContent = chatContent.replaceAll("'Galeri'", "AppStrings.gallery");
  chatContent = chatContent.replaceAll("'Pesan...'", "AppStrings.message");
  
  chatFile.writeAsStringSync(chatContent);
  print('Updated chat_detail_screen.dart');
  
  // Comment Detail
  final commentFile = File('lib/screens/comment_detail_screen.dart');
  var commentContent = commentFile.readAsStringSync();
  
  if (!commentContent.contains("import 'package:nutrify/utils/locale/app_strings.dart';")) {
    commentContent = "import 'package:nutrify/utils/locale/app_strings.dart';\n" + commentContent;
  }
  
  commentContent = commentContent.replaceAll("'Komentar'", "AppStrings.commentsTitle");
  commentContent = commentContent.replaceAll("'Balasan (\${_replies.length})'", "AppStrings.repliesCount(_replies.length)");
  commentContent = commentContent.replaceAll("'Belum ada balasan'", "AppStrings.noRepliesYet");
  commentContent = commentContent.replaceAll("'Balas @\${_replyTarget!.userName}...'", "AppStrings.replyToUser(_replyTarget!.userName)");
  commentContent = commentContent.replaceAll("'Tulis balasan...'", "AppStrings.writeReply");
  // 'Balas' might be in a Text widget
  commentContent = commentContent.replaceAll("Text('Balas',", "Text(AppStrings.reply,");
  
  commentFile.writeAsStringSync(commentContent);
  print('Updated comment_detail_screen.dart');
}
