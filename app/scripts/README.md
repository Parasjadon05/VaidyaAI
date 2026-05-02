# VaidyaAI Scripts

This directory is reserved for offline data and model preparation outside the Flutter app.

Planned scripts:

- `prepare_rag_sqlite.py`: convert curated guideline JSON into a bundled SQLite or FTS database.
- `generate_hindi_medqa.py`: translate and review selected MedQA-style examples for Hindi localization.
- `unsloth_lora_train.py`: train a Gemma LoRA adapter for medical QA and safe referral phrasing.
- `quantize_gemma.sh`: export and quantize model artifacts for the selected on-device runtime.

The MVP currently uses `assets/rag/guideline_chunks.json` directly so the app remains dependency-light.
