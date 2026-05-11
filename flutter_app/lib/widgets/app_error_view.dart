import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_exception.dart';
import '../theme/app_spacing.dart';

/// Full-width error state with optional retry (network / server errors).
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.error,
    this.onRetry,
    this.title,
    this.scrollable = true,
    this.padding,
  });

  final Object error;
  final VoidCallback? onRetry;
  final String? title;
  /// When false, uses a [Column] so the widget can sit inside another scroll view.
  final bool scrollable;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final api = error is ApiException ? error as ApiException : null;
    final headline = title ?? loc.errorStateTitle;
    final message = api?.userMessage ?? error.toString();
    final hint = api?.kind == ApiErrorKind.network
        ? loc.errorNetworkHint
        : (api?.kind == ApiErrorKind.server ? loc.errorServerHint : null);

    final pad = padding ??
        const EdgeInsets.fromLTRB(
          AppSpacing.screenHorizontal,
          AppSpacing.screenTop,
          AppSpacing.screenHorizontal,
          AppSpacing.screenBottom,
        );
    final children = <Widget>[
      Icon(
        api?.kind == ApiErrorKind.network
            ? Icons.wifi_off_rounded
            : Icons.error_outline_rounded,
        size: 48,
        color: theme.colorScheme.error,
      ),
      const SizedBox(height: 16),
      Text(
        headline,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      if (hint != null) ...[
        const SizedBox(height: 12),
        Text(
          hint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
      if (onRetry != null) ...[
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(loc.errorRetry),
        ),
      ],
    ];

    if (scrollable) {
      return ListView(
        padding: pad,
        children: children,
      );
    }
    return Padding(
      padding: pad,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
