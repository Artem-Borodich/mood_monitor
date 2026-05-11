import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'l10n/app_localizations.dart';
import 'locale_store.dart';
import 'screens/add_mood_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/recommendations_screen.dart';
import 'screens/settings_screen.dart';
import 'design_system/design_tokens.dart';
import 'theme/app_decoration.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  await initializeDateFormatting('ru');
  runApp(const MoodApp());
}

class MoodApp extends StatefulWidget {
  const MoodApp({super.key});

  @override
  State<MoodApp> createState() => _MoodAppState();
}

class _MoodAppState extends State<MoodApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    getStoredLocale().then((l) {
      if (mounted) setState(() => _locale = l);
    });
    getStoredThemeMode().then((m) {
      if (mounted) setState(() => _themeMode = m);
    });
  }

  void _setLocale(Locale locale) {
    setState(() => _locale = locale);
    setStoredLocale(locale);
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    setStoredThemeMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbeing Monitor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(null),
      darkTheme: AppTheme.darkTheme(null),
      themeMode: _themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: _locale,
      home: MainScaffold(
        onOpenSettings: (ctx) => Navigator.push(
          ctx,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              currentLocale: _locale,
              onLocaleChanged: _setLocale,
              themeMode: _themeMode,
              onThemeModeChanged: _setThemeMode,
            ),
          ),
        ),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key, this.onOpenSettings});

  final void Function(BuildContext context)? onOpenSettings;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        onAddMoodTap: () => setState(() => _currentIndex = 2),
      ),
      const HistoryScreen(),
      const AddMoodScreen(),
      const RecommendationsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      extendBody: true,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppDecorations.scaffoldGradient(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Material(
                  elevation: 6,
                  shadowColor: cs.primary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(22),
                  color: cs.surface.withValues(alpha: 0.92),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: cs.primaryContainer,
                          child: Icon(Icons.person_rounded, size: 18, color: cs.onPrimaryContainer),
                        ),
                        const Spacer(),
                        ShaderMask(
                          shaderCallback: (bounds) => AppDecorations.primaryHeroGradient().createShader(bounds),
                          child: Text(
                            'Serenity',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: loc.settingsTitle,
                          style: IconButton.styleFrom(
                            backgroundColor: cs.surfaceContainerHighest.withValues(alpha: 0.8),
                          ),
                          onPressed: () => widget.onOpenSettings?.call(context),
                          icon: Icon(Icons.tune_rounded, color: cs.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.03, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: _screens[_currentIndex],
                ),
              ),
            ),
          ],
        ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 72),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppDecorations.primaryHeroGradient(),
            boxShadow: AppDecorations.cardSubtle(context),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _currentIndex = 2);
              },
              child: SizedBox(
                width: DsSizes.fab,
                height: DsSizes.fab,
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        child: Material(
          elevation: 22,
          shadowColor: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(28),
          color: cs.surface.withValues(alpha: 0.98),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: NavigationBar(
            height: 72,
            backgroundColor: Colors.transparent,
            indicatorColor: cs.primaryContainer,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              HapticFeedback.selectionClick();
              setState(() => _currentIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                selectedIcon: const Icon(Icons.dashboard_rounded),
                label: loc.navDashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_rounded),
                selectedIcon: const Icon(Icons.history_toggle_off_rounded),
                label: loc.navHistory,
              ),
              NavigationDestination(
                icon: const Icon(Icons.add_circle_outline_rounded),
                selectedIcon: const Icon(Icons.add_circle_rounded),
                label: loc.navAdd,
              ),
              NavigationDestination(
                icon: const Icon(Icons.lightbulb_outline_rounded),
                selectedIcon: const Icon(Icons.lightbulb_rounded),
                label: loc.navTips,
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
