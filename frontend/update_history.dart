import 'dart:io';

void main() {
  final file = File('lib/screens/history_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll("'Belum ada catatan'", "AppStrings.noRecordYet");
  
  file.writeAsStringSync(content);
  print('Updated history_screen.dart');
}
