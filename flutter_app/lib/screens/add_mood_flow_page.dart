import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_decoration.dart';
import 'add_mood_screen.dart';

/// Full-screen mood entry opened from the shell (not a bottom tab).
class AddMoodFlowPage extends StatelessWidget {
  const AddMoodFlowPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppDecorations.scaffoldGradient(context),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  tooltip: loc.cancel,
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              Expanded(
                child: AddMoodScreen(
                  embeddedInShell: true,
                  onSaved: () {
                    if (context.mounted) Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
