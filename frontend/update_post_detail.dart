import 'dart:io';

void main() {
  final file = File('lib/screens/post_detail_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:nutrify/utils/locale/app_strings.dart';")) {
    content = "import 'package:nutrify/utils/locale/app_strings.dart';\n" + content;
  }
  
  // Replace strings
  content = content.replaceAll("'Baru saja'", "AppStrings.justNow"); // from previous strings
  content = content.replaceAll("'Postingan'", "AppStrings.posts");
  content = content.replaceAll("'\${_formatCount(post.likes)} Suka'", "AppStrings.likes(_formatCount(post.likes))");
  content = content.replaceAll("'\${_formatCount(post.comments)} Komentar'", "AppStrings.comments(_formatCount(post.comments))");
  content = content.replaceAll("post.isLiked ? 'Disukai' : 'Suka'", "post.isLiked ? AppStrings.liked : AppStrings.like");
  content = content.replaceAll("'Komentar'", "AppStrings.commentsTitle");
  content = content.replaceAll("'Belum ada komentar. Jadilah yang pertama!'", "AppStrings.noCommentsBeFirst");
  content = content.replaceAll("'Lihat \${c.repliesCount - c.replies.length} balasan lainnya'", "AppStrings.viewMoreReplies(c.repliesCount - c.replies.length)");
  content = content.replaceAll("'Lihat \${c.repliesCount} balasan'", "AppStrings.viewReplies(c.repliesCount)");
  
  // tiktok format
  // Membalas $replyToName -> c.userName ‣ replyToName
  // Let's just fix the string formatting where it occurs
  // Old: headerName = 'Membalas \$replyToName';
  content = content.replaceAll("headerName = 'Membalas \$replyToName';", "headerName = '\${c.userName}' + AppStrings.tiktokReplyIndicator + '\$replyToName';");
  
  content = content.replaceAll("Text('Balas',", "Text(AppStrings.reply,");
  content = content.replaceAll("'Membalas @\${_replyTarget!.userName}'", "AppStrings.replyingTo(_replyTarget!.userName)");
  content = content.replaceAll("'Balas @\${_replyTarget!.userName}...'", "AppStrings.replyToUser(_replyTarget!.userName)");
  content = content.replaceAll("'Tulis komentar...'", "AppStrings.writeComment");
  
  content = content.replaceAll("'Hapus Postingan?'", "AppStrings.deletePostPrompt");
  content = content.replaceAll("'Postingan ini akan dihapus secara permanen.'", "AppStrings.deletePostWarning");
  content = content.replaceAll("Text('Batal',", "Text(AppStrings.cancel,");
  content = content.replaceAll("Text('Hapus',", "Text(AppStrings.delete,");
  content = content.replaceAll("'Gagal menghapus postingan'", "AppStrings.failedToDeletePost");
  
  file.writeAsStringSync(content);
  print('Updated post_detail_screen.dart');
}
