enum AppLanguage {
  hindi('hi', 'हिन्दी'),
  english('en', 'English');

  const AppLanguage(this.code, this.label);

  final String code;
  final String label;

  bool get isHindi => this == AppLanguage.hindi;
}
