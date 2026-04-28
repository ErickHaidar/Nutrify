import 'package:nutrify/core/stores/error/error_store.dart';
import 'package:nutrify/domain/entity/language/Language.dart';
import 'package:nutrify/domain/repository/setting/setting_repository.dart';
import 'package:nutrify/utils/locale/app_strings.dart';
import 'package:mobx/mobx.dart';

part 'language_store.g.dart';

class LanguageStore = _LanguageStore with _$LanguageStore;

abstract class _LanguageStore with Store {
  static const String TAG = "LanguageStore";

  // repository instance
  final SettingRepository _repository;

  // store for handling errors
  final ErrorStore errorStore;

  // supported languages
  List<Language> supportedLanguages = [
    Language(code: 'ID', locale: 'id', language: 'Bahasa Indonesia'),
    Language(code: 'US', locale: 'en', language: 'English'),
  ];

  // constructor:---------------------------------------------------------------
  _LanguageStore(this._repository, this.errorStore) {
    init();
  }

  // store variables:-----------------------------------------------------------
  @observable
  String _locale = "id";

  @computed
  String get locale => _locale;

  // actions:-------------------------------------------------------------------
  @action
  void changeLanguage(String value) {
    _locale = value;
    AppStrings.setLocale(value);
    _repository.changeLanguage(value).then((_) {
      // write additional logic here
    });
  }

  @action
  String getCode() {
    var code;

    if (_locale == 'id') {
      code = "ID";
    } else if (_locale == 'en') {
      code = "US";
    }

    return code;
  }

  @action
  String? getLanguage() {
    return supportedLanguages[supportedLanguages
            .indexWhere((language) => language.locale == _locale)]
        .language;
  }

  // general:-------------------------------------------------------------------
  void init() async {
    // getting current language from shared preference
    if (_repository.currentLanguage != null) {
      _locale = _repository.currentLanguage!;
    } else {
      _locale = 'id'; // Default to Indonesian
    }
    AppStrings.setLocale(_locale);
  }

  // dispose:-------------------------------------------------------------------
  @override
  dispose() {}
}
