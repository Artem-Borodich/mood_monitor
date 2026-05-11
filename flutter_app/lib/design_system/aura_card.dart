import 'package:flutter/material.dart';

import '../theme/app_decoration.dart';
import 'design_tokens.dart';

/// Large frosted-style surface used across the app (premium card).
class AuraCard extends StatelessWidget {
  const AuraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.gradient,
    this.onTap,
    this.borderRadius = DsRadii.lg,
    this.elevated = true,
    this.glassBorder = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool elevated;
  final bool glassBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = BorderRadius.circular(borderRadius);
    final border = glassBorder && gradient != null
        ? AppDecorations.glassBorderOnGradient(context)
        : (glassBorder ? AppDecorations.glassBorderLight(context) : null);

    final inner = Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? theme.colorScheme.surface : null,
        borderRadius: r,
        border: border,
        boxShadow: elevated
            ? AppDecorations.cardFloating(context)
            : AppDecorations.cardSubtle(context),
      ),
      child: Padding(padding: padding, child: child),
    );

    Widget core = margin != null ? Padding(padding: margin!, child: inner) : inner;

    if (onTap == null) return core;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: r,
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
        highlightColor: Colors.transparent,
        child: core,
      ),
    );
  }
}
