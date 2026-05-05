import 'dart:io';

void main() {
  final file = File('lib/utils/locale/app_strings.dart');
  var content = file.readAsStringSync();
  
  final additions = """
  // ─── Chat Detail & Comment Detail ────────────────────────────────────────
  static String get failedToSendMsg => _t('Gagal mengirim pesan', 'Failed to send message');
  static String get camera => _t('Kamera', 'Camera');
  static String get gallery => _t('Galeri', 'Gallery');
  static String repliesCount(int count) => _t('Balasan (\$count)', 'Replies (\$count)');
  static String get noRepliesYet => _t('Belum ada balasan', 'No replies yet');
  static String replyToUser(String name) => _t('Balas @\$name...', 'Reply to @\$name...');
  static String get writeReply => _t('Tulis balasan...', 'Write a reply...');
""";

  if (!content.contains('failedToSendMsg')) {
    content = content.replaceFirst('}', additions + '\n}');
    file.writeAsStringSync(content);
    print('Added Chat Detail & Comment Detail to AppStrings');
  }
}
