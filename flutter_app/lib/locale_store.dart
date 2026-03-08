import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyLocale = 'app_locale';
const _keySavedTipIds = 'saved_tip_ids';

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

Future<Set<String>> getSavedTipIds() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_keySavedTipIds);
  return list != null ? list.toSet() : {};
}

Future<void> setSavedTipIds(Set<String> ids) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_keySavedTipIds, ids.toList());
}

Future<void> toggleSavedTipId(String id) async {
  final current = await getSavedTipIds();
  if (current.contains(id)) {
    current.remove(id);
  } else {
    current.add(id);
  }
  await setSavedTipIds(current);
}
