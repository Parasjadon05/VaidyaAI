#!/usr/bin/env python3
"""Stage 2: Continue LoRA training on paired clinical images and responses."""

from __future__ import annotations

import argparse
import base64
import json
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage1-checkpoint", default="checkpoints/stage1")
    parser.add_argument("--image-jsonl", default="data/multimodal_clinical.jsonl")
    parser.add_argument("--output-dir", default="checkpoints/stage2")
    parser.add_argument("--epochs", type=int, default=1)
    parser.add_argument("--batch-size", type=int, default=2)
    parser.add_argument("--learning-rate", type=float, default=1e-4)
    parser.add_argument("--max-seq-length", type=int, default=8192)
    return parser.parse_args()


def validate_jsonl(path: Path) -> None:
    if not path.exists():
        raise SystemExit(
            f"Missing {path}. Expected JSONL rows with image, text, and response fields."
        )
    with path.open() as handle:
        first = json.loads(next(handle))
    required = {"image", "text", "response"}
    missing = required.difference(first)
    if missing:
        raise SystemExit(f"{path} is missing required fields: {sorted(missing)}")
    base64.b64decode(first["image"], validate=True)


def main() -> None:
    args = parse_args()
    image_jsonl = Path(args.image_jsonl)
    validate_jsonl(image_jsonl)
    Path(args.output_dir).mkdir(parents=True, exist_ok=True)

    try:
        import unsloth  # noqa: F401
        from unsloth import FastVisionModel
        from datasets import load_dataset
        from trl import SFTTrainer
        from transformers import TrainingArguments
    except ImportError as exc:
        raise SystemExit(
            "Install multimodal training dependencies: unsloth, transformers, trl, datasets."
        ) from exc

    model, tokenizer = FastVisionModel.from_pretrained(
        args.stage1_checkpoint,
        max_seq_length=args.max_seq_length,
        load_in_4bit=True,
    )
    FastVisionModel.for_training(model)

    dataset = load_dataset("json", data_files=str(image_jsonl), split="train")

    def format_example(example: dict) -> dict:
        return {
            "text": (
                "<image>\n"
                f"{example['text']}\n"
                "Respond with diagnosis, visual evidence, triage, and safe recommended action.\n"
                f"{example['response']}"
            )
        }

    dataset = dataset.map(format_example, remove_columns=dataset.column_names)
    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=dataset,
        dataset_text_field="text",
        max_seq_length=args.max_seq_length,
        args=TrainingArguments(
            output_dir=args.output_dir,
            num_train_epochs=args.epochs,
            per_device_train_batch_size=args.batch_size,
            learning_rate=args.learning_rate,
            lr_scheduler_type="cosine",
            logging_steps=25,
            save_strategy="epoch",
            fp16=True,
            report_to="none",
        ),
    )
    trainer.train()
    trainer.save_model(args.output_dir)
    tokenizer.save_pretrained(args.output_dir)


if __name__ == "__main__":
    main()
