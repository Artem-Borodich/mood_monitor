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

  final _screens = const [
    DashboardScreen(),
    AddMoodScreen(),
    HistoryScreen(),
    RecommendationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.appTitle),
        actions: [
          if (widget.onOpenSettings != null)
            IconButton(
              tooltip: loc.settingsTitle,
              icon: const Icon(Icons.settings_rounded),
              onPressed: () => widget.onOpenSettings!(context),
            ),
        ],
      ),
      body: AnimatedSwitcher(
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
      bottomNavigationBar: NavigationBar(
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
            icon: const Icon(Icons.add_circle_outline_rounded),
            selectedIcon: const Icon(Icons.add_circle_rounded),
            label: loc.navAdd,
          ),
          NavigationDestination(
            icon: const Icon(Icons.format_list_bulleted_outlined),
            selectedIcon: const Icon(Icons.format_list_bulleted_rounded),
            label: loc.navHistory,
          ),
          NavigationDestination(
            icon: const Icon(Icons.lightbulb_outline_rounded),
            selectedIcon: const Icon(Icons.lightbulb_rounded),
            label: loc.navTips,
          ),
        ],
      ),
    );
  }
}
