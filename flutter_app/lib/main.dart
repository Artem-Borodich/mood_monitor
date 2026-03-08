import 'package:flutter/material.dart';

import 'screens/add_mood_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/recommendations_screen.dart';

void main() {
  runApp(const MoodApp());
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wellbeing Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
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
      body: _screens[_currentIndex],
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

