import 'package:flutter/material.dart';

import '../models/mood_entry.dart';
import '../services/api_service.dart';
import '../widgets/mood_list_item.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final ApiService _api = ApiService();
  late Future<List<MoodEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchMoodEntries();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.fetchMoodEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<MoodEntry>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error: ${snapshot.error}'),
                ),
              ],
            );
          }
          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No mood entries yet.'),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return MoodListItem(entry: entries[index]);
            },
          );
        },
      ),
    );
  }
}

