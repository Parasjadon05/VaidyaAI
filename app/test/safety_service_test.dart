import 'package:flutter_test/flutter_test.dart';
import 'package:vaidyaai/core/localization/app_language.dart';
import 'package:vaidyaai/features/ai/data/safety_service.dart';
import 'package:vaidyaai/features/ai/domain/diagnosis_result.dart';
import 'package:vaidyaai/features/ai/domain/patient_case.dart';

void main() {
  const safetyService = SafetyService();

  test('escalates red flags to red referral', () {
    const patientCase = PatientCase(
      symptoms: 'Fever with breathing difficulty',
      language: AppLanguage.english,
      age: 3,
      temperatureC: 39.4,
      heartRateBpm: 136,
      durationDays: 2,
    );
    const result = DiagnosisResult(
      differentials: [
        DifferentialDiagnosis(
          name: 'Viral fever',
          confidence: 0.6,
          reason: 'Fever present',
        ),
      ],
      triageColor: TriageColor.yellow,
      actions: ['Give fluids'],
      referralRequired: false,
      uncertaintyNote: 'Monitor closely.',
      guidelineSources: ['WHO'],
    );

    final safeResult = safetyService.apply(
      patientCase: patientCase,
      result: result,
    );

    expect(safeResult.triageColor, TriageColor.red);
    expect(safeResult.referralRequired, isTrue);
    expect(safeResult.redFlags, contains('High fever'));
    expect(safeResult.redFlags, contains('Breathing difficulty'));
  });

  test('removes dosage-like text from actions', () {
    const patientCase = PatientCase(
      symptoms: 'rash',
      language: AppLanguage.english,
      age: 30,
      temperatureC: 37.2,
      heartRateBpm: 82,
      durationDays: 1,
    );
    const result = DiagnosisResult(
      differentials: [
        DifferentialDiagnosis(
          name: 'Rash',
          confidence: 0.5,
          reason: 'Skin symptoms',
        ),
      ],
      triageColor: TriageColor.green,
      actions: ['Give tablet 500mg twice daily'],
      referralRequired: false,
      uncertaintyNote: 'Review if worse.',
      guidelineSources: ['Local'],
    );

    final safeResult = safetyService.apply(
      patientCase: patientCase,
      result: result,
    );

    expect(safeResult.actions.single, isNot(contains('500mg')));
    expect(safeResult.actions.single, isNot(contains('twice daily')));
  });
}
