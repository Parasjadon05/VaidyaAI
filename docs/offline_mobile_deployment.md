# Offline Mobile Deployment Plan

This is the practical hackathon path for making VaidyaAI credible as an offline mobile app without requiring a free-GPU fine-tune.

## What Is Already Offline

- Flutter UI and workflow are local.
- Hindi/English strings are bundled.
- Guideline RAG seed data is bundled in `app/assets/rag/guideline_chunks.json`.
- SQLite knowledge base is bundled in `app/assets/knowledge_base.sqlite`.
- Red-flag escalation and dosage blocking run in Dart.
- Demo inference uses a deterministic local mock engine.

## What Makes It Fully Offline

The phone must also contain:

- A quantized base Gemma model file.
- A native runtime that can execute that model locally.
- A Flutter bridge from the intake flow to that runtime.

No cloud API should be needed at inference time.

## Recommended Hackathon Runtime Path

Use this order:

1. **Demo now:** `MockInferenceEngine` + local RAG + safety layer.
2. **Local machine proof:** `OllamaInferenceEngine` pointed at a local Gemma runtime.
3. **Android proof:** GGUF model with llama.cpp through a Flutter native bridge.
4. **Google-aligned stretch:** LiteRT / Google AI Edge conversion if Gemma 4 mobile export is available in time.

## Android Packaging Options

Large model files should not live directly inside a normal APK.

Better options:

- Android Play Asset Delivery / asset pack.
- Expansion file or sideloaded model directory.
- Demo phone preloaded with `models/vaidya_gemma_q4.gguf`.

The app should check for the model file and show a clear runtime status:

```text
RAG DB: bundled
Safety rules: bundled
Model runtime: mock / local Gemma
Model file: missing / ready
Network: not required
```

## Demo Script

1. Turn on airplane mode.
2. Open VaidyaAI.
3. Show Offline readiness screen.
4. Enter Hindi symptoms.
5. Attach photo placeholder.
6. Run triage.
7. Show guideline grounding and safety-layer chip.
8. Trigger a red-flag case to prove deterministic escalation.

## Honest Submission Wording

Use this in the video or README:

> VaidyaAI is designed for offline deployment. The MVP already bundles local guideline retrieval and deterministic clinical safety rules. The model boundary supports local Gemma execution through an on-device runtime; the demo uses a deterministic local engine while the same prompt/RAG/safety contract is ready for a quantized Gemma runtime.
