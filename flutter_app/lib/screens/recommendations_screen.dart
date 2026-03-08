import 'package:flutter/material.dart';

import '../services/api_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchRecommendations();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _api.fetchRecommendations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Map<String, dynamic>>(
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
          final data = snapshot.data ?? {};
          final index = data['wellbeing_index'] as num?;
          final message = data['message'] as String? ??
              'No recommendation available. Try adding a mood entry.';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (index != null)
                Text(
                  'Wellbeing Index: ${index.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              const SizedBox(height: 16),
              Text(
                message,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          );
        },
      ),
    );
  }
}

