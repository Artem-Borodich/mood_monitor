/// Matches backend `wellbeing_constants` + `calculate_wellbeing`.
const double moodWeight = 0.4;
const double energyWeight = 0.3;
const double stressWeight = 0.3;

/// Min / max of `0.4*m + 0.3*e - 0.3*s` for mood, stress, energy in 1..10.
const double kWellbeingIndexMin =
    moodWeight * 1 + energyWeight * 1 - stressWeight * 10;
const double kWellbeingIndexMax =
    moodWeight * 10 + energyWeight * 10 - stressWeight * 1;

double calculateWellbeingIndex({
  required int mood,
  required int stress,
  required int energy,
}) {
  return double.parse(
    (moodWeight * mood + energyWeight * energy - stressWeight * stress)
        .toStringAsFixed(2),
  );
}

/// Maps raw index to 0–100 for the dashboard ring (same scale as recommendations).
double wellbeingIndexToDisplayPercent(double index) {
  final span = kWellbeingIndexMax - kWellbeingIndexMin;
  if (span <= 0) return 0;
  return (((index - kWellbeingIndexMin) / span) * 100).clamp(0.0, 100.0);
}

/// Bands aligned with backend recommendation copy (index < 3, < 6, else).
enum WellbeingTier { low, medium, high }

WellbeingTier wellbeingTierFromIndex(double index) {
  if (index < 3) return WellbeingTier.low;
  if (index < 6) return WellbeingTier.medium;
  return WellbeingTier.high;
}

/// Human-friendly percent for the ring (avoids confusing bare `0` when value is tiny).
String formatWellbeingPercentDisplay(double percent01to100, bool hasData) {
  if (!hasData) return '—';
  final p = percent01to100.clamp(0.0, 100.0);
  if (p <= 0) return '0';
  if (p < 1) return '<1';
  return '${p.round()}';
}
