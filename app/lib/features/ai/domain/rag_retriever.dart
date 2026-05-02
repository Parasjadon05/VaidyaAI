import 'guideline_chunk.dart';
import 'patient_case.dart';

abstract interface class RagRetriever {
  Future<List<GuidelineChunk>> retrieve(PatientCase patientCase);
}
