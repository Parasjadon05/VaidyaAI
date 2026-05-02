# VaidyaAI

VaidyaAI is an offline rural health triage aide for the Kaggle Gemma 4 Impact Challenge. The MVP is a Flutter Android-first app for community health workers in rural India: enter Hindi or English symptoms, add vitals, optionally attach a photo placeholder, and receive a conservative triage card in under five seconds.

The app-first strategy is **base Gemma 4 + local clinical RAG + deterministic safety rules**. Fine-tuning is optional and not required for the demo.

## MVP Scope

- Hindi/English UI toggle for the CHW workflow.
- Structured symptoms and vitals intake.
- Photo and voice capture placeholders ready for mobile plugins.
- Local guideline retrieval from bundled assets in `assets/rag/`.
- Prompt builder that injects retrieved guideline chunks into the base model request.
- Mock offline inference engine for reliable demos, with an Ollama-compatible adapter for local Gemma runtime integration.
- Safety layer outside the model for red-flag escalation and dosage blocking.

## Architecture

```mermaid
flowchart TD
    intake["Flutter intake screen"] --> patientCase["PatientCase"]
    patientCase --> rag["LocalAssetRagRetriever"]
    rag --> prompt["ClinicalPromptBuilder"]
    prompt --> engine["InferenceEngine"]
    engine --> safety["SafetyService"]
    safety --> triage["Triage screen"]
```

The app keeps LLM output behind typed contracts. `MockInferenceEngine` powers the current demo, while `OllamaInferenceEngine` provides a local HTTP adapter for an on-device or local Gemma 4 runtime. Safety-critical red-flag escalation remains deterministic even when the model changes.

## Run

```sh
flutter pub get
flutter test
flutter run
```

## Medical Safety

This project is clinical decision support for non-doctor health workers, not a diagnosis device. It does not provide prescription drug dosages, escalates red flags toward referral, and advises PHC or doctor consultation when uncertain.
