import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_spacing.dart';

/// 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s × 4 cycles (~2 min).
class BreathingTimerScreen extends StatefulWidget {
  const BreathingTimerScreen({super.key});

  @override
  State<BreathingTimerScreen> createState() => _BreathingTimerScreenState();
}

class _BreathingTimerScreenState extends State<BreathingTimerScreen> {
  static const int _inhaleSec = 4;
  static const int _holdSec = 7;
  static const int _exhaleSec = 8;
  static const int _cycles = 4;

  int _cycle = 0;
  String _phase = 'inhale';
  int _secondsLeft = _inhaleSec;
  Timer? _timer;
  bool _running = false;

  int _phaseTotalSeconds() {
    return switch (_phase) {
      'inhale' => _inhaleSec,
      'hold' => _holdSec,
      'exhale' => _exhaleSec,
      _ => _inhaleSec,
    };
  }

  double _phaseProgress() {
    final total = _phaseTotalSeconds();
    if (total <= 0) return 0;
    return ((total - _secondsLeft) + 1).clamp(1, total) / total;
  }

  Color _phaseColor(ColorScheme cs) {
    return switch (_phase) {
      'inhale' => cs.primary,
      'hold' => cs.tertiary,
      'exhale' => cs.secondary,
      _ => cs.primary,
    };
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _secondsLeft--;
      if (_secondsLeft > 0) return;
      switch (_phase) {
        case 'inhale':
          _phase = 'hold';
          _secondsLeft = _holdSec;
          break;
        case 'hold':
          _phase = 'exhale';
          _secondsLeft = _exhaleSec;
          break;
        case 'exhale':
          _cycle++;
          if (_cycle >= _cycles) {
            _stop();
            HapticFeedback.mediumImpact();
            if (mounted) Navigator.of(context).pop(true);
            return;
          }
          _phase = 'inhale';
          _secondsLeft = _inhaleSec;
          break;
      }
    });
    HapticFeedback.selectionClick();
  }

  void _start() {
    if (_running) return;
    HapticFeedback.lightImpact();
    setState(() {
      _running = true;
      _cycle = 0;
      _phase = 'inhale';
      _secondsLeft = _inhaleSec;
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _running = false);
  }

  String _phaseLabel(AppLocalizations loc) {
    return switch (_phase) {
      'inhale' => loc.tipsBreathInhale,
      'hold' => loc.tipsBreathHold,
      'exhale' => loc.tipsBreathExhale,
      _ => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(_running ? loc.tipsBreathTitle : loc.breathUiReadyTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          tooltip: loc.breathUiClose,
          onPressed: () {
            _stop();
            Navigator.of(context).pop(false);
          },
        ),
        actions: [
          if (_running)
            TextButton(
              onPressed: () {
                _stop();
                Navigator.of(context).pop(false);
              },
              child: Text(loc.breathUiStop),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.surface,
              cs.primaryContainer.withValues(alpha: 0.35),
              cs.surfaceContainerLow.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenHorizontal,
              8,
              AppSpacing.screenHorizontal,
              AppSpacing.screenBottom,
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (!_running) ...[
                          Text(
                            loc.breathUiReadySubtitle,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _StepTile(n: 1, text: loc.breathUiStep1, cs: cs, theme: theme),
                          _StepTile(n: 2, text: loc.breathUiStep2, cs: cs, theme: theme),
                          _StepTile(n: 3, text: loc.breathUiStep3, cs: cs, theme: theme),
                          const SizedBox(height: 12),
                          Text(
                            '${loc.breathUiCycles}: $_cycles · ${loc.recDurBreathing}',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 320),
                            switchInCurve: Curves.easeOutCubic,
                            child: Text(
                              _phaseLabel(loc),
                              key: ValueKey(_phase + _secondsLeft.toString()),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: _phaseColor(cs),
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: 240,
                            height: 240,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Transform.rotate(
                                  angle: -math.pi / 2,
                                  child: SizedBox(
                                    width: 240,
                                    height: 240,
                                    child: CircularProgressIndicator(
                                      value: _phaseProgress().clamp(0.001, 1.0),
                                      strokeWidth: 14,
                                      strokeCap: StrokeCap.round,
                                      backgroundColor:
                                          cs.surfaceContainerHighest.withValues(alpha: 0.9),
                                      color: _phaseColor(cs),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$_secondsLeft',
                                      style: theme.textTheme.displayLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        height: 1,
                                        fontSize: 64,
                                      ),
                                    ),
                                    Text(
                                      loc.breathUiSec,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '${loc.breathUiCycles}: ${_cycle + 1} / $_cycles',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            loc.breathUiRunningFooter,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_running)
                  FilledButton.icon(
                    onPressed: _start,
                    icon: const Icon(Icons.play_arrow_rounded, size: 26),
                    label: Text(loc.breathUiStart),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.n,
    required this.text,
    required this.cs,
    required this.theme,
  });

  final int n;
  final String text;
  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$n',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: cs.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
