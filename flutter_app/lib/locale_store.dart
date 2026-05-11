import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyLocale = 'app_locale';
const _keySavedTipIds = 'saved_tip_ids';
const _keyThemeMode = 'app_theme_mode';
const _keyDismissedTipIds = 'dismissed_tip_ids';
const _keyCompletedActionPrefix = 'completed_actions_';
const _keyHelpfulTipIds = 'helpful_tip_ids';
const _keyNotHelpfulTipIds = 'not_helpful_tip_ids';

String _dateKey(DateTime d) {
  final local = d.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$y-$m-$day';
}

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

Future<ThemeMode> getStoredThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  switch (prefs.getString(_keyThemeMode)) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

Future<void> setStoredThemeMode(ThemeMode mode) async {
  final prefs = await SharedPreferences.getInstance();
  final value = switch (mode) {
    ThemeMode.light => 'light',
    ThemeMode.dark => 'dark',
    _ => 'system',
  };
  await prefs.setString(_keyThemeMode, value);
}

Future<Set<String>> getDismissedTipIds() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_keyDismissedTipIds);
  return list != null ? list.toSet() : {};
}

Future<void> setDismissedTipIds(Set<String> ids) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setStringList(_keyDismissedTipIds, ids.toList());
}

Future<void> dismissTipId(String id) async {
  final current = await getDismissedTipIds();
  current.add(id);
  await setDismissedTipIds(current);
}

Future<Set<String>> getCompletedActionKeysForDate(DateTime date) async {
  final prefs = await SharedPreferences.getInstance();
  final key = '$_keyCompletedActionPrefix${_dateKey(date)}';
  final list = prefs.getStringList(key);
  return list != null ? list.toSet() : {};
}

Future<void> markActionCompletedForDate(
  String actionKey,
  DateTime date,
) async {
  final prefs = await SharedPreferences.getInstance();
  final key = '$_keyCompletedActionPrefix${_dateKey(date)}';
  final current = prefs.getStringList(key)?.toSet() ?? <String>{};
  if (current.contains(actionKey)) return;
  current.add(actionKey);
  await prefs.setStringList(key, current.toList());
}

Future<int> getCompletedActionsCountForDate(DateTime date) async {
  final set = await getCompletedActionKeysForDate(date);
  return set.length;
}

Future<int> getWellnessCompletionStreakDays(
  DateTime fromDate, {
  int maxDaysBack = 21,
}) async {
  // Simple streak: consecutive days (starting from `fromDate`) that have any completion.
  var streak = 0;
  final base = DateTime(fromDate.year, fromDate.month, fromDate.day);
  for (var i = 0; i < maxDaysBack; i++) {
    final d = base.subtract(Duration(days: i));
    final count = await getCompletedActionsCountForDate(d);
    if (count == 0) break;
    streak++;
  }
  return streak;
}

Future<bool> isActionCompletedForDate(
  String actionKey,
  DateTime date,
) async {
  final keys = await getCompletedActionKeysForDate(date);
  return keys.contains(actionKey);
}

Future<Set<String>> getHelpfulTipIds() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_keyHelpfulTipIds);
  return list != null ? list.toSet() : {};
}

Future<Set<String>> getNotHelpfulTipIds() async {
  final prefs = await SharedPreferences.getInstance();
  final list = prefs.getStringList(_keyNotHelpfulTipIds);
  return list != null ? list.toSet() : {};
}

Future<void> setTipHelpful(String tipId, {required bool helpful}) async {
  final prefs = await SharedPreferences.getInstance();

  final helpfulList = prefs.getStringList(_keyHelpfulTipIds);
  final notHelpfulList = prefs.getStringList(_keyNotHelpfulTipIds);

  final helpfulIds = helpfulList != null ? helpfulList.toSet() : <String>{};
  final notHelpfulIds =
      notHelpfulList != null ? notHelpfulList.toSet() : <String>{};

  if (helpful) {
    helpfulIds.add(tipId);
    notHelpfulIds.remove(tipId);
  } else {
    notHelpfulIds.add(tipId);
    helpfulIds.remove(tipId);
  }

  await prefs.setStringList(_keyHelpfulTipIds, helpfulIds.toList());
  await prefs.setStringList(_keyNotHelpfulTipIds, notHelpfulIds.toList());
}
