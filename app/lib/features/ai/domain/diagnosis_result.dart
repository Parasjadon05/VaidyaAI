enum TriageColor {
  green,
  yellow,
  red;

  String get label => switch (this) {
    TriageColor.green => 'GREEN',
    TriageColor.yellow => 'YELLOW',
    TriageColor.red => 'RED',
  };
}

class DifferentialDiagnosis {
  const DifferentialDiagnosis({
    required this.name,
    required this.confidence,
    required this.reason,
  });

  final String name;
  final double confidence;
  final String reason;
}

class DiagnosisResult {
  const DiagnosisResult({
    required this.differentials,
    required this.triageColor,
    required this.actions,
    required this.referralRequired,
    required this.uncertaintyNote,
    required this.guidelineSources,
    this.redFlags = const [],
    this.promptPreview,
  });

  final List<DifferentialDiagnosis> differentials;
  final TriageColor triageColor;
  final List<String> actions;
  final bool referralRequired;
  final String uncertaintyNote;
  final List<String> guidelineSources;
  final List<String> redFlags;
  final String? promptPreview;

  DiagnosisResult copyWith({
    List<DifferentialDiagnosis>? differentials,
    TriageColor? triageColor,
    List<String>? actions,
    bool? referralRequired,
    String? uncertaintyNote,
    List<String>? guidelineSources,
    List<String>? redFlags,
    String? promptPreview,
  }) {
    return DiagnosisResult(
      differentials: differentials ?? this.differentials,
      triageColor: triageColor ?? this.triageColor,
      actions: actions ?? this.actions,
      referralRequired: referralRequired ?? this.referralRequired,
      uncertaintyNote: uncertaintyNote ?? this.uncertaintyNote,
      guidelineSources: guidelineSources ?? this.guidelineSources,
      redFlags: redFlags ?? this.redFlags,
      promptPreview: promptPreview ?? this.promptPreview,
    );
  }
}
