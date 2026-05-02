#!/usr/bin/env python3
"""Stage 3: Hindi safety and humility preference tuning with DPO."""

from __future__ import annotations

import argparse
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--stage2-checkpoint", default="checkpoints/stage2")
    parser.add_argument("--dataset", default="data/hindi_dpo.jsonl")
    parser.add_argument("--output-dir", default="checkpoints/stage3")
    parser.add_argument("--epochs", type=int, default=1)
    parser.add_argument("--batch-size", type=int, default=2)
    parser.add_argument("--learning-rate", type=float, default=5e-5)
    parser.add_argument("--beta", type=float, default=0.1)
    parser.add_argument("--max-length", type=int, default=4096)
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    if not Path(args.dataset).exists():
        raise SystemExit(f"Missing DPO dataset: {args.dataset}")
    Path(args.output_dir).mkdir(parents=True, exist_ok=True)

    try:
        from datasets import load_dataset
        from transformers import TrainingArguments
        from trl import DPOTrainer
        from unsloth import FastLanguageModel
    except ImportError as exc:
        raise SystemExit(
            "Install DPO dependencies: unsloth, transformers, trl, datasets."
        ) from exc

    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=args.stage2_checkpoint,
        max_seq_length=args.max_length,
        load_in_4bit=True,
    )
    FastLanguageModel.for_training(model)
    dataset = load_dataset("json", data_files=args.dataset, split="train")

    trainer = DPOTrainer(
        model=model,
        ref_model=None,
        tokenizer=tokenizer,
        train_dataset=dataset,
        beta=args.beta,
        max_length=args.max_length,
        max_prompt_length=2048,
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
