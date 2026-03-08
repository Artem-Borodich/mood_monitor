import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/add_mood_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/recommendations_screen.dart';
import 'theme/colors.dart';
void main() {
  runApp(const MoodApp());
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbeing Monitor',
      theme: _buildTheme(),
      home: const MainScaffold(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,

        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: base.appBarTheme.copyWith(
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: base.colorScheme.onSurface,
        ),
      ),
      cardTheme: base.cardTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 6,
  shadowColor: AppColors.shadow,
  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
  selectedItemColor: AppColors.primary,
  unselectedItemColor: AppColors.textSecondary,
  showUnselectedLabels: true,
  type: BottomNavigationBarType.fixed,
  elevation: 8,
  selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
  unselectedLabelStyle: GoogleFonts.inter(),
),
      elevatedButtonTheme: ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    elevation: 6,
    shadowColor: AppColors.shadow,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  ),
),
      scaffoldBackgroundColor: AppColors.background,
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellbeing Monitor'),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ));
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          );
          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Tips',
          ),
        ],
      ),
    );
  }
}

