import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/mood_entry.dart';
import '../services/api_service.dart';

class MoodListItem extends StatelessWidget {
  const MoodListItem({
    super.key,
    required this.entry,
    this.onEdit,
    this.onDelete,
  });

  final MoodEntry entry;
  final void Function(MoodEntry entry)? onEdit;
  final void Function(MoodEntry entry)? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final dateString =
        '${entry.createdAt.year}-${entry.createdAt.month.toString().padLeft(2, '0')}-${entry.createdAt.day.toString().padLeft(2, '0')}';

    Widget card = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
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
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateString,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      loc.historyEntrySubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _pill(
                  context: context,
                  icon: '😊',
                  label: loc.moodLabel,
                  value: entry.mood,
                  color: theme.colorScheme.primary,
                ),
                _pill(
                  context: context,
                  icon: '🔥',
                  label: loc.stressLabel,
                  value: entry.stress,
                  color: theme.colorScheme.error,
                ),
                _pill(
                  context: context,
                  icon: '⚡',
                  label: loc.energyLabel,
                  value: entry.energy,
                  color: theme.colorScheme.tertiary,
                ),
              ],
            ),
            if (entry.note != null && entry.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  entry.note!,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    if (onEdit != null || onDelete != null) {
      return GestureDetector(
        onLongPress: () => _showActions(context, loc),
        child: card,
      );
    }
    return card;
  }

  void _showActions(BuildContext context, AppLocalizations loc) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(loc.editEntry),
                onTap: () {
                  Navigator.pop(context);
                  onEdit!(entry);
                },
              ),
            if (onDelete != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(loc.deleteEntry),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(context, loc);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations loc) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.deleteEntry),
        content: Text(loc.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(loc.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(loc.deleteEntry),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ApiService().deleteMoodEntry(entry.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(loc.entryDeleted)));
      onDelete!(entry);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${loc.errorPrefix}$e')));
    }
  }

  Widget _pill({
    required BuildContext context,
    required String icon,
    required String label,
    required int value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

