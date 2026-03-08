import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyLocale = 'app_locale';

Future<Locale?> getStoredLocale() async {
  final prefs = await SharedPreferences.getInstance();
  final code = prefs.getString(_keyLocale);
  if (code == null) return null;
  return Locale(code);
}

Future<void> setStoredLocale(Locale locale) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyLocale, locale.languageCode);
}
