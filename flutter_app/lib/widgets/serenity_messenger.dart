import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../theme/app_decoration.dart';

/// Toast style aligned with Serenity (glass card, fixed slot, no layout jump).
enum SerenitySnackKind {
  success,
  info,
  error,
}

/// Centralized snack toasts: stable bottom offset, width clamp, soft motion.
abstract final class SerenityMessenger {
  static const Duration _success = Duration(milliseconds: 2600);
  static const Duration _info = Duration(milliseconds: 3000);
  static const Duration _error = Duration(milliseconds: 4400);

  /// Space above system gesture area + bottom navigation (72) + outer padding (12).
  static double _bottomReserve(BuildContext context) {
    final mq = MediaQuery.of(context);
    return mq.padding.bottom + mq.viewInsets.bottom + 88;
  }

  static void show(
    BuildContext context,
    String message, {
    SerenitySnackKind kind = SerenitySnackKind.success,
    Duration? duration,
  }) {
    final text = message.trim();
    if (text.isEmpty) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final screenW = MediaQuery.sizeOf(context).width;
    final barW = (screenW - 32).clamp(280.0, 480.0);

    final (IconData icon, Color iconBg, Color iconFg) = switch (kind) {
      SerenitySnackKind.success => (
          Icons.check_circle_rounded,
          cs.primaryContainer.withValues(alpha: 0.92),
          cs.primary,
        ),
      SerenitySnackKind.info => (
          Icons.info_rounded,
          cs.tertiaryContainer.withValues(alpha: 0.92),
          cs.tertiary,
        ),
      SerenitySnackKind.error => (
          Icons.error_rounded,
          cs.errorContainer.withValues(alpha: 0.95),
          cs.error,
        ),
    };

    final d = duration ?? switch (kind) {
      SerenitySnackKind.error => _error,
      SerenitySnackKind.info => _info,
      SerenitySnackKind.success => _success,
    };

    messenger.clearSnackBars();

    messenger.showSnackBar(
      SnackBar(
        duration: d,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        clipBehavior: Clip.none,
        dismissDirection: DismissDirection.horizontal,
        margin: EdgeInsets.fromLTRB(16, 0, 16, _bottomReserve(context)),
        width: barW,
        content: Animate(
          effects: [
            FadeEffect(
              duration: 240.ms,
              curve: Curves.easeOutCubic,
            ),
            SlideEffect(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
              duration: 320.ms,
              curve: Curves.easeOutCubic,
            ),
          ],
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: cs.surface.withValues(alpha: 0.94),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.55),
              ),
              boxShadow: AppDecorations.cardFloating(context),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Icon(icon, color: iconFg, size: 22),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
