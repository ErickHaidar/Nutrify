import 'dart:io';

void main() {
  final file = File('lib/screens/chat_list_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:nutrify/utils/locale/app_strings.dart';")) {
    content = "import 'package:nutrify/utils/locale/app_strings.dart';\n$content";
  }
  
  content = content.replaceAll("'Chat'", "AppStrings.chat");
  content = content.replaceAll("'Semua'", "AppStrings.all");
  content = content.replaceAll("'Belum Dibaca'", "AppStrings.unread");
  content = content.replaceAll("'Tandai Semua Dibaca'", "AppStrings.markAllRead");
  content = content.replaceAll("'Cari percakapan...'", "AppStrings.searchConversation");
  content = content.replaceAll("'Belum ada percakapan'", "AppStrings.noConversations");
  content = content.replaceAll("'Mulai Obrolan'", "AppStrings.startChat");
  content = content.replaceAll("'Gagal memulai obrolan: \$e'", "AppStrings.failedToStartChat(e.toString())");
  content = content.replaceAll("'Cari nama atau username...'", "AppStrings.searchNameOrUsername");
  content = content.replaceAll("'Ketik minimal 2 karakter'", "AppStrings.typeAtLeast2CharsChat");
  content = content.replaceAll("'User tidak ditemukan'", "AppStrings.userNotFound");
  content = content.replaceAll("'[Gambar]'", "AppStrings.imageStr");
  content = content.replaceAll("'Sekarang'", "AppStrings.now");
  
  file.writeAsStringSync(content);
  print('Updated chat_list_screen.dart');
}
