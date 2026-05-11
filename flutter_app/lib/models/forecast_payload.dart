class ForecastFactor {
  const ForecastFactor({required this.name, required this.impact});

  final String name;
  final String impact;

  factory ForecastFactor.fromJson(Map<String, dynamic> json) {
    return ForecastFactor(
      name: json['name'] as String,
      impact: json['impact'] as String,
    );
  }
}

class ForecastPayload {
  const ForecastPayload({
    required this.status,
    this.risk,
    this.label,
    this.threshold = 0.5,
    this.factors,
    this.explanation,
    this.targetDate,
  });

  final String status;
  final double? risk;
  final String? label;
  final double threshold;
  final List<ForecastFactor>? factors;
  final String? explanation;
  final String? targetDate;

  factory ForecastPayload.fromJson(Map<String, dynamic> json) {
    final rawFactors = json['factors'] as List<dynamic>?;
    return ForecastPayload(
      status: json['status'] as String? ?? 'ok',
      risk: (json['risk'] as num?)?.toDouble(),
      label: json['label'] as String?,
      threshold: (json['threshold'] as num?)?.toDouble() ?? 0.5,
      factors: rawFactors
          ?.map((e) => ForecastFactor.fromJson(e as Map<String, dynamic>))
          .toList(),
      explanation: json['explanation'] as String?,
      targetDate: json['target_date'] as String?,
    );
  }
}

