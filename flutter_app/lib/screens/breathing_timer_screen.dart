import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 4-7-8 breathing: inhale 4s, hold 7s, exhale 8s. Repeats for 4 cycles (~2 min).
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
            return;
          }
          _phase = 'inhale';
          _secondsLeft = _inhaleSec;
          break;
      }
    });
  }

  void _start() {
    if (_running) return;
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
    switch (_phase) {
      case 'inhale':
        return loc.tipsBreathInhale;
      case 'hold':
        return loc.tipsBreathHold;
      case 'exhale':
        return loc.tipsBreathExhale;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.tipsBreathTitle),
        actions: [
          if (_running)
            TextButton(
              onPressed: _stop,
              child: Text(loc.cancel),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_running) ...[
                Text(
                  loc.tipsBreathSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(loc.tipsBreathStart),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ] else ...[
                Text(
                  _phaseLabel(loc),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '$_secondsLeft',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${loc.tipsBreathCycle} ${_cycle + 1} / $_cycles',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
