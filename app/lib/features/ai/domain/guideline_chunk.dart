class GuidelineChunk {
  const GuidelineChunk({
    required this.id,
    required this.title,
    required this.language,
    required this.conditionTags,
    required this.redFlags,
    required this.actions,
    required this.source,
    required this.text,
  });

  final String id;
  final String title;
  final String language;
  final List<String> conditionTags;
  final List<String> redFlags;
  final List<String> actions;
  final String source;
  final String text;

  factory GuidelineChunk.fromJson(Map<String, dynamic> json) {
    return GuidelineChunk(
      id: json['id'] as String,
      title: json['title'] as String,
      language: json['language'] as String,
      conditionTags: List<String>.from(json['conditionTags'] as List),
      redFlags: List<String>.from(json['redFlags'] as List),
      actions: List<String>.from(json['actions'] as List),
      source: json['source'] as String,
      text: json['text'] as String,
    );
  }

  bool matches(String symptoms) {
    final haystack = symptoms.toLowerCase();
    return conditionTags.any((tag) => haystack.contains(tag.toLowerCase()));
  }
}
