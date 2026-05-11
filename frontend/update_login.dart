import 'dart:io';

void main() {
  final file = File('lib/presentation/login/login.dart');
  var content = file.readAsStringSync();
  
  // Replace hardcoded "ATAU"
  content = content.replaceAll("'ATAU'", "AppStrings.or_");
  
  // Replace hardcoded "Masuk" (SignIn button)
  content = content.replaceAll("'Masuk'", "AppStrings.login");
  
  // Add LanguageStore import if not present
  if (!content.contains('home/store/language/language_store.dart')) {
    content = content.replaceFirst("import 'package:nutrify/presentation/login/store/login_store.dart';", 
        "import 'package:nutrify/presentation/login/store/login_store.dart';\nimport 'package:nutrify/presentation/home/store/language/language_store.dart';");
  }

  // Insert Language Toggle icon at the top of _buildBody -> Stack -> children
  // Or inside AppBar. Right now LoginScreen has `appBar: EmptyAppBar(),`
  // Let's add a proper top right button using Positioned inside Stack
  if (!content.contains('_buildLanguageToggle()')) {
    content = content.replaceFirst(
      "Widget _buildBody() {\n    return Stack(\n      children: <Widget>[\n        Center(child: _buildRightSide()),",
      "Widget _buildBody() {\n    return Stack(\n      children: <Widget>[\n        Center(child: _buildRightSide()),\n        Positioned(top: 10, right: 16, child: _buildLanguageToggle()),"
    );
  }

  // Add the implementation of _buildLanguageToggle and _showLanguagePicker to _LoginScreenState
  if (!content.contains('Widget _buildLanguageToggle')) {
    final languageToggleCode = """
  Widget _buildLanguageToggle() {
    return Observer(
      builder: (_) {
        final _langStore = getIt<LanguageStore>();
        return TextButton.icon(
          onPressed: () => _showLanguagePicker(_langStore),
          icon: const Icon(Icons.language, color: NutrifyTheme.darkCard, size: 20),
          label: Text(
            _langStore.locale == 'id' ? 'ID' : 'EN',
            style: const TextStyle(color: NutrifyTheme.darkCard, fontWeight: FontWeight.bold),
          ),
        );
      }
    );
  }

  void _showLanguagePicker(LanguageStore languageStore) {
    showModalBottomSheet(
      context: context,
      backgroundColor: NutrifyTheme.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: NutrifyTheme.darkCard.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(AppStrings.chooseLanguage,
                  style: const TextStyle(
                      color: NutrifyTheme.darkCard,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildLanguageOption(ctx, languageStore, flag: '🇮🇩', label: 'Bahasa Indonesia', locale: 'id'),
              const SizedBox(height: 12),
              _buildLanguageOption(ctx, languageStore, flag: '🇺🇸', label: 'English', locale: 'en'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext ctx, LanguageStore languageStore,
      {required String flag, required String label, required String locale}) {
    final isSelected = AppStrings.currentLocale == locale;
    return GestureDetector(
      onTap: () {
        languageStore.changeLanguage(locale);
        Navigator.pop(ctx);
        setState(() {}); // refresh the whole screen to apply AppStrings
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? NutrifyTheme.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? NutrifyTheme.darkCard : NutrifyTheme.darkCard.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : NutrifyTheme.darkCard,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
""";
    content = content.replaceFirst(
      "// dispose:-------------------------------------------------------------------",
      "$languageToggleCode\n  // dispose:-------------------------------------------------------------------"
    );
  }

  // Also replace 'Daftar' in _SignUpModalContentState if needed
  // It says Text('Daftar'...) we can replace it with Text(AppStrings.signUp...)
  content = content.replaceAll("Text(\n                                  'Daftar',", "Text(\n                                  AppStrings.signUp,");
  
  file.writeAsStringSync(content);
  print('Updated login.dart');
}
