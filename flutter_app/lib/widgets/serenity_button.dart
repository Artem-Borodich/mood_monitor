import 'package:flutter/material.dart';

import '../theme/app_decoration.dart';
import '../design_system/design_tokens.dart';

/// Primary CTA — full width, soft gradient, large tap target.
class SerenityButton extends StatelessWidget {
  const SerenityButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DsRadii.pill),
          gradient: enabled ? AppDecorations.primaryHeroGradient() : LinearGradient(
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surfaceContainerHigh,
            ],
          ),
          boxShadow: enabled ? AppDecorations.cardSubtle(context) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(DsRadii.pill),
            onTap: onPressed,
            child: SizedBox(
              width: double.infinity,
              height: DsSizes.minTap + 6,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: enabled ? Colors.white : theme.colorScheme.onSurfaceVariant, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: enabled ? Colors.white : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
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
