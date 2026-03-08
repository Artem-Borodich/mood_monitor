import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_service.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _future;
  String? _lastLang;

  @override
  void initState() {
    super.initState();
    _future = Future.value(<String, dynamic>{}); // will be replaced in build
  }

  Future<void> _refresh() async {
    final lang = _lastLang ?? 'en';
    setState(() {
      _future = _fetch(lang);
    });
  }

  Future<Map<String, dynamic>> _fetch(String lang) {
    return _api.fetchRecommendations(lang: lang);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context);
    final lang = locale.languageCode == 'ru' ? 'ru' : 'en';
    if (_lastLang != lang) {
      _lastLang = lang;
      _future = _fetch(lang);
    }

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
                  padding: const EdgeInsets.all(20),
                  child: Text('${loc.errorPrefix}${snapshot.error}'),
                ),
              ],
            );
          }
          final data = snapshot.data ?? {};
          final index = data['wellbeing_index'] as num?;
          final message = data['message'] as String? ??
              'No recommendation available. Try adding a mood entry.';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                loc.tipsTodayTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                loc.tipsTodaySubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              if (index != null)
                _buildIndexCard(
                  context: context,
                  index: index.toDouble(),
                ),
              const SizedBox(height: 16),
              _buildMessageCard(
                context: context,
                message: message,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildIndexCard({
    required BuildContext context,
    required double index,
  }) {
    final theme = Theme.of(context);

    Color background;
    IconData icon;
    String title;

    if (index >= 7.5) {
      background = Colors.greenAccent.withOpacity(0.25);
      icon = Icons.sentiment_very_satisfied_rounded;
      title = 'You\'re doing great';
    } else if (index >= 5) {
      background = Colors.amberAccent.withOpacity(0.25);
      icon = Icons.sentiment_satisfied_rounded;
      title = 'You\'re in the middle zone';
    } else {
      background = Colors.redAccent.withOpacity(0.25);
      icon = Icons.sentiment_dissatisfied_rounded;
      title = 'You might need extra care';
    }

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 28,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wellbeing Index: ${index.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer
                          .withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required BuildContext context,
    required String message,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                Icons.lightbulb_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal tip',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

