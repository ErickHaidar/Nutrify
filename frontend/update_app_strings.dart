import 'dart:io';

void main() {
  final file = File('lib/utils/locale/app_strings.dart');
  var content = file.readAsStringSync();
  
  final additions = """
  // ─── Chat & Community Extensions ─────────────────────────────────────────
  static String get post => _t('Posting', 'Post');
  static String get searchUser => _t('Cari User', 'Search User');
  static String get searchNameOrUsername => _t('Cari nama atau username...', 'Search name or username...');
  static String get typeAtLeast2Chars => _t('Ketik minimal 2 karakter untuk mencari', 'Type at least 2 characters to search');
  static String get typeAtLeast2CharsChat => _t('Ketik minimal 2 karakter', 'Type at least 2 characters');
  static String get userNotFound => _t('User tidak ditemukan', 'User not found');
  static String get followingStatus => _t('Diikuti', 'Following');
  static String get requestedStatus => _t('Diminta', 'Requested');
  static String get followStatus => _t('Ikuti', 'Follow');
  static String get commentsTitle => _t('Komentar', 'Comments');
  static String get noComments => _t('Belum ada komentar', 'No comments yet');
  static String get writeComment => _t('Tulis komentar...', 'Write a comment...');
  static String get reply => _t('Balas', 'Reply');
  static String replyingTo(String name) => _t('Membalas @\$name', 'Replying to @\$name');
  static String viewMoreReplies(int count) => _t('Lihat \$count balasan lainnya', 'View \$count more replies');
  static String viewReplies(int count) => _t('Lihat \$count balasan', 'View \$count replies');
  static String get commentDetail => _t('Detail Komentar', 'Comment Detail');

  // ─── Chat ────────────────────────────────────────────────────────────────
  static String get chat => _t('Chat', 'Chat');
  static String get all => _t('Semua', 'All');
  static String get unread => _t('Belum Dibaca', 'Unread');
  static String get markAllRead => _t('Tandai Semua Dibaca', 'Mark All Read');
  static String get searchConversation => _t('Cari percakapan...', 'Search conversation...');
  static String get noConversations => _t('Belum ada percakapan', 'No conversations yet');
  static String get startChat => _t('Mulai Obrolan', 'Start Chat');
  static String failedToStartChat(String e) => _t('Gagal memulai obrolan: \$e', 'Failed to start chat: \$e');
  static String get imageStr => _t('[Gambar]', '[Image]');
  static String get typeMessage => _t('Ketik pesan...', 'Type a message...');
  static String get now => _t('Sekarang', 'Now');
""";

  if (!content.contains('Chat & Community Extensions')) {
    content = content.replaceFirst('}', additions + '\n}');
    file.writeAsStringSync(content);
    print('Added Chat & Community Extensions to AppStrings');
  } else {
    print('Extensions already present');
  }
}
