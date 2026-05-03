import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/app_config.dart';
import '../l10n/app_localizations.dart';
import '../locale_store.dart';
import '../theme/app_spacing.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final Locale? currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  String _themeSubtitle(AppLocalizations loc) {
    return switch (themeMode) {
      ThemeMode.light => loc.settingsThemeLight,
      ThemeMode.dark => loc.settingsThemeDark,
      _ => loc.settingsThemeSystem,
    };
  }

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
            elevation: 2,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(loc.settingsAppearance),
                  subtitle: Text(_themeSubtitle(loc)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showThemeSheet(context, loc),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(loc.settingsLanguage),
                  subtitle: Text(
                    currentLocale?.languageCode == 'ru'
                        ? loc.languageRussian
                        : loc.languageEnglish,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showLanguagePicker(context, loc),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.betweenSections),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) {
              final version = snap.data?.version ?? '…';
              final build = snap.data?.buildNumber ?? '';
              final verLabel =
                  build.isEmpty ? version : '$version ($build)';
              return Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_outline_rounded,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            loc.settingsAbout,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.titleToContent),
                      Text(
                        loc.settingsAboutBody,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.betweenCards),
                      SelectableText(
                        '${loc.settingsVersion}: $verLabel',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        AppConfig.apiBaseUrl,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontFamily: 'monospace',
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        loc.settingsApiHint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                child: Text(
                  loc.settingsAppearance,
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              _themeTile(
                ctx,
                loc.settingsThemeSystem,
                ThemeMode.system,
                Icons.brightness_auto_rounded,
              ),
              _themeTile(
                ctx,
                loc.settingsThemeLight,
                ThemeMode.light,
                Icons.light_mode_rounded,
              ),
              _themeTile(
                ctx,
                loc.settingsThemeDark,
                ThemeMode.dark,
                Icons.dark_mode_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _themeTile(
    BuildContext context,
    String label,
    ThemeMode mode,
    IconData icon,
  ) {
    final selected = themeMode == mode;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing:
          selected ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary) : null,
      onTap: () {
        onThemeModeChanged(mode);
        Navigator.pop(context);
      },
    );
  }

  void _showLanguagePicker(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(loc.languageEnglish),
                trailing: currentLocale?.languageCode != 'ru'
                    ? Icon(Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () {
                  onLocaleChanged(const Locale('en'));
                  setStoredLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ListTile(
                title: Text(loc.languageRussian),
                trailing: currentLocale?.languageCode == 'ru'
                    ? Icon(Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
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
