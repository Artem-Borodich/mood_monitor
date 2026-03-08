import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../locale_store.dart';
import '../theme/app_spacing.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  final Locale? currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.screenTop,
          AppSpacing.screenHorizontal,
          AppSpacing.screenBottom,
        ),
        children: [
          Card(
            elevation: 4,
            child: Column(
              children: [
                ListTile(
                  title: Text(loc.settingsLanguage),
                  subtitle: Text(
                    currentLocale?.languageCode == 'ru'
                        ? loc.languageRussian
                        : loc.languageEnglish,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showLanguagePicker(context, loc),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(loc.languageEnglish),
                onTap: () {
                  onLocaleChanged(const Locale('en'));
                  setStoredLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(loc.languageRussian),
                onTap: () {
                  onLocaleChanged(const Locale('ru'));
                  setStoredLocale(const Locale('ru'));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
