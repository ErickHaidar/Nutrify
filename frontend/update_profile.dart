import 'dart:io';

void main() {
  final file = File('lib/screens/profile_screen.dart');
  var content = file.readAsStringSync();
  
  if (!content.contains("import 'package:nutrify/utils/locale/app_strings.dart';")) {
    content = "import 'package:nutrify/utils/locale/app_strings.dart';\n" + content;
  }
  
  content = content.replaceAll("Tab(text: 'Umum')", "Tab(text: AppStrings.generalTab)");
  content = content.replaceAll("Tab(text: 'Sosial')", "Tab(text: AppStrings.socialTab)");
  
  file.writeAsStringSync(content);
  print('Updated profile_screen.dart');
}
