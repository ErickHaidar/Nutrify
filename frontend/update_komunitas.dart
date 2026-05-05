import 'dart:io';

void main() {
  final file = File('lib/screens/komunitas_screen.dart');
  var content = file.readAsStringSync();
  
  // Posting
  content = content.replaceAll("'Posting'", "AppStrings.post");
  // follow status
  content = content.replaceAll("(AppStrings.isId ? 'Diminta' : 'Requested')", "AppStrings.requestedStatus");
  content = content.replaceAll("isFollowing ? 'Diikuti' : isRequested ? 'Diminta' : 'Ikuti'", "isFollowing ? AppStrings.followingStatus : isRequested ? AppStrings.requestedStatus : AppStrings.followStatus");
  content = content.replaceAll("isFollowing ? 'Diikuti' : isRequested ? 'Diminta' : 'Ikuti'", "isFollowing ? AppStrings.followingStatus : isRequested ? AppStrings.requestedStatus : AppStrings.followStatus"); // in case there's another
  // search user
  content = content.replaceAll("'Cari User'", "AppStrings.searchUser");
  content = content.replaceAll("'Cari nama atau username...'", "AppStrings.searchNameOrUsername");
  content = content.replaceAll("'Ketik minimal 2 karakter untuk mencari'", "AppStrings.typeAtLeast2Chars");
  content = content.replaceAll("'User tidak ditemukan'", "AppStrings.userNotFound");
  
  // comments
  content = content.replaceAll("'Komentar'", "AppStrings.commentsTitle");
  content = content.replaceAll("'Belum ada komentar'", "AppStrings.noComments");
  content = content.replaceAll("'Tulis komentar...'", "AppStrings.writeComment");
  content = content.replaceAll("'Balas'", "AppStrings.reply");
  
  // Membalas @\${_replyTarget!.userName}
  content = content.replaceAll("'Membalas @\${_replyTarget!.userName}'", "AppStrings.replyingTo(_replyTarget!.userName)");
  
  // Lihat balasan
  content = content.replaceAll("'Lihat \${c.repliesCount - c.replies.length} balasan lainnya'", "AppStrings.viewMoreReplies(c.repliesCount - c.replies.length)");
  content = content.replaceAll("'Lihat \${c.repliesCount} balasan'", "AppStrings.viewReplies(c.repliesCount)");

  file.writeAsStringSync(content);
  print('Updated komunitas_screen.dart');
}
