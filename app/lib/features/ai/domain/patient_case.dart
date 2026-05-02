import '../../../core/localization/app_language.dart';

class PatientCase {
  const PatientCase({
    required this.symptoms,
    required this.language,
    required this.age,
    required this.temperatureC,
    required this.heartRateBpm,
    required this.durationDays,
    this.weightKg,
    this.hasPhoto = false,
    this.photoNote,
  });

  final String symptoms;
  final AppLanguage language;
  final int age;
  final double temperatureC;
  final int heartRateBpm;
  final int durationDays;
  final double? weightKg;
  final bool hasPhoto;
  final String? photoNote;

  String get normalizedText => symptoms.toLowerCase();
}
