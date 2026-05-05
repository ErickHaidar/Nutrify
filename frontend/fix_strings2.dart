import 'dart:io';

void main() {
  final file = File('lib/utils/locale/app_strings.dart');
  var content = file.readAsStringSync();
  
  // Find where `_currentLocale = prefs.getString('app_locale') ?? 'id';` is
  // and insert `}` right after it.
  content = content.replaceFirst(
    "_currentLocale = prefs.getString('app_locale') ?? 'id';\n    // ───",
    "_currentLocale = prefs.getString('app_locale') ?? 'id';\n  }\n\n    // ───"
  );
  
  // Also fix the bottom part which might have an extra `}`
  // Let's just remove the first extra `}` from the bottom if we can, or just trust the analyzer to tell us.
  
  file.writeAsStringSync(content);
}
