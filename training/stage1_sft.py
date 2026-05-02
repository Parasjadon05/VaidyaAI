#!/usr/bin/env python3
"""Stage 1: Medical knowledge SFT for Gemma 4 E4B with Unsloth LoRA."""

from __future__ import annotations

import argparse
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", default="google/gemma-4-e4b-it")
    parser.add_argument("--dataset", default="medqa")
    parser.add_argument("--output-dir", default="checkpoints/stage1")
    parser.add_argument("--epochs", type=int, default=3)
    parser.add_argument("--batch-size", type=int, default=4)
    parser.add_argument("--learning-rate", type=float, default=2e-4)
    parser.add_argument("--max-seq-length", type=int, default=8192)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    Path(args.output_dir).mkdir(parents=True, exist_ok=True)

    try:
        import unsloth  # noqa: F401
        from unsloth import FastLanguageModel
        from datasets import load_dataset
        from trl import SFTTrainer
        from transformers import TrainingArguments
    except ImportError as exc:
        raise SystemExit(
            "Install training dependencies in a GPU environment: "
            "unsloth, transformers, trl, datasets, accelerate."
        ) from exc

    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=args.model,
        max_seq_length=args.max_seq_length,
        load_in_4bit=True,
    )
    model = FastLanguageModel.get_peft_model(
        model,
        r=16,
        lora_alpha=32,
        target_modules=["q_proj", "k_proj", "v_proj", "o_proj"],
        lora_dropout=0,
        bias="none",
        use_gradient_checkpointing="unsloth",
    )

    dataset = load_dataset(args.dataset, split="train")

    def format_example(example: dict) -> dict:
        question = example.get("question") or example.get("prompt") or ""
        answer = example.get("answer") or example.get("response") or ""
        return {
            "text": (
                "You are a cautious clinical reasoning assistant.\n"
                f"Question: {question}\n"
                "Answer with differential diagnosis, reasoning, triage, and safe next action.\n"
                f"Response: {answer}"
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
            warmup_ratio=0.03,
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
