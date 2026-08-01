import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'app_locale';

  Locale _locale = const Locale('zh', 'CN');

  Locale get locale => _locale;

  String get localeName => _locale.languageCode == 'zh' ? '中文' : 'English';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString(_localeKey);
    if (savedLocale != null) {
      if (savedLocale == 'en') {
        _locale = const Locale('en', 'US');
      } else {
        _locale = const Locale('zh', 'CN');
      }
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
