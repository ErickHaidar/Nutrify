import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    "const Text('Edit Postingan',",
    "Text(AppStrings.editPost,"
  );
  content = content.replaceAll(
    "content: Text('Postingan berhasil diedit')),",
    "content: Text(AppStrings.postEditedSuccessfully)),"
  );
  content = content.replaceAll(
    "title: const Text('Hapus Postingan?',",
    "title: Text(AppStrings.deletePostPrompt,"
  );
  content = content.replaceAll(
    "'Postingan ini akan dihapus secara permanen.',",
    "AppStrings.deletePostWarning,"
  );
  content = content.replaceAll(
    "_buildStatItem('Postingan', _postsCount),",
    "_buildStatItem(AppStrings.posts, _postsCount),"
  );
  content = content.replaceAll(
    "const Text('Postingan',",
    "Text(AppStrings.posts,"
  );
  content = content.replaceAll(
    "Text('Belum ada postingan',",
    "Text(AppStrings.noPostsYet,"
  );
  content = content.replaceAll(
    "label: const Text('Buat Postingan',",
    "label: Text(AppStrings.createPost,"
  );
  content = content.replaceAll(
    "isPrivate ? 'Privat' : 'Publik',",
    "isPrivate ? AppStrings.privateLabel : AppStrings.publicLabel,"
  );
  
  file.writeAsStringSync(content);
  print('Fixed profile_screen.dart');
}
