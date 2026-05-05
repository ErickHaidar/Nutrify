import 'dart:io';

void main() {
  final file = File('lib/utils/locale/app_strings.dart');
  var content = file.readAsStringSync();
  
  final additions = """
  // ─── Post Detail & User Profile & Profile Tabs ─────────────────────────
  static String get posts => _t('Postingan', 'Posts');
  static String get like => _t('Suka', 'Like');
  static String get liked => _t('Disukai', 'Liked');
  static String get noCommentsBeFirst => _t('Belum ada komentar. Jadilah yang pertama!', 'No comments yet. Be the first!');
  static String get deletePostPrompt => _t('Hapus Postingan?', 'Delete Post?');
  static String get deletePostWarning => _t('Postingan ini akan dihapus secara permanen.', 'This post will be permanently deleted.');
  static String get failedToDeletePost => _t('Gagal menghapus postingan', 'Failed to delete post');
  static String failedToOpenChat(String e) => _t('Gagal membuka chat: \$e', 'Failed to open chat: \$e');
  static String get followingCountLabel => _t('Mengikuti', 'Following');
  static String get followersCountLabel => _t('Pengikut', 'Followers');
  static String get sendMessage => _t('Kirim Pesan', 'Send Message');
  static String get privateAccount => _t('Akun Privat', 'Private Account');
  static String get followToSeePosts => _t('Ikuti akun ini untuk melihat postingan.', 'Follow this account to see posts.');
  static String get noPostsYet => _t('Belum ada postingan', 'No posts yet');
  static String get generalTab => _t('Umum', 'General');
  static String get socialTab => _t('Sosial', 'Social');
  static String get tiktokReplyIndicator => _t(' ‣ ', ' ‣ ');
""";

  final lastIndex = content.lastIndexOf('}');
  if (lastIndex != -1) {
    final before = content.substring(0, lastIndex);
    final after = content.substring(lastIndex);
    final newContent = before + additions + "\n" + after;
    file.writeAsStringSync(newContent);
    print('Updated app_strings.dart correctly');
  } else {
    print('Error: Could not find last }');
  }
}
