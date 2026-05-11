import 'package:flutter/material.dart';

import '../theme/app_decoration.dart';

class SerenityCard extends StatelessWidget {
  const SerenityCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
    this.onTap,
    this.borderRadius = 24,
    this.elevated = true,
    this.glassBorder = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool elevated;
  final bool glassBorder;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(borderRadius);
    final border = glassBorder && gradient != null
        ? AppDecorations.glassBorderOnGradient(context)
        : (glassBorder ? AppDecorations.glassBorderLight(context) : null);

    final card = Container(
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null ? Theme.of(context).colorScheme.surface : null,
        borderRadius: r,
        border: border,
        boxShadow: elevated ? AppDecorations.cardFloating(context) : AppDecorations.cardSubtle(context),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: r,
        splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        child: card,
      ),
    );
  }
}
