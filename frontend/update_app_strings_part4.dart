import 'dart:io';

void main() {
  final file = File('lib/utils/locale/app_strings.dart');
  var content = file.readAsStringSync();
  
  final additions = """
  // ─── Profile Extensions ────────────────────────────────────────────────
  static String get editPost => _t('Edit Postingan', 'Edit Post');
  static String get postEditedSuccessfully => _t('Postingan berhasil diedit', 'Post edited successfully');
  static String get createPost => _t('Buat Postingan', 'Create Post');
  static String get privateLabel => _t('Privat', 'Private');
  static String get publicLabel => _t('Publik', 'Public');
""";

  final lastIndex = content.lastIndexOf('}');
  if (lastIndex != -1) {
    final before = content.substring(0, lastIndex);
    final after = content.substring(lastIndex);
    final newContent = "$before$additions\n$after";
    file.writeAsStringSync(newContent);
    print('Updated app_strings.dart correctly');
  } else {
    print('Error: Could not find last }');
  }
}
