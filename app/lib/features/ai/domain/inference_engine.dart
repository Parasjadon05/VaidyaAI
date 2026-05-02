import 'diagnosis_result.dart';
import 'guideline_chunk.dart';
import 'patient_case.dart';

abstract interface class InferenceEngine {
  String get name;

  Future<DiagnosisResult> analyze({
    required PatientCase patientCase,
    required List<GuidelineChunk> guidelines,
    required String prompt,
  });
}
