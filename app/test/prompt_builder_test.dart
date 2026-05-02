import 'package:flutter_test/flutter_test.dart';
import 'package:vaidyaai/core/localization/app_language.dart';
import 'package:vaidyaai/features/ai/data/prompt_builder.dart';
import 'package:vaidyaai/features/ai/domain/guideline_chunk.dart';
import 'package:vaidyaai/features/ai/domain/patient_case.dart';

void main() {
  test('prompt includes symptoms, vitals, guidelines, and image marker', () {
    const builder = ClinicalPromptBuilder();
    const patientCase = PatientCase(
      symptoms: 'rash on arm',
      language: AppLanguage.english,
      age: 42,
      temperatureC: 38.1,
      heartRateBpm: 90,
      durationDays: 3,
      hasPhoto: true,
    );
    const guidelines = [
      GuidelineChunk(
        id: 'skin',
        title: 'Skin wound',
        language: 'en',
        conditionTags: ['rash'],
        redFlags: ['spreading'],
        actions: ['Clean wound'],
        source: 'WHO',
        text: 'Refer if redness spreads.',
      ),
    ];

    final prompt = builder.build(
      patientCase: patientCase,
      guidelines: guidelines,
    );

    expect(prompt, contains('rash on arm'));
    expect(prompt, contains('temperature 38.1 C'));
    expect(prompt, contains('Skin wound'));
    expect(prompt, contains('[IMAGE: attached JPEG'));
    expect(prompt, contains('Never give dosage instructions'));
  });
}
